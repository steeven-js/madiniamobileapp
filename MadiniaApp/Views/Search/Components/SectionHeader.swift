//
//  SectionHeader.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// Reusable section header with title and optional "Voir tout" button.
/// Used in SearchView for section navigation.
struct SectionHeader: View {
    /// Section title
    let title: String

    /// Optional action for "Voir tout" button
    var onViewAll: (() -> Void)?

    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(MadiniaTypography.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            Spacer()

            if let onViewAll {
                Button {
                    onViewAll()
                } label: {
                    HStack(spacing: MadiniaSpacing.xxs) {
                        Text("Voir tout")
                            .font(MadiniaTypography.subheadline)
                            .fontWeight(.medium)

                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundStyle(MadiniaColors.accent)
                }
                .accessibilityLabel("Voir tout \(title)")
            }
        }
        .padding(.horizontal, MadiniaSpacing.md)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: MadiniaSpacing.lg) {
        SectionHeader(title: "Nos Services") {
            print("View all services")
        }

        SectionHeader(title: "Nos Formations") {
            print("View all formations")
        }

        SectionHeader(title: "Catégories")
    }
}
