//
//  TopRatedSection.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// Section displaying most viewed formations on the Home screen.
/// Shows vertical list of TopRatedCard components.
struct TopRatedSection: View {
    /// Formations to display (top 5 most viewed)
    let formations: [Formation]

    /// Action when "View all" is tapped
    var onViewAllTap: (() -> Void)?

    /// Action when a formation is tapped
    var onFormationTap: ((Formation) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            // Header row
            headerRow

            // Formation cards (max 5 most viewed)
            VStack(spacing: MadiniaSpacing.sm) {
                ForEach(formations.prefix(5)) { formation in
                    TopRatedCard(formation: formation) {
                        onFormationTap?(formation)
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    private var headerRow: some View {
        HStack {
            Text("Les plus consultées")
                .font(MadiniaTypography.title2)
                .fontWeight(.bold)

            Spacer()

            Button {
                onViewAllTap?()
            } label: {
                HStack(spacing: MadiniaSpacing.xxs) {
                    Text("Voir tout")
                        .font(MadiniaTypography.subheadline)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .foregroundStyle(MadiniaColors.gold)
            }
            .accessibilityLabel("Voir toutes les formations")
        }
    }
}

// MARK: - Preview

#Preview("Top Rated Section") {
    ScrollView {
        TopRatedSection(
            formations: Formation.samples,
            onViewAllTap: { print("View all tapped") },
            onFormationTap: { print("Formation tapped: \($0.title)") }
        )
        .padding(.horizontal, MadiniaSpacing.md)
    }
}

#Preview("Empty State") {
    TopRatedSection(formations: [])
        .padding(.horizontal, MadiniaSpacing.md)
}
