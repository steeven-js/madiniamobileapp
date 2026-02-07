//
//  CacheService.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import Foundation

/// Service for persisting data to local storage.
/// Uses FileManager to store JSON data in the app's cache directory.
final class CacheService {
    // MARK: - Singleton

    static let shared = CacheService()

    // MARK: - Cache Keys

    private enum CacheKey: String {
        case formations
        case categories
        case services
        case articles
        case events
    }

    // MARK: - Properties

    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

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
    }

    // MARK: - Private Helpers

    private func createCacheDirectoryIfNeeded() {
        guard let cacheDirectory = cacheDirectory else { return }
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }

    private func cacheFileURL(for key: CacheKey) -> URL? {
        cacheDirectory?.appendingPathComponent("\(key.rawValue).json")
    }

    // MARK: - Generic Save/Load

    private func save<T: Encodable>(_ data: T, for key: CacheKey) {
        guard let url = cacheFileURL(for: key) else { return }
        do {
            let jsonData = try encoder.encode(data)
            try jsonData.write(to: url)
            #if DEBUG
            print("Cache: Saved \(key.rawValue) to disk")
            #endif
        } catch {
            #if DEBUG
            print("Cache: Failed to save \(key.rawValue): \(error)")
            #endif
        }
    }

    private func load<T: Decodable>(for key: CacheKey, as type: T.Type) -> T? {
        guard let url = cacheFileURL(for: key),
              fileManager.fileExists(atPath: url.path) else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try decoder.decode(type, from: data)
            #if DEBUG
            print("Cache: Loaded \(key.rawValue) from disk")
            #endif
            return decoded
        } catch {
            #if DEBUG
            print("Cache: Failed to load \(key.rawValue): \(error)")
            #endif
            return nil
        }
    }

    // MARK: - Formations

    func saveFormations(_ formations: [Formation]) {
        save(formations, for: .formations)
    }

    func loadFormations() -> [Formation]? {
        load(for: .formations, as: [Formation].self)
    }

    // MARK: - Categories

    func saveCategories(_ categories: [FormationCategory]) {
        save(categories, for: .categories)
    }

    func loadCategories() -> [FormationCategory]? {
        load(for: .categories, as: [FormationCategory].self)
    }

    // MARK: - Services

    func saveServices(_ services: [Service]) {
        save(services, for: .services)
    }

    func loadServices() -> [Service]? {
        load(for: .services, as: [Service].self)
    }

    // MARK: - Articles

    func saveArticles(_ articles: [Article]) {
        save(articles, for: .articles)
    }

    func loadArticles() -> [Article]? {
        load(for: .articles, as: [Article].self)
    }

    // MARK: - Events

    func saveEvents(_ events: [Event]) {
        save(events, for: .events)
    }

    func loadEvents() -> [Event]? {
        load(for: .events, as: [Event].self)
    }

    // MARK: - Clear Cache

    func clearAll() {
        guard let cacheDirectory = cacheDirectory else { return }
        try? fileManager.removeItem(at: cacheDirectory)
        createCacheDirectoryIfNeeded()
        #if DEBUG
        print("Cache: Cleared all cached data")
        #endif
    }
}
