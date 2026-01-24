//
//  LoadingView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Reusable loading view component displaying a spinner with optional message.
/// Centers content vertically for use in various contexts.
struct LoadingView: View {
    /// Optional message to display below the spinner
    var message: String?

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .accessibilityLabel("Chargement en cours")

            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .accessibilityElement(children: .combine)
    }
}

#Preview("With Message") {
    LoadingView(message: "Chargement des formations...")
}

#Preview("Without Message") {
    LoadingView()
}
