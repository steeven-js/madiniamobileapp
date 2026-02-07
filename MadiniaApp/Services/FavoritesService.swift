//
//  FavoritesService.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-25.
//

import Foundation
import SwiftUI

// MARK: - API Response Types

/// Response for GET /favorites endpoint (returns array of formation IDs)
struct FavoriteIdsResponse: Decodable {
    let success: Bool
    let data: [Int]
}

/// Response for GET /favorites/formations endpoint (returns full formation data)
struct FavoriteFormationsResponse: Decodable {
    let success: Bool
    let data: [Formation]
}

/// Response for POST/DELETE favorites endpoints
struct FavoriteActionResponse: Decodable {
    let success: Bool
    let message: String?
}

// MARK: - Favorites Service

/// Service for managing saved formations (favorites).
/// Uses local storage (UserDefaults) with API sync for persistence.
///
/// Usage:
/// ```swift
/// @Environment(FavoritesService.self) private var favoritesService
/// favoritesService.isFavorite(formationId: 123)
/// Task { await favoritesService.toggleFavorite(formationId: 123) }
/// ```
@Observable
final class FavoritesService {
    /// Shared singleton instance
    static let shared = FavoritesService()

    // MARK: - Storage Keys

    private let deviceUUIDKey = "device_uuid"
    private let favoriteIdsKey = "favorite_formation_ids"

    // MARK: - Public State

    /// Set of favorite formation IDs (observable)
    private(set) var favoriteFormationIds: Set<Int> = []

    /// Whether a sync is in progress
    private(set) var isSyncing = false

    /// Last sync error (nil if last sync was successful)
    private(set) var lastSyncError: String?

    // MARK: - Private Properties

    private var baseURL: String { AppEnvironment.apiBaseURL }
    private var apiKey: String { SecretsManager.apiKey }
    private let session: URLSession
    private let decoder: JSONDecoder

    // MARK: - Initialization

    private init() {
        self.session = .shared
        self.decoder = JSONDecoder()

        // Ensure device UUID exists
        ensureDeviceUUID()

        // Load from local storage
        loadFromLocal()

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

    // MARK: - Public Methods

    /// Check if a formation is favorited
    func isFavorite(formationId: Int) -> Bool {
        favoriteFormationIds.contains(formationId)
    }

    /// Toggle favorite status for a formation.
    /// Updates local storage immediately, then syncs with server.
    func toggleFavorite(formationId: Int) async {
        if isFavorite(formationId: formationId) {
            await removeFavorite(formationId: formationId)
        } else {
            await addFavorite(formationId: formationId)
        }
    }

    /// Add a formation to favorites
    func addFavorite(formationId: Int) async {
        // Update local immediately
        await MainActor.run {
            favoriteFormationIds.insert(formationId)
            saveToLocal()
        }

        // Sync with server
        do {
            try await addFavoriteToServer(formationId: formationId)
            await MainActor.run {
                lastSyncError = nil
            }
        } catch {
            #if DEBUG
            print("Failed to add favorite to server: \(error)")
            #endif
            await MainActor.run {
                lastSyncError = error.localizedDescription
            }
        }
    }

    /// Remove a formation from favorites
    func removeFavorite(formationId: Int) async {
        // Update local immediately
        await MainActor.run {
            favoriteFormationIds.remove(formationId)
            saveToLocal()
        }

        // Sync with server
        do {
            try await removeFavoriteFromServer(formationId: formationId)
            await MainActor.run {
                lastSyncError = nil
            }
        } catch {
            #if DEBUG
            print("Failed to remove favorite from server: \(error)")
            #endif
            await MainActor.run {
                lastSyncError = error.localizedDescription
            }
        }
    }

    /// Sync favorites with server (fetches latest from API)
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
            let serverIds = try await fetchFavoriteIdsFromServer()
            await MainActor.run {
                favoriteFormationIds = Set(serverIds)
                saveToLocal()
                lastSyncError = nil
            }
        } catch {
            #if DEBUG
            print("Failed to sync favorites: \(error)")
            #endif
            await MainActor.run {
                lastSyncError = error.localizedDescription
            }
        }
    }

    /// Fetch saved formations with full data from server
    func fetchSavedFormations() async throws -> [Formation] {
        let url = URL(string: "\(baseURL)/favorites/formations?device_uuid=\(deviceUUID)")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.timeoutInterval = 30

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noData
        }

        if let error = APIError.from(statusCode: httpResponse.statusCode) {
            throw error
        }

        let result = try decoder.decode(FavoriteFormationsResponse.self, from: data)
        return result.data
    }

    // MARK: - Local Storage

    private func loadFromLocal() {
        guard let data = UserDefaults.standard.data(forKey: favoriteIdsKey),
              let ids = try? JSONDecoder().decode([Int].self, from: data) else {
            favoriteFormationIds = []
            return
        }
        favoriteFormationIds = Set(ids)
    }

    private func saveToLocal() {
        guard let data = try? JSONEncoder().encode(Array(favoriteFormationIds)) else { return }
        UserDefaults.standard.set(data, forKey: favoriteIdsKey)
    }

    // MARK: - API Calls

    private func fetchFavoriteIdsFromServer() async throws -> [Int] {
        let url = URL(string: "\(baseURL)/favorites?device_uuid=\(deviceUUID)")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.timeoutInterval = 30

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noData
        }

        if let error = APIError.from(statusCode: httpResponse.statusCode) {
            throw error
        }

        let result = try decoder.decode(FavoriteIdsResponse.self, from: data)
        return result.data
    }

    private func addFavoriteToServer(formationId: Int) async throws {
        let url = URL(string: "\(baseURL)/favorites")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.timeoutInterval = 30

        let body: [String: Any] = [
            "device_uuid": deviceUUID,
            "formation_id": formationId
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noData
        }

        // 201 Created or 200 OK are both acceptable
        if httpResponse.statusCode >= 400 {
            if let error = APIError.from(statusCode: httpResponse.statusCode) {
                throw error
            }
        }
    }

    private func removeFavoriteFromServer(formationId: Int) async throws {
        let url = URL(string: "\(baseURL)/favorites/\(formationId)?device_uuid=\(deviceUUID)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.timeoutInterval = 30

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noData
        }

        // 404 is acceptable (already deleted)
        if httpResponse.statusCode >= 400 && httpResponse.statusCode != 404 {
            if let error = APIError.from(statusCode: httpResponse.statusCode) {
                throw error
            }
        }
    }
}

// MARK: - Supabase Realtime (Future Implementation)
//
// To enable realtime sync across devices:
// 1. Add Supabase Swift package: https://github.com/supabase/supabase-swift
// 2. Configure Supabase client with anon key
// 3. Subscribe to postgres changes on user_favorites table
//
// Example implementation:
// ```swift
// import Supabase
//
// private var supabase: SupabaseClient!
// private var realtimeChannel: RealtimeChannel?
//
// func setupSupabase() {
//     supabase = SupabaseClient(
//         supabaseURL: URL(string: "https://rrgxotnrwmjqnaugllks.supabase.co")!,
//         supabaseKey: "YOUR_ANON_KEY"
//     )
// }
//
// func setupRealtimeListener() {
//     realtimeChannel = supabase.channel("favorites-\(deviceUUID)")
//     realtimeChannel?.onPostgresChange(
//         event: .all,
//         schema: "public",
//         table: "user_favorites",
//         filter: "device_uuid=eq.\(deviceUUID)"
//     ) { [weak self] payload in
//         Task { @MainActor in
//             await self?.handleRealtimeChange(payload)
//         }
//     }
//     realtimeChannel?.subscribe()
// }
// ```
