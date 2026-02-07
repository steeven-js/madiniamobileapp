//
//  OfflineDownloadButton.swift
//  MadiniaApp
//
//  Bouton de téléchargement pour le mode hors-ligne dans les vues de détail.
//

import SwiftUI

/// Bouton permettant de télécharger une formation pour une lecture hors-ligne.
struct OfflineDownloadButton: View {

    // MARK: - Properties

    let formation: Formation

    // MARK: - Dependencies

    private var offlineService: OfflineContentService { OfflineContentService.shared }
    private var networkService: NetworkMonitorService { NetworkMonitorService.shared }

    // MARK: - State

    @State private var showDeleteConfirmation = false

    // MARK: - Computed Properties

    private var isAvailableOffline: Bool {
        offlineService.isAvailableOffline(formationId: formation.id)
    }

    private var downloadProgress: DownloadProgress? {
        offlineService.downloadProgress[formation.id]
    }

    private var isDownloading: Bool {
        if let progress = downloadProgress {
            return progress.status == .downloading || progress.status == .pending
        }
        return false
    }

    // MARK: - Body

    var body: some View {
        Button {
            handleTap()
        } label: {
            buttonContent
        }
        .disabled(isDownloading || !networkService.isConnected && !isAvailableOffline)
        .confirmationDialog(
            "Supprimer le contenu hors-ligne",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Supprimer", role: .destructive) {
                offlineService.removeFormation(formationId: formation.id)
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Cette formation ne sera plus disponible hors-ligne.")
        }
    }

    // MARK: - Button Content

    @ViewBuilder
    private var buttonContent: some View {
        HStack(spacing: MadiniaSpacing.xs) {
            if isDownloading, let progress = downloadProgress {
                // Downloading state
                ZStack {
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundStyle(MadiniaColors.violet.opacity(0.3))

                    Circle()
                        .trim(from: 0, to: progress.progress)
                        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .foregroundStyle(MadiniaColors.violet)
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 16, height: 16)

                Text("\(Int(progress.progress * 100))%")
                    .font(MadiniaTypography.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(MadiniaColors.violet)

            } else if isAvailableOffline {
                // Available offline state
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.green)

                Text("Disponible hors ligne")
                    .font(MadiniaTypography.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.green)

            } else {
                // Download available state
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 16))
                    .foregroundStyle(networkService.isConnected ? MadiniaColors.violet : .gray)

                Text("Télécharger")
                    .font(MadiniaTypography.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(networkService.isConnected ? MadiniaColors.violet : .gray)
            }
        }
        .padding(.horizontal, MadiniaSpacing.sm)
        .padding(.vertical, MadiniaSpacing.xs)
        .background(backgroundColor)
        .clipShape(Capsule())
    }

    // MARK: - Background Color

    private var backgroundColor: Color {
        if isDownloading {
            return MadiniaColors.violet.opacity(0.1)
        } else if isAvailableOffline {
            return Color.green.opacity(0.1)
        } else {
            return networkService.isConnected ? MadiniaColors.violet.opacity(0.1) : Color.gray.opacity(0.1)
        }
    }

    // MARK: - Actions

    private func handleTap() {
        if isAvailableOffline {
            showDeleteConfirmation = true
        } else if !isDownloading && networkService.isConnected {
            Task {
                await offlineService.downloadFormation(formation)
            }
        }
    }
}

// MARK: - Compact Version

/// Version compacte du bouton de téléchargement (icône uniquement)
struct OfflineDownloadButtonCompact: View {

    let formation: Formation

    private var offlineService: OfflineContentService { OfflineContentService.shared }
    private var networkService: NetworkMonitorService { NetworkMonitorService.shared }

    @State private var showDeleteConfirmation = false

    private var isAvailableOffline: Bool {
        offlineService.isAvailableOffline(formationId: formation.id)
    }

    private var downloadProgress: DownloadProgress? {
        offlineService.downloadProgress[formation.id]
    }

    private var isDownloading: Bool {
        if let progress = downloadProgress {
            return progress.status == .downloading || progress.status == .pending
        }
        return false
    }

    var body: some View {
        Button {
            handleTap()
        } label: {
            ZStack {
                if isDownloading, let progress = downloadProgress {
                    // Progress ring
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundStyle(.white.opacity(0.3))

                    Circle()
                        .trim(from: 0, to: progress.progress)
                        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(-90))

                    Image(systemName: "arrow.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)

                } else if isAvailableOffline {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)

                } else {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(networkService.isConnected ? 0.8 : 0.4))
                }
            }
            .frame(width: 32, height: 32)
        }
        .disabled(isDownloading || !networkService.isConnected && !isAvailableOffline)
        .confirmationDialog(
            "Supprimer le contenu hors-ligne",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Supprimer", role: .destructive) {
                offlineService.removeFormation(formationId: formation.id)
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Cette formation ne sera plus disponible hors-ligne.")
        }
    }

    private func handleTap() {
        if isAvailableOffline {
            showDeleteConfirmation = true
        } else if !isDownloading && networkService.isConnected {
            Task {
                await offlineService.downloadFormation(formation)
            }
        }
    }
}

// MARK: - Preview

#Preview("Download Button States") {
    VStack(spacing: 24) {
        // Download available
        HStack(spacing: MadiniaSpacing.xs) {
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 16))
                .foregroundStyle(MadiniaColors.violet)

            Text("Télécharger")
                .font(MadiniaTypography.caption)
                .fontWeight(.medium)
                .foregroundStyle(MadiniaColors.violet)
        }
        .padding(.horizontal, MadiniaSpacing.sm)
        .padding(.vertical, MadiniaSpacing.xs)
        .background(MadiniaColors.violet.opacity(0.1))
        .clipShape(Capsule())

        // Downloading
        HStack(spacing: MadiniaSpacing.xs) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 2)
                    .foregroundStyle(MadiniaColors.violet.opacity(0.3))

                Circle()
                    .trim(from: 0, to: 0.65)
                    .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .foregroundStyle(MadiniaColors.violet)
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 16, height: 16)

            Text("65%")
                .font(MadiniaTypography.caption)
                .fontWeight(.medium)
                .foregroundStyle(MadiniaColors.violet)
        }
        .padding(.horizontal, MadiniaSpacing.sm)
        .padding(.vertical, MadiniaSpacing.xs)
        .background(MadiniaColors.violet.opacity(0.1))
        .clipShape(Capsule())

        // Available offline
        HStack(spacing: MadiniaSpacing.xs) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(.green)

            Text("Disponible hors ligne")
                .font(MadiniaTypography.caption)
                .fontWeight(.medium)
                .foregroundStyle(.green)
        }
        .padding(.horizontal, MadiniaSpacing.sm)
        .padding(.vertical, MadiniaSpacing.xs)
        .background(Color.green.opacity(0.1))
        .clipShape(Capsule())

        // Disabled (offline, not downloaded)
        HStack(spacing: MadiniaSpacing.xs) {
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 16))
                .foregroundStyle(.gray)

            Text("Télécharger")
                .font(MadiniaTypography.caption)
                .fontWeight(.medium)
                .foregroundStyle(.gray)
        }
        .padding(.horizontal, MadiniaSpacing.sm)
        .padding(.vertical, MadiniaSpacing.xs)
        .background(Color.gray.opacity(0.1))
        .clipShape(Capsule())
    }
    .padding()
}
