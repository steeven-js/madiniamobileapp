//
//  PreRegistrationsService.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-25.
//

import Foundation
import SwiftUI

/// Service managing user pre-registrations for formations.
/// Handles local storage, API sync, and enforces the 5 pre-registration limit.
@Observable
final class PreRegistrationsService {
    // MARK: - Singleton

    static let shared = PreRegistrationsService()

    // MARK: - Constants

    /// Maximum number of pre-registrations allowed per device
    static let maxPreRegistrations = 5

    // MARK: - Published State

    /// Current pre-registrations from API
    private(set) var preRegistrations: [PreRegistration] = []

    /// IDs of formations the user has pre-registered for (local cache)
    private(set) var preRegisteredFormationIds: Set<Int> = []

    /// Number of pre-registrations used
    var usedCount: Int { preRegistrations.count }

    /// Number of pre-registrations remaining
    var remainingCount: Int { max(0, Self.maxPreRegistrations - usedCount) }

    /// Whether the user can create more pre-registrations
    var canCreateMore: Bool { usedCount < Self.maxPreRegistrations }

    // MARK: - Private Properties

    private let apiService: APIServiceProtocol
    private let userDefaults: UserDefaults

    /// Device UUID for identifying the user
    private var deviceUUID: String {
        if let uuid = userDefaults.string(forKey: "device_uuid"), !uuid.isEmpty {
            return uuid
        }
        let newUUID = UUID().uuidString
        userDefaults.set(newUUID, forKey: "device_uuid")
        return newUUID
    }

    // MARK: - Initialization

    init(
        apiService: APIServiceProtocol = APIService.shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.apiService = apiService
        self.userDefaults = userDefaults
        loadFromLocal()
    }

    // MARK: - Public Methods

    /// Returns the device UUID for use in API calls
    func getDeviceUUID() -> String {
        return deviceUUID
    }

    /// Checks if user is already pre-registered for a formation
    func isPreRegistered(formationId: Int) -> Bool {
        preRegisteredFormationIds.contains(formationId)
    }

    /// Fetches pre-registrations from the API
    @MainActor
    func fetchPreRegistrations() async throws -> [PreRegistration] {
        let registrations = try await apiService.fetchPreRegistrations(deviceUUID: deviceUUID)
        self.preRegistrations = registrations
        self.preRegisteredFormationIds = Set(registrations.map { $0.formationId })
        saveToLocal()
        return registrations
    }

    /// Adds a new pre-registration locally (called after successful API submission)
    @MainActor
    func addPreRegistration(_ registration: PreRegistration) {
        preRegistrations.insert(registration, at: 0)
        preRegisteredFormationIds.insert(registration.formationId)
        saveToLocal()
    }

    /// Refreshes pre-registrations from API
    @MainActor
    func refresh() async {
        do {
            _ = try await fetchPreRegistrations()
        } catch {
            print("PreRegistrationsService: Failed to refresh - \(error.localizedDescription)")
        }
    }

    // MARK: - Local Storage

    private func saveToLocal() {
        let ids = Array(preRegisteredFormationIds)
        if let data = try? JSONEncoder().encode(ids) {
            userDefaults.set(data, forKey: "preregistered_formation_ids")
        }
    }

    private func loadFromLocal() {
        guard let data = userDefaults.data(forKey: "preregistered_formation_ids"),
              let ids = try? JSONDecoder().decode([Int].self, from: data) else {
            return
        }
        preRegisteredFormationIds = Set(ids)
    }
}
