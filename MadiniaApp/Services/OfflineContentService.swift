//
//  OfflineContentService.swift
//  MadiniaApp
//
//  Service de gestion du contenu hors-ligne.
//  Permet le téléchargement et le stockage des formations pour une lecture offline.
//

import Foundation
import SwiftUI

/// État de progression d'un téléchargement
struct DownloadProgress: Identifiable {
    let id: Int // formationId
    var progress: Double // 0.0 to 1.0
    var status: DownloadStatus
    var error: String?

    enum DownloadStatus: String {
        case pending = "En attente"
        case downloading = "Téléchargement"
        case completed = "Terminé"
        case failed = "Échec"
    }
}

/// Métadonnées d'une formation stockée hors-ligne
struct OfflineFormationMetadata: Codable {
    let formationId: Int
    let downloadedAt: Date
    let fileSize: Int64
    let imageFileName: String?
}

/// Service de gestion du contenu hors-ligne.
@Observable
final class OfflineContentService {

    // MARK: - Singleton

    static let shared = OfflineContentService()

    // MARK: - Constants

    private let offlineDirectoryName = "OfflineContent"
    private let metadataFileName = "offline_metadata.json"
    private let formationsDirectoryName = "formations"

    // MARK: - Published Properties

    /// IDs des formations disponibles hors-ligne
    private(set) var offlineFormationIds: Set<Int> = []

    /// Progression des téléchargements en cours
    private(set) var downloadProgress: [Int: DownloadProgress] = [:]

    /// Espace de stockage total utilisé (en bytes)
    private(set) var totalStorageUsed: Int64 = 0

    /// Indique si un téléchargement est en cours
    var isDownloading: Bool {
        downloadProgress.values.contains { $0.status == .downloading || $0.status == .pending }
    }

    // MARK: - Private Properties

    private var offlineMetadata: [Int: OfflineFormationMetadata] = [:]
    private let fileManager = FileManager.default

    // MARK: - Computed Properties

    /// Répertoire racine pour le stockage hors-ligne
    private var offlineDirectory: URL {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(offlineDirectoryName)
    }

    /// Répertoire pour les formations
    private var formationsDirectory: URL {
        return offlineDirectory.appendingPathComponent(formationsDirectoryName)
    }

    /// Fichier de métadonnées
    private var metadataFileURL: URL {
        return offlineDirectory.appendingPathComponent(metadataFileName)
    }

    // MARK: - Initialization

    private init() {
        createDirectoriesIfNeeded()
        loadMetadata()
        calculateStorageUsed()
    }

    // MARK: - Public Methods

    /// Vérifie si une formation est disponible hors-ligne
    func isAvailableOffline(formationId: Int) -> Bool {
        return offlineFormationIds.contains(formationId)
    }

    /// Télécharge une formation pour une lecture hors-ligne
    func downloadFormation(_ formation: Formation) async {
        guard !offlineFormationIds.contains(formation.id) else {
            #if DEBUG
            print("[OfflineContent] Formation \(formation.id) already downloaded")
            #endif
            return
        }

        // Initialiser la progression
        await MainActor.run {
            downloadProgress[formation.id] = DownloadProgress(
                id: formation.id,
                progress: 0.0,
                status: .downloading
            )
        }

        do {
            // 1. Sauvegarder les données JSON de la formation
            let formationFileURL = formationsDirectory.appendingPathComponent("\(formation.id).json")
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let formationData = try encoder.encode(formation)
            try formationData.write(to: formationFileURL)

            await MainActor.run {
                downloadProgress[formation.id]?.progress = 0.3
            }

            // 2. Télécharger l'image si disponible
            var imageFileName: String?
            var imageSize: Int64 = 0

            if let imageUrlString = formation.imageUrl,
               let imageUrl = URL(string: imageUrlString) {
                do {
                    let (imageData, _) = try await URLSession.shared.data(from: imageUrl)
                    let imageName = "\(formation.id)_image.jpg"
                    let imageFileURL = formationsDirectory.appendingPathComponent(imageName)
                    try imageData.write(to: imageFileURL)
                    imageFileName = imageName
                    imageSize = Int64(imageData.count)

                    await MainActor.run {
                        downloadProgress[formation.id]?.progress = 0.8
                    }
                } catch {
                    #if DEBUG
                    print("[OfflineContent] Failed to download image for formation \(formation.id): \(error)")
                    #endif
                    // Continue sans l'image - pas une erreur fatale
                }
            }

            // 3. Mettre à jour les métadonnées
            let totalSize = Int64(formationData.count) + imageSize
            let metadata = OfflineFormationMetadata(
                formationId: formation.id,
                downloadedAt: Date(),
                fileSize: totalSize,
                imageFileName: imageFileName
            )

            await MainActor.run {
                self.offlineMetadata[formation.id] = metadata
                self.offlineFormationIds.insert(formation.id)
                self.totalStorageUsed += totalSize
                self.downloadProgress[formation.id]?.progress = 1.0
                self.downloadProgress[formation.id]?.status = .completed
            }

            saveMetadata()

            #if DEBUG
            print("[OfflineContent] Successfully downloaded formation \(formation.id)")
            #endif

            // Retirer de la liste de progression après un délai
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                self.downloadProgress.removeValue(forKey: formation.id)
            }

        } catch {
            await MainActor.run {
                self.downloadProgress[formation.id]?.status = .failed
                self.downloadProgress[formation.id]?.error = error.localizedDescription
            }

            #if DEBUG
            print("[OfflineContent] Failed to download formation \(formation.id): \(error)")
            #endif
        }
    }

    /// Supprime une formation du stockage hors-ligne
    func removeFormation(formationId: Int) {
        guard offlineFormationIds.contains(formationId) else { return }

        let formationFileURL = formationsDirectory.appendingPathComponent("\(formationId).json")

        // Supprimer le fichier JSON
        try? fileManager.removeItem(at: formationFileURL)

        // Supprimer l'image si présente
        if let metadata = offlineMetadata[formationId],
           let imageFileName = metadata.imageFileName {
            let imageFileURL = formationsDirectory.appendingPathComponent(imageFileName)
            try? fileManager.removeItem(at: imageFileURL)
        }

        // Mettre à jour les stats
        if let metadata = offlineMetadata[formationId] {
            totalStorageUsed -= metadata.fileSize
        }

        offlineFormationIds.remove(formationId)
        offlineMetadata.removeValue(forKey: formationId)
        downloadProgress.removeValue(forKey: formationId)

        saveMetadata()

        #if DEBUG
        print("[OfflineContent] Removed formation \(formationId) from offline storage")
        #endif
    }

    /// Télécharge toutes les formations favorites
    func downloadAllFavorites() async {
        let favoriteIds = FavoritesService.shared.favoriteFormationIds

        #if DEBUG
        print("[OfflineContent] downloadAllFavorites called - \(favoriteIds.count) favorites found")
        #endif

        if favoriteIds.isEmpty {
            #if DEBUG
            print("[OfflineContent] No favorites to download")
            #endif
            return
        }

        for formationId in favoriteIds {
            // Vérifier si déjà téléchargé
            guard !offlineFormationIds.contains(formationId) else {
                #if DEBUG
                print("[OfflineContent] Formation \(formationId) already downloaded, skipping")
                #endif
                continue
            }

            #if DEBUG
            print("[OfflineContent] Fetching formation \(formationId) details...")
            #endif

            // Récupérer les détails de la formation
            do {
                let formation = try await fetchFormationDetails(formationId: formationId)
                await downloadFormation(formation)
            } catch {
                #if DEBUG
                print("[OfflineContent] Failed to fetch formation \(formationId): \(error)")
                #endif
            }
        }
    }

    /// Charge une formation depuis le stockage hors-ligne
    func loadOfflineFormation(formationId: Int) -> Formation? {
        guard offlineFormationIds.contains(formationId) else { return nil }

        let formationFileURL = formationsDirectory.appendingPathComponent("\(formationId).json")

        guard let data = try? Data(contentsOf: formationFileURL),
              let formation = try? JSONDecoder().decode(Formation.self, from: data) else {
            return nil
        }

        return formation
    }

    /// Charge l'image d'une formation depuis le stockage hors-ligne
    func loadOfflineImage(formationId: Int) -> UIImage? {
        guard let metadata = offlineMetadata[formationId],
              let imageFileName = metadata.imageFileName else {
            return nil
        }

        let imageFileURL = formationsDirectory.appendingPathComponent(imageFileName)
        guard let data = try? Data(contentsOf: imageFileURL) else { return nil }

        return UIImage(data: data)
    }

    /// Supprime tout le contenu hors-ligne
    func clearAllOfflineContent() {
        try? fileManager.removeItem(at: formationsDirectory)
        createDirectoriesIfNeeded()

        offlineFormationIds.removeAll()
        offlineMetadata.removeAll()
        downloadProgress.removeAll()
        totalStorageUsed = 0

        saveMetadata()

        #if DEBUG
        print("[OfflineContent] Cleared all offline content")
        #endif
    }

    /// Retourne la liste des formations téléchargées avec leurs métadonnées
    func getDownloadedFormationsInfo() -> [(formationId: Int, downloadedAt: Date, fileSize: Int64)] {
        return offlineMetadata.values.map { ($0.formationId, $0.downloadedAt, $0.fileSize) }
            .sorted { $0.downloadedAt > $1.downloadedAt }
    }

    /// Formate la taille de stockage pour l'affichage
    func formattedStorageUsed() -> String {
        return ByteCountFormatter.string(fromByteCount: totalStorageUsed, countStyle: .file)
    }

    // MARK: - Private Methods

    private func createDirectoriesIfNeeded() {
        try? fileManager.createDirectory(at: offlineDirectory, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: formationsDirectory, withIntermediateDirectories: true)
    }

    private func loadMetadata() {
        guard let data = try? Data(contentsOf: metadataFileURL),
              let metadata = try? JSONDecoder().decode([OfflineFormationMetadata].self, from: data) else {
            offlineMetadata = [:]
            offlineFormationIds = []
            return
        }

        offlineMetadata = Dictionary(uniqueKeysWithValues: metadata.map { ($0.formationId, $0) })
        offlineFormationIds = Set(metadata.map { $0.formationId })

        #if DEBUG
        print("[OfflineContent] Loaded \(offlineFormationIds.count) offline formations")
        #endif
    }

    private func saveMetadata() {
        let metadataArray = Array(offlineMetadata.values)
        guard let data = try? JSONEncoder().encode(metadataArray) else { return }
        try? data.write(to: metadataFileURL)
    }

    private func calculateStorageUsed() {
        totalStorageUsed = offlineMetadata.values.reduce(0) { $0 + $1.fileSize }
    }

    private func fetchFormationDetails(formationId: Int) async throws -> Formation {
        // First, try to get from AppDataRepository (already loaded formations)
        let formations = await MainActor.run {
            AppDataRepository.shared.formations
        }

        if let formation = formations.first(where: { $0.id == formationId }) {
            #if DEBUG
            print("[OfflineContent] Found formation \(formationId) in AppDataRepository")
            #endif
            return formation
        }

        // If not found locally, try to fetch via favorites endpoint
        #if DEBUG
        print("[OfflineContent] Formation \(formationId) not in repository, trying favorites API...")
        #endif

        let savedFormations = try await FavoritesService.shared.fetchSavedFormations()
        if let formation = savedFormations.first(where: { $0.id == formationId }) {
            return formation
        }

        throw URLError(.resourceUnavailable)
    }
}
