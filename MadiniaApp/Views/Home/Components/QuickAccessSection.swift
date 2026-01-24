//
//  QuickAccessSection.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Quick access section with buttons to navigate to key app sections.
/// Displayed on the Home screen below the highlights.
struct QuickAccessSection: View {
    /// Action for "Voir toutes les formations" button
    var onFormationsTap: (() -> Void)?

    /// Action for "Lire le blog" button
    var onBlogTap: (() -> Void)?

    /// Action for "Nous contacter" button
    var onContactTap: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Accès rapide")
                .font(.title2)
                .fontWeight(.bold)

            VStack(spacing: 12) {
                // Formations button
                quickAccessButton(
                    title: "Voir toutes les formations",
                    icon: "book.fill",
                    action: onFormationsTap
                )

                // Blog button
                quickAccessButton(
                    title: "Lire le blog",
                    icon: "doc.text.fill",
                    action: onBlogTap
                )

                // Contact button
                quickAccessButton(
                    title: "Nous contacter",
                    icon: "envelope.fill",
                    action: onContactTap
                )
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Subviews

    private func quickAccessButton(
        title: String,
        icon: String,
        action: (() -> Void)?
    ) -> some View {
        Button {
            action?()
        } label: {
            HStack {
                Image(systemName: icon)
                    .font(.body)
                Text(title)
                    .font(.body)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .accessibilityLabel(title)
    }
}

#Preview {
    QuickAccessSection(
        onFormationsTap: { print("Formations tapped") },
        onBlogTap: { print("Blog tapped") },
        onContactTap: { print("Contact tapped") }
    )
    .padding()
}
