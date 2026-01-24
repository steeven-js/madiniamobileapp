//
//  ErrorView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Reusable error view component displaying an error message with retry option.
/// All strings are in French as per architecture requirements.
struct ErrorView: View {
    /// Error message to display
    let message: String

    /// Action to perform when retry button is tapped
    var onRetry: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            // Error icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
                .accessibilityHidden(true)

            // Error message
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Retry button
            if let onRetry = onRetry {
                Button {
                    onRetry()
                } label: {
                    Label("Réessayer", systemImage: "arrow.clockwise")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Réessayer le chargement")
            }
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Erreur: \(message)")
    }
}

#Preview("With Retry") {
    ErrorView(
        message: "Erreur de connexion. Vérifiez votre connexion internet.",
        onRetry: { print("Retry tapped") }
    )
}

#Preview("Without Retry") {
    ErrorView(message: "Une erreur est survenue.")
}
