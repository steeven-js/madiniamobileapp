//
//  CacheService.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import Foundation

// MARK: - Cache Content Type

/// Types of cacheable content with their TTL configuration
enum CacheContentType: String, CaseIterable {
    case formations
    case categories
    case services
    case articles
    case events

    /// Time-To-Live in seconds for each content type
    var ttl: TimeInterval {
        switch self {
        case .formations:
            return 24 * 60 * 60  // 24 hours
        case .categories:
            return 7 * 24 * 60 * 60  // 1 week
        case .services:
            return 24 * 60 * 60  // 24 hours
        case .articles:
            return 6 * 60 * 60  // 6 hours (news updates more frequently)
        case .events:
            return 2 * 60 * 60  // 2 hours (time-sensitive)
        }
    }

    /// Display name for UI
    var displayName: String {
        switch self {
        case .formations: return "Formations"
        case .categories: return "Catégories"
        case .services: return "Services"
        case .articles: return "Articles"
        case .events: return "Événements"
        }
    }
}

// MARK: - Cache Freshness

/// Indicates the freshness state of cached data
enum CacheFreshness {
    /// Data is fresh (within 50% of TTL)
    case fresh
    /// Data is getting stale (50-100% of TTL)
    case stale
    /// Data has expired (beyond TTL)
    case expired
    /// No cached data available
    case none

    /// Color indicator for UI
    var colorName: String {
        switch self {
        case .fresh: return "green"
        case .stale: return "orange"
        case .expired: return "red"
        case .none: return "gray"
        }
    }

    /// SF Symbol for freshness
    var icon: String {
        switch self {
        case .fresh: return "checkmark.circle.fill"
        case .stale: return "clock.fill"
        case .expired: return "exclamationmark.triangle.fill"
        case .none: return "questionmark.circle"
        }
    }
}

// MARK: - Cache Metadata

/// Metadata stored alongside cached data
struct CacheMetadata: Codable {
    let cachedAt: Date
    let contentType: String

    var age: TimeInterval {
        Date().timeIntervalSince(cachedAt)
    }

    func freshness(for type: CacheContentType) -> CacheFreshness {
        let ttl = type.ttl
        let ageRatio = age / ttl

        if ageRatio < 0.5 {
            return .fresh
        } else if ageRatio < 1.0 {
            return .stale
        } else {
            return .expired
        }
    }

    func isExpired(for type: CacheContentType) -> Bool {
        age > type.ttl
    }
}

// MARK: - Cache Entry

/// A cached entry containing data and metadata
struct CacheEntry<T: Codable>: Codable {
    let data: T
    let metadata: CacheMetadata
}

// MARK: - Cache Service

/// Service for persisting data to local storage with TTL and freshness tracking.
/// Uses FileManager to store JSON data in the app's cache directory.
@Observable
final class CacheService {
    // MARK: - Singleton

    static let shared = CacheService()

    // MARK: - Properties

    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    /// Cache freshness state for each content type
    private(set) var freshnessState: [CacheContentType: CacheFreshness] = [:]

    /// Last update time for each content type
    private(set) var lastUpdated: [CacheContentType: Date] = [:]

    /// Cache directory URL
    private var cacheDirectory: URL? {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("MadiniaCache", isDirectory: true)
    }

    // MARK: - Initialization

    private init() {
        createCacheDirectoryIfNeeded()
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
        loadMetadataState()
    }

    // MARK: - Private Helpers

    private func createCacheDirectoryIfNeeded() {
        guard let cacheDirectory = cacheDirectory else { return }
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }

    private func cacheFileURL(for type: CacheContentType) -> URL? {
        cacheDirectory?.appendingPathComponent("\(type.rawValue).json")
    }

    private func metadataFileURL(for type: CacheContentType) -> URL? {
        cacheDirectory?.appendingPathComponent("\(type.rawValue)_meta.json")
    }

    /// Loads metadata state for all content types
    private func loadMetadataState() {
        for type in CacheContentType.allCases {
            if let metadata = loadMetadata(for: type) {
                lastUpdated[type] = metadata.cachedAt
                freshnessState[type] = metadata.freshness(for: type)
            } else {
                freshnessState[type] = .none
            }
        }
    }

    /// Updates freshness state for all content types
    func refreshFreshnessState() {
        for type in CacheContentType.allCases {
            if let metadata = loadMetadata(for: type) {
                freshnessState[type] = metadata.freshness(for: type)
            } else {
                freshnessState[type] = .none
            }
        }
    }

    // MARK: - Metadata Operations

    private func saveMetadata(for type: CacheContentType) {
        guard let url = metadataFileURL(for: type) else { return }
        let metadata = CacheMetadata(cachedAt: Date(), contentType: type.rawValue)
        do {
            let data = try encoder.encode(metadata)
            try data.write(to: url)
            lastUpdated[type] = metadata.cachedAt
            freshnessState[type] = .fresh
        } catch {
            #if DEBUG
            print("Cache: Failed to save metadata for \(type.rawValue): \(error)")
            #endif
        }
    }

    private func loadMetadata(for type: CacheContentType) -> CacheMetadata? {
        guard let url = metadataFileURL(for: type),
              fileManager.fileExists(atPath: url.path) else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(CacheMetadata.self, from: data)
        } catch {
            return nil
        }
    }

    // MARK: - Generic Save/Load

    private func save<T: Encodable>(_ data: T, for type: CacheContentType) {
        guard let url = cacheFileURL(for: type) else { return }
        do {
            let jsonData = try encoder.encode(data)
            try jsonData.write(to: url)
            saveMetadata(for: type)
            #if DEBUG
            print("Cache: Saved \(type.rawValue) to disk")
            #endif
        } catch {
            #if DEBUG
            print("Cache: Failed to save \(type.rawValue): \(error)")
            #endif
        }
    }

    private func load<T: Decodable>(for type: CacheContentType, as dataType: T.Type, ignoreExpiry: Bool = false) -> T? {
        guard let url = cacheFileURL(for: type),
              fileManager.fileExists(atPath: url.path) else {
            return nil
        }

        // Check expiry unless ignored
        if !ignoreExpiry, let metadata = loadMetadata(for: type), metadata.isExpired(for: type) {
            #if DEBUG
            print("Cache: \(type.rawValue) has expired (age: \(Int(metadata.age))s, TTL: \(Int(type.ttl))s)")
            #endif
            // Update freshness state
            freshnessState[type] = .expired
            // Return nil to force refresh, but data is still available via loadIgnoringExpiry
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try decoder.decode(dataType, from: data)
            #if DEBUG
            print("Cache: Loaded \(type.rawValue) from disk")
            #endif
            return decoded
        } catch {
            #if DEBUG
            print("Cache: Failed to load \(type.rawValue): \(error)")
            #endif
            return nil
        }
    }

    // MARK: - Public API - Freshness

    /// Returns the freshness state for a content type
    func freshness(for type: CacheContentType) -> CacheFreshness {
        guard let metadata = loadMetadata(for: type) else {
            return .none
        }
        return metadata.freshness(for: type)
    }

    /// Returns the age of cached data in seconds
    func age(for type: CacheContentType) -> TimeInterval? {
        loadMetadata(for: type)?.age
    }

    /// Returns whether the cache for a type needs refresh
    func needsRefresh(_ type: CacheContentType) -> Bool {
        guard let metadata = loadMetadata(for: type) else {
            return true
        }
        return metadata.isExpired(for: type)
    }

    /// Returns types that need refresh
    var typesNeedingRefresh: [CacheContentType] {
        CacheContentType.allCases.filter { needsRefresh($0) }
    }

    // MARK: - Formations

    func saveFormations(_ formations: [Formation]) {
        save(formations, for: .formations)
    }

    func loadFormations() -> [Formation]? {
        load(for: .formations, as: [Formation].self)
    }

    func loadFormationsIgnoringExpiry() -> [Formation]? {
        load(for: .formations, as: [Formation].self, ignoreExpiry: true)
    }

    // MARK: - Categories

    func saveCategories(_ categories: [FormationCategory]) {
        save(categories, for: .categories)
    }

    func loadCategories() -> [FormationCategory]? {
        load(for: .categories, as: [FormationCategory].self)
    }

    func loadCategoriesIgnoringExpiry() -> [FormationCategory]? {
        load(for: .categories, as: [FormationCategory].self, ignoreExpiry: true)
    }

    // MARK: - Services

    func saveServices(_ services: [Service]) {
        save(services, for: .services)
    }

    func loadServices() -> [Service]? {
        load(for: .services, as: [Service].self)
    }

    func loadServicesIgnoringExpiry() -> [Service]? {
        load(for: .services, as: [Service].self, ignoreExpiry: true)
    }

    // MARK: - Articles

    func saveArticles(_ articles: [Article]) {
        save(articles, for: .articles)
    }

    func loadArticles() -> [Article]? {
        load(for: .articles, as: [Article].self)
    }

    func loadArticlesIgnoringExpiry() -> [Article]? {
        load(for: .articles, as: [Article].self, ignoreExpiry: true)
    }

    // MARK: - Events

    func saveEvents(_ events: [Event]) {
        save(events, for: .events)
    }

    func loadEvents() -> [Event]? {
        load(for: .events, as: [Event].self)
    }

    func loadEventsIgnoringExpiry() -> [Event]? {
        load(for: .events, as: [Event].self, ignoreExpiry: true)
    }

    // MARK: - Selective Invalidation

    /// Invalidates cache for a specific content type
    func invalidate(_ type: CacheContentType) {
        guard let dataURL = cacheFileURL(for: type),
              let metaURL = metadataFileURL(for: type) else { return }
        try? fileManager.removeItem(at: dataURL)
        try? fileManager.removeItem(at: metaURL)
        freshnessState[type] = .none
        lastUpdated[type] = nil
        #if DEBUG
        print("Cache: Invalidated \(type.rawValue)")
        #endif
    }

    /// Invalidates cache for multiple content types
    func invalidate(_ types: [CacheContentType]) {
        types.forEach { invalidate($0) }
    }

    /// Invalidates all expired caches
    func invalidateExpired() {
        for type in CacheContentType.allCases {
            if needsRefresh(type) {
                invalidate(type)
            }
        }
    }

    // MARK: - Clear Cache

    /// Clears all cached data
    func clearAll() {
        guard let cacheDirectory = cacheDirectory else { return }
        try? fileManager.removeItem(at: cacheDirectory)
        createCacheDirectoryIfNeeded()
        freshnessState = [:]
        lastUpdated = [:]
        #if DEBUG
        print("Cache: Cleared all cached data")
        #endif
    }

    // MARK: - Statistics

    /// Returns the total cache size in bytes
    var totalCacheSize: Int64 {
        guard let cacheDirectory = cacheDirectory else { return 0 }
        var totalSize: Int64 = 0
        if let files = try? fileManager.contentsOfDirectory(atPath: cacheDirectory.path) {
            for file in files {
                let path = cacheDirectory.appendingPathComponent(file).path
                if let attrs = try? fileManager.attributesOfItem(atPath: path),
                   let size = attrs[.size] as? Int64 {
                    totalSize += size
                }
            }
        }
        return totalSize
    }

    /// Formatted cache size string
    var formattedCacheSize: String {
        let bytes = totalCacheSize
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
