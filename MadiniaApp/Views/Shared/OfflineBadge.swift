//
//  OfflineBadge.swift
//  MadiniaApp
//
//  Badge indiquant qu'une formation est disponible hors-ligne.
//  Affiche un anneau de progression pendant le téléchargement.
//

import SwiftUI

/// Badge indiquant la disponibilité hors-ligne d'une formation.
struct OfflineBadge: View {

    // MARK: - Properties

    let formationId: Int

    // MARK: - Dependencies

    private var offlineService: OfflineContentService { OfflineContentService.shared }

    // MARK: - Computed Properties

    private var isAvailableOffline: Bool {
        offlineService.isAvailableOffline(formationId: formationId)
    }

    private var downloadProgress: DownloadProgress? {
        offlineService.downloadProgress[formationId]
    }

    private var isDownloading: Bool {
        if let progress = downloadProgress {
            return progress.status == .downloading || progress.status == .pending
        }
        return false
    }

    // MARK: - Body

    var body: some View {
        Group {
            if isDownloading, let progress = downloadProgress {
                downloadingBadge(progress: progress.progress)
            } else if isAvailableOffline {
                availableBadge
            }
        }
    }

    // MARK: - Available Badge

    private var availableBadge: some View {
        Image(systemName: "arrow.down.circle.fill")
            .font(.system(size: 20))
            .foregroundStyle(MadiniaColors.violetFixed)
            .background(
                Circle()
                    .fill(.white)
                    .frame(width: 18, height: 18)
            )
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
    }

    // MARK: - Downloading Badge

    private func downloadingBadge(progress: Double) -> some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(lineWidth: 2)
                .foregroundStyle(.white.opacity(0.3))

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .foregroundStyle(MadiniaColors.violetFixed)
                .rotationEffect(.degrees(-90))

            // Center icon
            Image(systemName: "arrow.down")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(MadiniaColors.violetFixed)
        }
        .frame(width: 20, height: 20)
        .background(
            Circle()
                .fill(.white)
                .frame(width: 22, height: 22)
        )
        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}

// MARK: - View Modifier

/// Modificateur de vue pour ajouter facilement le badge offline.
struct OfflineBadgeModifier: ViewModifier {
    let formationId: Int

    func body(content: Content) -> some View {
        content.overlay(alignment: .topLeading) {
            OfflineBadge(formationId: formationId)
                .padding(MadiniaSpacing.xs)
        }
    }
}

extension View {
    /// Ajoute un badge offline à la vue si la formation est disponible hors-ligne.
    func offlineBadge(formationId: Int) -> some View {
        modifier(OfflineBadgeModifier(formationId: formationId))
    }
}

// MARK: - Preview

#Preview("Offline Badge - Available") {
    VStack(spacing: 20) {
        // Simulated available badge
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(MadiniaColors.placeholderGradient)
                .frame(width: 170, height: 120)

            VStack {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(MadiniaColors.violetFixed)
                        .background(
                            Circle()
                                .fill(.white)
                                .frame(width: 18, height: 18)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        .padding(8)
                    Spacer()
                }
                Spacer()
            }
        }

        Text("Formation disponible hors-ligne")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
    .padding()
}

#Preview("Offline Badge - Downloading") {
    VStack(spacing: 20) {
        // Simulated downloading badge at 60%
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(MadiniaColors.placeholderGradient)
                .frame(width: 170, height: 120)

            VStack {
                HStack {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 2)
                            .foregroundStyle(.white.opacity(0.3))

                        Circle()
                            .trim(from: 0, to: 0.6)
                            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .foregroundStyle(MadiniaColors.violetFixed)
                            .rotationEffect(.degrees(-90))

                        Image(systemName: "arrow.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(MadiniaColors.violetFixed)
                    }
                    .frame(width: 20, height: 20)
                    .background(
                        Circle()
                            .fill(.white)
                            .frame(width: 22, height: 22)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    .padding(8)

                    Spacer()
                }
                Spacer()
            }
        }

        Text("Téléchargement en cours (60%)")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
    .padding()
}
