//
//  ErrorView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Reusable error view component displaying an error message with retry option.
/// Supports contextual messages, automatic retry progress, and degraded mode indication.
struct ErrorView: View {
    /// Error message to display
    let message: String

    /// Optional error context for icon
    var context: ErrorContext?

    /// Action to perform when retry button is tapped
    var onRetry: (() -> Void)?

    /// Whether to show compact version
    var isCompact: Bool = false

    /// Error handling service for retry state
    private let errorService = ErrorHandlingService.shared

    var body: some View {
        if isCompact {
            compactView
        } else {
            fullView
        }
    }

    // MARK: - Full View

    private var fullView: some View {
        VStack(spacing: MadiniaSpacing.lg) {
            // Error icon with animation
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: context?.icon ?? "exclamationmark.triangle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.orange)
                    .symbolEffect(.pulse, options: .repeating, isActive: errorService.retryState.isActive)
            }
            .accessibilityHidden(true)

            // Error message
            VStack(spacing: MadiniaSpacing.xs) {
                Text(message)
                    .font(MadiniaTypography.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                // Retry status
                if errorService.retryState.isActive {
                    Text(errorService.retryState.statusMessage)
                        .font(MadiniaTypography.caption)
                        .foregroundStyle(MadiniaColors.accent)
                        .transition(.opacity.combined(with: .scale))
                }

                // Degraded mode indicator
                if errorService.isDegradedMode {
                    degradedModeIndicator
                }
            }
            .padding(.horizontal, MadiniaSpacing.lg)

            // Action buttons
            if let onRetry = onRetry {
                retryButton(action: onRetry)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .animation(.easeInOut(duration: 0.3), value: errorService.retryState)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Erreur: \(message)")
    }

    // MARK: - Compact View

    private var compactView: some View {
        HStack(spacing: MadiniaSpacing.sm) {
            Image(systemName: context?.icon ?? "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text(message)
                    .font(MadiniaTypography.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                if errorService.retryState.isActive {
                    Text(errorService.retryState.statusMessage)
                        .font(MadiniaTypography.caption)
                        .foregroundStyle(MadiniaColors.accent)
                }
            }

            Spacer()

            if let onRetry = onRetry, !errorService.retryState.isActive {
                Button {
                    HapticManager.tap()
                    onRetry()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.body)
                        .foregroundStyle(MadiniaColors.accent)
                }
            } else if errorService.retryState.isActive {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(MadiniaSpacing.md)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
    }

    // MARK: - Subviews

    private var degradedModeIndicator: some View {
        HStack(spacing: MadiniaSpacing.xxs) {
            Image(systemName: "info.circle.fill")
                .font(.caption)
            Text("Données en cache affichées")
                .font(MadiniaTypography.caption)
        }
        .foregroundStyle(.secondary)
        .padding(.top, MadiniaSpacing.xs)
    }

    private func retryButton(action: @escaping () -> Void) -> some View {
        Button {
            HapticManager.tap()
            action()
        } label: {
            HStack(spacing: MadiniaSpacing.xs) {
                if errorService.retryState.isActive {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.clockwise")
                }
                Text(errorService.retryState.isActive ? "Connexion en cours..." : "Réessayer")
            }
            .font(MadiniaTypography.body)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, MadiniaSpacing.lg)
            .padding(.vertical, MadiniaSpacing.sm)
            .background(errorService.retryState.isActive ? Color.gray : MadiniaColors.accent)
            .clipShape(Capsule())
        }
        .disabled(errorService.retryState.isActive)
        .animation(.easeInOut, value: errorService.retryState.isActive)
    }
}

// MARK: - Contextual Error View

/// Error view with automatic context-based messaging
struct ContextualErrorView: View {
    let error: APIError
    let context: ErrorContext
    var onRetry: (() async -> Void)?

    @State private var isRetrying = false

    var body: some View {
        ErrorView(
            message: context.errorMessage(for: error),
            context: context,
            onRetry: onRetry != nil ? {
                guard !isRetrying else { return }
                isRetrying = true
                Task {
                    await onRetry?()
                    isRetrying = false
                }
            } : nil
        )
    }
}

// MARK: - Inline Error Banner

/// Compact error banner for inline display
struct ErrorBanner: View {
    let message: String
    var onRetry: (() -> Void)?
    var onDismiss: (() -> Void)?

    var body: some View {
        HStack(spacing: MadiniaSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)

            Text(message)
                .font(MadiniaTypography.caption)
                .foregroundStyle(.primary)
                .lineLimit(2)

            Spacer()

            if let onRetry = onRetry {
                Button {
                    HapticManager.tap()
                    onRetry()
                } label: {
                    Text("Réessayer")
                        .font(MadiniaTypography.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(MadiniaColors.accent)
                }
            }

            if let onDismiss = onDismiss {
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(MadiniaSpacing.sm)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.sm))
    }
}

// MARK: - Health Status Indicator

/// Small indicator showing app health state
struct HealthStatusIndicator: View {
    private let errorService = ErrorHandlingService.shared

    var body: some View {
        HStack(spacing: MadiniaSpacing.xxs) {
            Circle()
                .fill(errorService.healthState.color)
                .frame(width: 8, height: 8)

            Text(errorService.healthState.message)
                .font(MadiniaTypography.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, MadiniaSpacing.sm)
        .padding(.vertical, MadiniaSpacing.xxs)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}

// MARK: - Previews

#Preview("Full Error View") {
    ErrorView(
        message: "Erreur de connexion. Vérifiez votre connexion internet.",
        context: .loadingFormations,
        onRetry: { print("Retry tapped") }
    )
    .padding()
}

#Preview("Compact Error View") {
    ErrorView(
        message: "Impossible de charger les formations.",
        context: .loadingFormations,
        onRetry: { print("Retry tapped") },
        isCompact: true
    )
    .padding()
}

#Preview("Error Banner") {
    VStack(spacing: 16) {
        ErrorBanner(
            message: "Synchronisation échouée",
            onRetry: { print("Retry") },
            onDismiss: { print("Dismiss") }
        )

        ErrorBanner(
            message: "Mode hors ligne activé",
            onDismiss: { print("Dismiss") }
        )
    }
    .padding()
}

#Preview("Health Indicator") {
    VStack(spacing: 16) {
        HealthStatusIndicator()
    }
    .padding()
}
