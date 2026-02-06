//
//  MadiContextService.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-06.
//

import Foundation

// MARK: - API Response Types

/// Response for GET /madi/history endpoint
struct MadiHistoryResponse: Codable {
    let success: Bool
    let data: MadiHistoryData?
}

struct MadiHistoryData: Codable {
    let messages: [MadiMessage]
    let viewedFormations: [ViewedFormation]
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case messages
        case viewedFormations = "viewed_formations"
        case updatedAt = "updated_at"
    }
}

/// Response for POST /madi/history endpoint
struct MadiHistorySaveResponse: Codable {
    let success: Bool
    let message: String?
}

/// Response for POST /madi/track-view endpoint
struct MadiTrackViewResponse: Codable {
    let success: Bool
    let message: String?
}

// MARK: - Viewed Formation

/// Represents a formation that the user has viewed with timestamp.
struct ViewedFormation: Codable, Equatable {
    let formationId: Int
    let formationSlug: String
    let formationTitle: String
    let categoryName: String?
    let viewedAt: Date

    enum CodingKeys: String, CodingKey {
        case formationId = "formation_id"
        case formationSlug = "formation_slug"
        case formationTitle = "formation_title"
        case categoryName = "category_name"
        case viewedAt = "viewed_at"
    }

    init(formation: Formation) {
        self.formationId = formation.id
        self.formationSlug = formation.slug
        self.formationTitle = formation.title
        self.categoryName = formation.category?.name
        self.viewedAt = Date()
    }

    init(formationId: Int, formationSlug: String, formationTitle: String, categoryName: String?, viewedAt: Date) {
        self.formationId = formationId
        self.formationSlug = formationSlug
        self.formationTitle = formationTitle
        self.categoryName = categoryName
        self.viewedAt = viewedAt
    }
}

// MARK: - Madi Context Service

/// Centralized service for managing Madi AI coach context.
/// Tracks viewed formations, conversation history, and provides intelligent recommendations.
/// Uses local storage (UserDefaults) with API sync for persistence across devices.
@Observable
final class MadiContextService {
    /// Shared singleton instance
    static let shared = MadiContextService()

    // MARK: - Storage Keys

    private let deviceUUIDKey = "device_uuid"
    private let conversationHistoryKey = "madi_conversation_history"
    private let viewedFormationsKey = "madi_viewed_formations"
    private let lastSyncKey = "madi_last_sync"

    // MARK: - Configuration

    /// Maximum number of messages to persist
    private let maxConversationMessages = 50

    /// Maximum number of viewed formations to track
    private let maxViewedFormations = 100

    // MARK: - API Configuration

    private let baseURL = "https://madinia.fr/api/v1"
    private var apiKey: String { SecretsManager.apiKey }
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    // MARK: - Public State

    /// Formations the user has viewed
    private(set) var viewedFormations: [ViewedFormation] = []

    /// Whether a sync is in progress
    private(set) var isSyncing = false

    /// Last sync error (nil if last sync was successful)
    private(set) var lastSyncError: String?

    /// Cached conversation history (loaded on demand)
    private var cachedConversation: [MadiMessage]?

    // MARK: - Initialization

    private init() {
        self.session = .shared
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601

        // Ensure device UUID exists
        ensureDeviceUUID()

        // Load from local storage
        loadViewedFormations()

        // Sync with server in background
        Task {
            await syncWithServer()
        }
    }

    // MARK: - Device UUID

    /// Get the device UUID (creates one if doesn't exist)
    var deviceUUID: String {
        if let uuid = UserDefaults.standard.string(forKey: deviceUUIDKey) {
            return uuid
        }
        let newUUID = UUID().uuidString
        UserDefaults.standard.set(newUUID, forKey: deviceUUIDKey)
        return newUUID
    }

    private func ensureDeviceUUID() {
        _ = deviceUUID
    }

    // MARK: - Formation Tracking

    /// Track when a user views a formation
    func trackFormationView(_ formation: Formation) {
        // Check if already viewed recently (within last hour) to avoid duplicates
        let recentCutoff = Date().addingTimeInterval(-3600)
        if viewedFormations.contains(where: {
            $0.formationId == formation.id && $0.viewedAt > recentCutoff
        }) {
            return // Already tracked recently
        }

        let viewed = ViewedFormation(formation: formation)
        viewedFormations.insert(viewed, at: 0)

        // Trim to max size (FIFO)
        if viewedFormations.count > maxViewedFormations {
            viewedFormations = Array(viewedFormations.prefix(maxViewedFormations))
        }

        saveViewedFormations()

        // Sync to server in background
        Task {
            await trackFormationViewOnServer(viewed)
        }
    }

    /// Get recently viewed formations (last 7 days)
    func recentlyViewedFormations(limit: Int = 10) -> [ViewedFormation] {
        let weekAgo = Date().addingTimeInterval(-7 * 24 * 3600)
        return Array(viewedFormations.filter { $0.viewedAt > weekAgo }.prefix(limit))
    }

    /// Get unique formation IDs the user has viewed
    func viewedFormationIds() -> Set<Int> {
        Set(viewedFormations.map { $0.formationId })
    }

    /// Get most viewed categories
    func topCategories(limit: Int = 3) -> [String] {
        let categoryNames = viewedFormations.compactMap { $0.categoryName }
        let counts = Dictionary(grouping: categoryNames, by: { $0 }).mapValues { $0.count }
        return counts.sorted { $0.value > $1.value }.prefix(limit).map { $0.key }
    }

    // MARK: - Conversation History

    /// Save conversation to persistent storage
    func saveConversation(_ messages: [MadiMessage]) {
        // Only keep last N messages (FIFO)
        let messagesToSave = Array(messages.suffix(maxConversationMessages))

        guard let data = try? encoder.encode(messagesToSave) else {
            #if DEBUG
            print("Failed to encode conversation history")
            #endif
            return
        }

        UserDefaults.standard.set(data, forKey: conversationHistoryKey)
        cachedConversation = messagesToSave

        // Sync to server in background (debounced - only every 5 messages or on clear)
        if messagesToSave.count % 5 == 0 || messagesToSave.count <= 1 {
            Task {
                await saveHistoryToServer()
            }
        }
    }

    /// Load conversation from persistent storage
    func loadConversation() -> [MadiMessage] {
        if let cached = cachedConversation {
            return cached
        }

        guard let data = UserDefaults.standard.data(forKey: conversationHistoryKey),
              let messages = try? decoder.decode([MadiMessage].self, from: data) else {
            return []
        }

        cachedConversation = messages
        return messages
    }

    /// Clear conversation history
    func clearConversationHistory() {
        UserDefaults.standard.removeObject(forKey: conversationHistoryKey)
        cachedConversation = nil

        // Sync clear to server
        Task {
            await clearHistoryOnServer()
        }
    }

    /// Clear all history (conversation + viewed formations)
    func clearAllHistory() {
        clearConversationHistory()
        viewedFormations = []
        saveViewedFormations()

        // Sync clear to server
        Task {
            await clearHistoryOnServer()
        }
    }

    // MARK: - Server Sync

    /// Sync with server (fetches latest from API)
    func syncWithServer() async {
        await MainActor.run {
            isSyncing = true
        }

        defer {
            Task { @MainActor in
                isSyncing = false
            }
        }

        do {
            let serverData = try await fetchHistoryFromServer()

            await MainActor.run {
                // Merge server data with local (server wins for older data)
                if let serverMessages = serverData.messages, !serverMessages.isEmpty {
                    // If local is empty, use server data
                    if cachedConversation?.isEmpty ?? true {
                        cachedConversation = serverMessages
                        if let data = try? encoder.encode(serverMessages) {
                            UserDefaults.standard.set(data, forKey: conversationHistoryKey)
                        }
                    }
                }

                if let serverViewed = serverData.viewedFormations, !serverViewed.isEmpty {
                    // Merge: keep local recent ones + server ones not in local
                    let localIds = Set(viewedFormations.map { $0.formationId })
                    let newFromServer = serverViewed.filter { !localIds.contains($0.formationId) }
                    viewedFormations.append(contentsOf: newFromServer)
                    viewedFormations.sort { $0.viewedAt > $1.viewedAt }
                    viewedFormations = Array(viewedFormations.prefix(maxViewedFormations))
                    saveViewedFormationsLocally()
                }

                lastSyncError = nil
            }
        } catch {
            #if DEBUG
            print("Failed to sync Madi history: \(error)")
            #endif
            await MainActor.run {
                lastSyncError = error.localizedDescription
            }
        }
    }

    /// Force sync current state to server
    func forceSyncToServer() async {
        await saveHistoryToServer()
    }

    // MARK: - Smart Recommendations

    /// Get recommended formations based on user behavior
    /// - Parameters:
    ///   - allFormations: All available formations
    ///   - favoriteIds: User's favorite formation IDs
    /// - Returns: Sorted list of recommended formations with scores
    func getRecommendations(
        from allFormations: [Formation],
        favoriteIds: Set<Int>
    ) -> [(formation: Formation, score: Double, reason: String)] {
        var recommendations: [(Formation, Double, String)] = []

        let viewedIds = viewedFormationIds()
        let topCats = topCategories()

        for formation in allFormations {
            var score: Double = 0
            var reason = ""

            // Skip if already viewed
            if viewedIds.contains(formation.id) {
                continue
            }

            // Score based on category match with favorites
            if let category = formation.category?.name {
                let favoriteFormations = allFormations.filter { favoriteIds.contains($0.id) }
                let favoriteCategoryNames = Set(favoriteFormations.compactMap { $0.category?.name })

                if favoriteCategoryNames.contains(category) {
                    score += 30
                    reason = "Dans vos catégories favorites"
                }
            }

            // Score based on recently viewed categories
            if let category = formation.category?.name, topCats.contains(category) {
                score += 20
                if reason.isEmpty {
                    reason = "Basé sur vos consultations récentes"
                }
            }

            // Score based on level progression
            if let viewedLevel = mostCommonViewedLevel(),
               shouldRecommendLevel(formation.level, afterViewing: viewedLevel) {
                score += 15
                if reason.isEmpty {
                    reason = "Pour progresser dans votre parcours"
                }
            }

            // Boost popular formations
            if let views = formation.viewsCount, views > 100 {
                score += 5
            }

            // Only include if has positive score
            if score > 0 {
                recommendations.append((formation, score, reason))
            }
        }

        // Sort by score descending
        return recommendations.sorted { $0.1 > $1.1 }
    }

    /// Get contextual greeting message based on user history
    func getContextualGreeting(
        favoriteIds: Set<Int>,
        formations: [Formation]
    ) -> String? {
        // Check for new formations in favorite categories
        let favoriteFormations = formations.filter { favoriteIds.contains($0.id) }
        let favoriteCategoryNames = Set(favoriteFormations.compactMap { $0.category?.name })

        if !favoriteIds.isEmpty && !favoriteCategoryNames.isEmpty {
            let categoryList = favoriteCategoryNames.prefix(2).joined(separator: " et ")
            return "Je vois que vous vous intéressez à \(categoryList). Voulez-vous que je vous recommande des formations complémentaires ?"
        }

        // Check for recently viewed
        let recent = recentlyViewedFormations(limit: 3)
        if !recent.isEmpty {
            let lastViewed = recent[0]
            return "Vous avez consulté récemment « \(lastViewed.formationTitle) ». Souhaitez-vous explorer des formations similaires ?"
        }

        return nil
    }

    // MARK: - Private Helpers - Local Storage

    private func loadViewedFormations() {
        guard let data = UserDefaults.standard.data(forKey: viewedFormationsKey),
              let formations = try? decoder.decode([ViewedFormation].self, from: data) else {
            viewedFormations = []
            return
        }
        viewedFormations = formations
    }

    private func saveViewedFormations() {
        saveViewedFormationsLocally()
    }

    private func saveViewedFormationsLocally() {
        guard let data = try? encoder.encode(viewedFormations) else { return }
        UserDefaults.standard.set(data, forKey: viewedFormationsKey)
    }

    // MARK: - Private Helpers - API Calls

    private func fetchHistoryFromServer() async throws -> (messages: [MadiMessage]?, viewedFormations: [ViewedFormation]?) {
        let url = URL(string: "\(baseURL)/madi/history?device_uuid=\(deviceUUID)")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.timeoutInterval = 30

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noData
        }

        // 404 is acceptable (no history yet)
        if httpResponse.statusCode == 404 {
            return (nil, nil)
        }

        if let error = APIError.from(statusCode: httpResponse.statusCode) {
            throw error
        }

        let result = try decoder.decode(MadiHistoryResponse.self, from: data)
        return (result.data?.messages, result.data?.viewedFormations)
    }

    private func saveHistoryToServer() async {
        do {
            let url = URL(string: "\(baseURL)/madi/history")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
            request.timeoutInterval = 30

            let body: [String: Any] = [
                "device_uuid": deviceUUID,
                "messages": (try? JSONSerialization.jsonObject(with: encoder.encode(cachedConversation ?? []))) ?? [],
                "viewed_formations": (try? JSONSerialization.jsonObject(with: encoder.encode(viewedFormations))) ?? []
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (_, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.noData
            }

            if httpResponse.statusCode >= 400 {
                if let error = APIError.from(statusCode: httpResponse.statusCode) {
                    throw error
                }
            }

            await MainActor.run {
                lastSyncError = nil
            }

            #if DEBUG
            print("Madi history saved to server successfully")
            #endif
        } catch {
            #if DEBUG
            print("Failed to save Madi history to server: \(error)")
            #endif
            await MainActor.run {
                lastSyncError = error.localizedDescription
            }
        }
    }

    private func trackFormationViewOnServer(_ viewed: ViewedFormation) async {
        do {
            let url = URL(string: "\(baseURL)/madi/track-view")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
            request.timeoutInterval = 30

            let body: [String: Any] = [
                "device_uuid": deviceUUID,
                "formation_id": viewed.formationId,
                "formation_slug": viewed.formationSlug,
                "formation_title": viewed.formationTitle,
                "category_name": viewed.categoryName ?? NSNull(),
                "viewed_at": ISO8601DateFormatter().string(from: viewed.viewedAt)
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (_, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.noData
            }

            if httpResponse.statusCode >= 400 {
                if let error = APIError.from(statusCode: httpResponse.statusCode) {
                    throw error
                }
            }

            #if DEBUG
            print("Formation view tracked on server: \(viewed.formationTitle)")
            #endif
        } catch {
            #if DEBUG
            print("Failed to track formation view on server: \(error)")
            #endif
        }
    }

    private func clearHistoryOnServer() async {
        do {
            let url = URL(string: "\(baseURL)/madi/history?device_uuid=\(deviceUUID)")!
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
            request.timeoutInterval = 30

            let (_, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.noData
            }

            // 404 is acceptable (nothing to delete)
            if httpResponse.statusCode >= 400 && httpResponse.statusCode != 404 {
                if let error = APIError.from(statusCode: httpResponse.statusCode) {
                    throw error
                }
            }

            #if DEBUG
            print("Madi history cleared on server")
            #endif
        } catch {
            #if DEBUG
            print("Failed to clear Madi history on server: \(error)")
            #endif
        }
    }

    private func mostCommonViewedLevel() -> String? {
        // Map viewed formations to their levels (would need to store this)
        // For now, return nil - would need level in ViewedFormation
        return nil
    }

    private func shouldRecommendLevel(_ level: String, afterViewing viewedLevel: String) -> Bool {
        let levelOrder = ["debutant": 0, "intermediaire": 1, "avance": 2]
        guard let current = levelOrder[viewedLevel],
              let candidate = levelOrder[level] else {
            return false
        }
        // Recommend same level or one level up
        return candidate >= current && candidate <= current + 1
    }
}
