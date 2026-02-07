//
//  OfflineContentSettingsView.swift
//  MadiniaApp
//
//  Vue de gestion du contenu téléchargé pour le mode hors-ligne.
//

import SwiftUI

/// Vue permettant de gérer le contenu téléchargé pour le mode hors-ligne.
struct OfflineContentSettingsView: View {

    // MARK: - Dependencies

    // Note: Use direct singleton access for @Observable services
    private let offlineService = OfflineContentService.shared
    private let networkService = NetworkMonitorService.shared
    private let favoritesService = FavoritesService.shared

    // MARK: - State

    @State private var showClearConfirmation = false
    @State private var downloadedFormations: [(formationId: Int, downloadedAt: Date, fileSize: Int64)] = []
    @State private var isDownloadingAll = false

    // MARK: - Body

    var body: some View {
        List {
            // Storage summary section
            storageSummarySection

            // Downloaded formations section
            if !downloadedFormations.isEmpty {
                downloadedFormationsSection
            }

            // Actions section
            actionsSection
        }
        .navigationTitle("Contenu hors ligne")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadDownloadedFormations()
            #if DEBUG
            print("[OfflineSettings] View appeared")
            print("[OfflineSettings] Network isConnected: \(networkService.isConnected)")
            print("[OfflineSettings] Network type: \(networkService.connectionType.rawValue)")
            print("[OfflineSettings] Favorites count: \(favoritesService.favoriteFormationIds.count)")
            print("[OfflineSettings] Favorites IDs: \(favoritesService.favoriteFormationIds)")
            print("[OfflineSettings] Offline formations: \(offlineService.offlineFormationIds)")
            #endif
        }
        .confirmationDialog(
            "Supprimer tout le contenu hors-ligne ?",
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Supprimer tout", role: .destructive) {
                offlineService.clearAllOfflineContent()
                loadDownloadedFormations()
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Toutes les formations téléchargées seront supprimées. Vous pourrez les retélécharger ultérieurement.")
        }
    }

    // MARK: - Storage Summary Section

    private var storageSummarySection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: MadiniaSpacing.xxs) {
                    Text("Espace utilisé")
                        .font(MadiniaTypography.headline)
                        .foregroundStyle(.primary)

                    Text(offlineService.formattedStorageUsed())
                        .font(MadiniaTypography.title)
                        .foregroundStyle(MadiniaColors.accent)
                }

                Spacer()

                // Storage icon
                ZStack {
                    Circle()
                        .fill(MadiniaColors.accent.opacity(0.1))
                        .frame(width: 56, height: 56)

                    Image(systemName: "internaldrive.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(MadiniaColors.accent)
                }
            }
            .padding(.vertical, MadiniaSpacing.xs)

            // Formations count
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundStyle(.secondary)

                Text("\(offlineService.offlineFormationIds.count) formation\(offlineService.offlineFormationIds.count > 1 ? "s" : "") téléchargée\(offlineService.offlineFormationIds.count > 1 ? "s" : "")")
                    .font(MadiniaTypography.body)
                    .foregroundStyle(.secondary)
            }

            // Network status indicator
            HStack {
                Image(systemName: networkService.isConnected ? "wifi" : "wifi.slash")
                    .foregroundStyle(networkService.isConnected ? .green : .orange)

                Text(networkService.isConnected ? "Connecté (\(networkService.connectionType.rawValue))" : "Mode hors ligne")
                    .font(MadiniaTypography.body)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Stockage")
        }
    }

    // MARK: - Downloaded Formations Section

    private var downloadedFormationsSection: some View {
        Section {
            ForEach(downloadedFormations, id: \.formationId) { item in
                DownloadedFormationRow(
                    formationId: item.formationId,
                    downloadedAt: item.downloadedAt,
                    fileSize: item.fileSize,
                    onDelete: {
                        offlineService.removeFormation(formationId: item.formationId)
                        loadDownloadedFormations()
                    }
                )
            }
        } header: {
            Text("Formations téléchargées")
        }
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        Section {
            // Favorites count info
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.pink)

                Text("\(favoritesService.favoriteFormationIds.count) favori(s) sauvegardé(s)")
                    .font(MadiniaTypography.body)
                    .foregroundStyle(.secondary)
            }

            // Download all favorites button
            Button {
                #if DEBUG
                print("[OfflineSettings] Button tapped!")
                print("[OfflineSettings] Favorites count: \(favoritesService.favoriteFormationIds.count)")
                print("[OfflineSettings] Network connected: \(networkService.isConnected)")
                print("[OfflineSettings] Is downloading: \(offlineService.isDownloading)")
                #endif

                isDownloadingAll = true
                Task {
                    await offlineService.downloadAllFavorites()
                    await MainActor.run {
                        loadDownloadedFormations()
                        isDownloadingAll = false
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.down.circle")
                        .foregroundStyle(MadiniaColors.accent)

                    Text("Télécharger tous les favoris")
                        .foregroundStyle(.primary)

                    Spacer()

                    if isDownloadingAll || offlineService.isDownloading {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
            }
            .disabled(isDownloadingAll || offlineService.isDownloading)

            // Clear all button
            if !downloadedFormations.isEmpty {
                Button(role: .destructive) {
                    showClearConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash")

                        Text("Supprimer tout le contenu")

                        Spacer()
                    }
                }
            }
        } header: {
            Text("Actions")
        } footer: {
            Text("Le contenu téléchargé reste disponible même sans connexion internet. Il sera automatiquement mis à jour lorsque vous êtes en ligne.")
        }
    }

    // MARK: - Helper Methods

    private func loadDownloadedFormations() {
        downloadedFormations = offlineService.getDownloadedFormationsInfo()
    }
}

// MARK: - Downloaded Formation Row

/// Ligne affichant une formation téléchargée avec option de suppression.
struct DownloadedFormationRow: View {
    let formationId: Int
    let downloadedAt: Date
    let fileSize: Int64
    let onDelete: () -> Void

    @State private var formationTitle: String = "Formation #"
    @State private var showDeleteConfirmation = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: MadiniaSpacing.xxs) {
                Text(formationTitle)
                    .font(MadiniaTypography.body)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: MadiniaSpacing.sm) {
                    Text(formattedFileSize)
                        .font(MadiniaTypography.caption)
                        .foregroundStyle(.secondary)

                    Text("•")
                        .foregroundStyle(.secondary)

                    Text(formattedDate)
                        .font(MadiniaTypography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Delete button
            Button {
                showDeleteConfirmation = true
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .onAppear {
            loadFormationTitle()
        }
        .confirmationDialog(
            "Supprimer cette formation ?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Supprimer", role: .destructive) {
                onDelete()
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Cette formation ne sera plus disponible hors-ligne.")
        }
    }

    private var formattedFileSize: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }

    private var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: downloadedAt, relativeTo: Date())
    }

    private func loadFormationTitle() {
        if let formation = OfflineContentService.shared.loadOfflineFormation(formationId: formationId) {
            formationTitle = formation.title
        } else {
            formationTitle = "Formation #\(formationId)"
        }
    }
}

// MARK: - Preview

#Preview("Offline Content Settings") {
    NavigationStack {
        OfflineContentSettingsView()
    }
}

#Preview("Empty State") {
    NavigationStack {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Espace utilisé")
                            .font(MadiniaTypography.headline)

                        Text("0 Ko")
                            .font(MadiniaTypography.title)
                            .foregroundStyle(MadiniaColors.accent)
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(MadiniaColors.accent.opacity(0.1))
                            .frame(width: 56, height: 56)

                        Image(systemName: "internaldrive.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(MadiniaColors.accent)
                    }
                }

                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundStyle(.secondary)
                    Text("0 formation téléchargée")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Image(systemName: "wifi")
                        .foregroundStyle(.green)
                    Text("Connecté (Wi-Fi)")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Stockage")
            }

            Section {
                HStack {
                    Image(systemName: "arrow.down.circle")
                        .foregroundStyle(MadiniaColors.accent)
                    Text("Télécharger tous les favoris")
                }
            } header: {
                Text("Actions")
            } footer: {
                Text("Le contenu téléchargé reste disponible même sans connexion internet.")
            }
        }
        .navigationTitle("Contenu hors ligne")
    }
}
