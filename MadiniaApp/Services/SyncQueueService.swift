//
//  SyncQueueService.swift
//  MadiniaApp
//
//  Service de file d'attente pour les opérations en mode hors-ligne.
//  Enregistre les opérations localement et les synchronise au retour en ligne.
//

import Foundation

/// Types d'opérations pouvant être mises en file d'attente
enum PendingOperationType: String, Codable {
    case addFavorite = "add_favorite"
    case removeFavorite = "remove_favorite"
    case registerEvent = "register_event"
    case unregisterEvent = "unregister_event"
}

/// Représente une opération en attente de synchronisation
struct PendingOperation: Codable, Identifiable {
    let id: UUID
    let type: PendingOperationType
    let payload: [String: String]
    let createdAt: Date
    var retryCount: Int

    init(type: PendingOperationType, payload: [String: String]) {
        self.id = UUID()
        self.type = type
        self.payload = payload
        self.createdAt = Date()
        self.retryCount = 0
    }
}

/// Service de gestion de la file d'attente des opérations hors-ligne.
@Observable
final class SyncQueueService {

    // MARK: - Singleton

    static let shared = SyncQueueService()

    // MARK: - Constants

    private let storageKey = "pending_sync_operations"
    private let maxRetries = 3
    private let baseURL = "https://madinia.fr/api/v1"

    // MARK: - Published Properties

    /// Nombre d'opérations en attente
    private(set) var pendingCount: Int = 0

    /// Indique si une synchronisation est en cours
    private(set) var isSyncing: Bool = false

    /// Dernière erreur de synchronisation
    private(set) var lastSyncError: String?

    /// Date de la dernière synchronisation réussie
    private(set) var lastSyncDate: Date?

    // MARK: - Private Properties

    private var pendingOperations: [PendingOperation] = []

    // MARK: - Initialization

    private init() {
        loadPendingOperations()
        setupNetworkObserver()
    }

    // MARK: - Public Methods

    /// Ajoute une opération à la file d'attente
    func queueOperation(type: PendingOperationType, payload: [String: String]) {
        let operation = PendingOperation(type: type, payload: payload)
        pendingOperations.append(operation)
        pendingCount = pendingOperations.count
        savePendingOperations()

        #if DEBUG
        print("[SyncQueue] Queued operation: \(type.rawValue), payload: \(payload)")
        #endif
    }

    /// Synchronise toutes les opérations en attente
    func syncPendingOperations() async {
        guard !pendingOperations.isEmpty else {
            #if DEBUG
            print("[SyncQueue] No pending operations to sync")
            #endif
            return
        }

        guard NetworkMonitorService.shared.isConnected else {
            #if DEBUG
            print("[SyncQueue] Cannot sync: offline")
            #endif
            return
        }

        await MainActor.run {
            isSyncing = true
            lastSyncError = nil
        }

        var successfulOperations: [UUID] = []
        var failedOperations: [(UUID, String)] = []

        for operation in pendingOperations {
            do {
                try await executeOperation(operation)
                successfulOperations.append(operation.id)

                #if DEBUG
                print("[SyncQueue] Successfully synced: \(operation.type.rawValue)")
                #endif
            } catch {
                #if DEBUG
                print("[SyncQueue] Failed to sync: \(operation.type.rawValue), error: \(error)")
                #endif

                failedOperations.append((operation.id, error.localizedDescription))

                // Incrémenter le compteur de retry
                if let index = pendingOperations.firstIndex(where: { $0.id == operation.id }) {
                    pendingOperations[index].retryCount += 1

                    // Supprimer si trop de retries
                    if pendingOperations[index].retryCount >= maxRetries {
                        successfulOperations.append(operation.id) // Marquer comme traité
                        #if DEBUG
                        print("[SyncQueue] Removed operation after max retries: \(operation.type.rawValue)")
                        #endif
                    }
                }
            }
        }

        // Supprimer les opérations réussies
        pendingOperations.removeAll { successfulOperations.contains($0.id) }

        await MainActor.run {
            self.pendingCount = self.pendingOperations.count
            self.isSyncing = false

            if failedOperations.isEmpty || self.pendingOperations.isEmpty {
                self.lastSyncDate = Date()
            }

            if !failedOperations.isEmpty && !self.pendingOperations.isEmpty {
                self.lastSyncError = "Certaines opérations n'ont pas pu être synchronisées"
            }
        }

        savePendingOperations()
    }

    /// Supprime toutes les opérations en attente
    func clearPendingOperations() {
        pendingOperations.removeAll()
        pendingCount = 0
        savePendingOperations()
    }

    /// Retourne la liste des opérations en attente (lecture seule)
    func getPendingOperations() -> [PendingOperation] {
        return pendingOperations
    }

    // MARK: - Private Methods

    private func setupNetworkObserver() {
        NetworkMonitorService.shared.onBackOnline = { [weak self] in
            Task {
                await self?.syncPendingOperations()
            }
        }
    }

    private func executeOperation(_ operation: PendingOperation) async throws {
        let deviceUUID = getDeviceUUID()

        switch operation.type {
        case .addFavorite:
            guard let formationIdString = operation.payload["formationId"],
                  let formationId = Int(formationIdString) else {
                throw SyncError.invalidPayload
            }
            try await syncAddFavorite(formationId: formationId, deviceUUID: deviceUUID)

        case .removeFavorite:
            guard let formationIdString = operation.payload["formationId"],
                  let formationId = Int(formationIdString) else {
                throw SyncError.invalidPayload
            }
            try await syncRemoveFavorite(formationId: formationId, deviceUUID: deviceUUID)

        case .registerEvent:
            guard let eventId = operation.payload["eventId"] else {
                throw SyncError.invalidPayload
            }
            try await syncRegisterEvent(eventId: eventId, deviceUUID: deviceUUID)

        case .unregisterEvent:
            guard let eventId = operation.payload["eventId"] else {
                throw SyncError.invalidPayload
            }
            try await syncUnregisterEvent(eventId: eventId, deviceUUID: deviceUUID)
        }
    }

    // MARK: - API Sync Methods

    private func syncAddFavorite(formationId: Int, deviceUUID: String) async throws {
        guard let url = URL(string: "\(baseURL)/favorites") else {
            throw SyncError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "formation_id": formationId,
            "device_uuid": deviceUUID
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SyncError.serverError
        }
    }

    private func syncRemoveFavorite(formationId: Int, deviceUUID: String) async throws {
        guard let url = URL(string: "\(baseURL)/favorites/\(formationId)?device_uuid=\(deviceUUID)") else {
            throw SyncError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SyncError.serverError
        }
    }

    private func syncRegisterEvent(eventId: String, deviceUUID: String) async throws {
        guard let url = URL(string: "\(baseURL)/events/\(eventId)/register") else {
            throw SyncError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["device_uuid": deviceUUID]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SyncError.serverError
        }
    }

    private func syncUnregisterEvent(eventId: String, deviceUUID: String) async throws {
        guard let url = URL(string: "\(baseURL)/events/\(eventId)/unregister?device_uuid=\(deviceUUID)") else {
            throw SyncError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SyncError.serverError
        }
    }

    // MARK: - Persistence

    private func loadPendingOperations() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let operations = try? JSONDecoder().decode([PendingOperation].self, from: data) else {
            pendingOperations = []
            pendingCount = 0
            return
        }

        pendingOperations = operations
        pendingCount = operations.count

        #if DEBUG
        print("[SyncQueue] Loaded \(operations.count) pending operations")
        #endif
    }

    private func savePendingOperations() {
        guard let data = try? JSONEncoder().encode(pendingOperations) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func getDeviceUUID() -> String {
        if let uuid = UserDefaults.standard.string(forKey: "device_uuid") {
            return uuid
        }
        let newUUID = UUID().uuidString
        UserDefaults.standard.set(newUUID, forKey: "device_uuid")
        return newUUID
    }
}

// MARK: - Errors

enum SyncError: LocalizedError {
    case invalidPayload
    case invalidURL
    case serverError
    case networkError

    var errorDescription: String? {
        switch self {
        case .invalidPayload:
            return "Données invalides"
        case .invalidURL:
            return "URL invalide"
        case .serverError:
            return "Erreur serveur"
        case .networkError:
            return "Erreur réseau"
        }
    }
}
