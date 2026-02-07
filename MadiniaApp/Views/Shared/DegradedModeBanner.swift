//
//  DegradedModeBanner.swift
//  MadiniaApp
//
//  Bannière affichée lorsque l'app fonctionne en mode dégradé.
//

import SwiftUI

/// Bannière indiquant le mode dégradé de l'application
struct DegradedModeBanner: View {
    private let errorService = ErrorHandlingService.shared
    private let networkService = NetworkMonitorService.shared

    @State private var isExpanded = false

    var body: some View {
        if shouldShowBanner {
            VStack(spacing: 0) {
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
            .animation(.spring(response: 0.3), value: isExpanded)
        }
    }

    // MARK: - Computed Properties

    private var shouldShowBanner: Bool {
        switch errorService.healthState {
        case .degraded, .offline, .error:
            return true
        case .healthy:
            return false
        }
    }

    private var bannerColor: Color {
        switch errorService.healthState {
        case .healthy: return .green
        case .degraded: return .orange
        case .offline: return .gray
        case .error: return .red
        }
    }

    private var bannerIcon: String {
        errorService.healthState.icon
    }

    private var bannerMessage: String {
        switch errorService.healthState {
        case .healthy:
            return "Connecté"
        case .degraded:
            return "Mode dégradé - Données en cache"
        case .offline:
            return "Mode hors ligne"
        case .error(let msg):
            return msg
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
}

// MARK: - Preview

#Preview("Degraded Mode Banner") {
    VStack {
        DegradedModeBanner()
        Spacer()
    }
}
