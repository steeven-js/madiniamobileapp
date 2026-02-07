//
//  DegradedModeBanner.swift
//  MadiniaApp
//
//  Bannière affichée lorsque l'app fonctionne en mode dégradé ou avec des opérations en attente.
//

import SwiftUI

/// Mode d'affichage de la bannière
private enum BannerMode: Equatable {
    case degraded       // Mode dégradé (API indisponible)
    case offline        // Mode hors ligne
    case error(String)  // Erreur
    case syncPending    // Opérations en attente de sync
    case none           // Rien à afficher
}

/// Bannière indiquant le mode dégradé de l'application ou les opérations en attente
struct DegradedModeBanner: View {
    private let errorService = ErrorHandlingService.shared
    private let networkService = NetworkMonitorService.shared
    private let syncService = SyncQueueService.shared

    @State private var isExpanded = false

    var body: some View {
        if currentMode != .none {
            VStack(spacing: 0) {
                if case .syncPending = currentMode {
                    syncPendingBanner
                } else {
                    bannerContent
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                isExpanded.toggle()
                            }
                            HapticManager.selection()
                        }

                    if isExpanded {
                        expandedContent
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .animation(.spring(response: 0.3), value: isExpanded)
            .animation(.spring(response: 0.3), value: syncService.pendingCount)
        }
    }

    // MARK: - Computed Properties

    private var currentMode: BannerMode {
        // First check health state
        switch errorService.healthState {
        case .degraded:
            return .degraded
        case .offline:
            return .offline
        case .error(let msg):
            return .error(msg)
        case .healthy:
            // If healthy, check for pending sync operations
            if syncService.pendingCount > 0 {
                return .syncPending
            }
            return .none
        }
    }

    private var shouldShowBanner: Bool {
        currentMode != .none
    }

    private var bannerColor: Color {
        switch currentMode {
        case .degraded: return .orange
        case .offline: return .gray
        case .error: return .red
        case .syncPending: return MadiniaColors.violetFixed
        case .none: return .green
        }
    }

    private var bannerIcon: String {
        switch currentMode {
        case .degraded: return "exclamationmark.triangle.fill"
        case .offline: return "wifi.slash"
        case .error: return "xmark.circle.fill"
        case .syncPending: return "arrow.triangle.2.circlepath"
        case .none: return "checkmark.circle.fill"
        }
    }

    private var bannerMessage: String {
        switch currentMode {
        case .degraded:
            return "Mode dégradé - Données en cache"
        case .offline:
            return "Mode hors ligne"
        case .error(let msg):
            return msg
        case .syncPending:
            let count = syncService.pendingCount
            return "\(count) opération\(count > 1 ? "s" : "") en attente"
        case .none:
            return "Connecté"
        }
    }

    // MARK: - Subviews

    private var bannerContent: some View {
        HStack(spacing: MadiniaSpacing.sm) {
            Image(systemName: bannerIcon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)

            Text(bannerMessage)
                .font(MadiniaTypography.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white)

            Spacer()

            // Retry indicator or chevron
            if errorService.retryState.isActive {
                ProgressView()
                    .scaleEffect(0.7)
                    .tint(.white)
            } else {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, MadiniaSpacing.md)
        .padding(.vertical, MadiniaSpacing.sm)
        .background(bannerColor)
    }

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            // Status details
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    statusRow(
                        icon: "wifi",
                        label: "Réseau",
                        value: networkService.isConnected ? networkService.connectionType.rawValue : "Déconnecté",
                        isOK: networkService.isConnected
                    )

                    if errorService.isDegradedMode {
                        statusRow(
                            icon: "server.rack",
                            label: "API",
                            value: "Indisponible",
                            isOK: false
                        )
                    }
                }

                Spacer()

                // Retry button
                if !errorService.retryState.isActive && networkService.isConnected {
                    Button {
                        HapticManager.tap()
                        Task {
                            await AppDataRepository.shared.refresh()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                            Text("Réessayer")
                        }
                        .font(MadiniaTypography.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, MadiniaSpacing.sm)
                        .padding(.vertical, MadiniaSpacing.xs)
                        .background(bannerColor.opacity(0.8))
                        .clipShape(Capsule())
                    }
                }
            }

            // Retry status
            if errorService.retryState.isActive {
                Text(errorService.retryState.statusMessage)
                    .font(MadiniaTypography.caption)
                    .foregroundStyle(.secondary)
            }

            // Info text
            Text("Les données affichées proviennent du cache local et peuvent ne pas être à jour.")
                .font(MadiniaTypography.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(MadiniaSpacing.md)
        .background(Color(.secondarySystemBackground))
    }

    private func statusRow(icon: String, label: String, value: String, isOK: Bool) -> some View {
        HStack(spacing: MadiniaSpacing.xs) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(isOK ? .green : .orange)
                .frame(width: 16)

            Text(label)
                .font(MadiniaTypography.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(MadiniaTypography.caption)
                .fontWeight(.medium)
                .foregroundStyle(isOK ? Color.primary : Color.orange)
        }
    }

    // MARK: - Sync Pending Banner

    private var syncPendingBanner: some View {
        HStack(spacing: MadiniaSpacing.sm) {
            if syncService.isSyncing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
            } else {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text(syncService.isSyncing ? "Synchronisation..." : bannerMessage)
                .font(MadiniaTypography.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white)

            Spacer()

            if !syncService.isSyncing {
                Button {
                    HapticManager.tap()
                    Task {
                        await syncService.syncPendingOperations()
                    }
                } label: {
                    Text("Sync")
                        .font(MadiniaTypography.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, MadiniaSpacing.sm)
                        .padding(.vertical, MadiniaSpacing.xxs)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, MadiniaSpacing.md)
        .padding(.vertical, MadiniaSpacing.sm)
        .background(MadiniaColors.violetFixed)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Preview

#Preview("Degraded Mode Banner") {
    VStack {
        DegradedModeBanner()
        Spacer()
    }
}
