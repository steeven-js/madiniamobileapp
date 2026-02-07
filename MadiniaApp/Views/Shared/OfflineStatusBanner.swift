//
//  OfflineStatusBanner.swift
//  MadiniaApp
//
//  Bannière globale affichant l'état de connectivité et les opérations en attente.
//

import SwiftUI

/// Bannière affichant l'état hors-ligne et les opérations de synchronisation en attente.
struct OfflineStatusBanner: View {

    // MARK: - Dependencies

    private var networkService: NetworkMonitorService { NetworkMonitorService.shared }
    private var syncService: SyncQueueService { SyncQueueService.shared }

    // MARK: - State

    @State private var isExpanded = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            if !networkService.isConnected {
                offlineBanner
            } else if syncService.pendingCount > 0 {
                syncPendingBanner
            }
        }
    }

    // MARK: - Offline Banner

    private var offlineBanner: some View {
        HStack(spacing: MadiniaSpacing.sm) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 16, weight: .semibold))

            Text("Mode hors ligne")
                .font(MadiniaTypography.subheadline)
                .fontWeight(.medium)

            Spacer()

            if OfflineContentService.shared.offlineFormationIds.count > 0 {
                Text("\(OfflineContentService.shared.offlineFormationIds.count) formations disponibles")
                    .font(MadiniaTypography.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, MadiniaSpacing.md)
        .padding(.vertical, MadiniaSpacing.sm)
        .background(Color.orange)
        .transition(.move(edge: .top).combined(with: .opacity))
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
                    .font(.system(size: 16, weight: .semibold))
            }

            Text(syncService.isSyncing ? "Synchronisation..." : "\(syncService.pendingCount) opération\(syncService.pendingCount > 1 ? "s" : "") en attente")
                .font(MadiniaTypography.subheadline)
                .fontWeight(.medium)

            Spacer()

            if !syncService.isSyncing {
                Button {
                    Task {
                        await syncService.syncPendingOperations()
                    }
                } label: {
                    Text("Sync")
                        .font(MadiniaTypography.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, MadiniaSpacing.sm)
                        .padding(.vertical, MadiniaSpacing.xxs)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, MadiniaSpacing.md)
        .padding(.vertical, MadiniaSpacing.sm)
        .background(MadiniaColors.violetFixed)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Preview

#Preview("Offline Banner") {
    VStack(spacing: 0) {
        // Simulated offline banner
        HStack(spacing: MadiniaSpacing.sm) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 16, weight: .semibold))

            Text("Mode hors ligne")
                .font(MadiniaTypography.subheadline)
                .fontWeight(.medium)

            Spacer()

            Text("3 formations disponibles")
                .font(MadiniaTypography.caption)
                .foregroundStyle(.white.opacity(0.8))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, MadiniaSpacing.md)
        .padding(.vertical, MadiniaSpacing.sm)
        .background(Color.orange)

        Spacer()
    }
}

#Preview("Sync Pending Banner") {
    VStack(spacing: 0) {
        // Simulated sync pending banner
        HStack(spacing: MadiniaSpacing.sm) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 16, weight: .semibold))

            Text("2 opérations en attente")
                .font(MadiniaTypography.subheadline)
                .fontWeight(.medium)

            Spacer()

            Text("Sync")
                .font(MadiniaTypography.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, MadiniaSpacing.sm)
                .padding(.vertical, MadiniaSpacing.xxs)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())
        }
        .foregroundStyle(.white)
        .padding(.horizontal, MadiniaSpacing.md)
        .padding(.vertical, MadiniaSpacing.sm)
        .background(MadiniaColors.violetFixed)

        Spacer()
    }
}
