//
//  CategoriesSection.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// Section displaying categories in a horizontal scroll on the Home screen.
/// Includes header with "View all" link and category cards.
struct CategoriesSection: View {
    /// Categories to display
    let categories: [FormationCategory]

    /// Action when "View all" is tapped
    var onViewAllTap: (() -> Void)?

    /// Action when a category is tapped
    var onCategoryTap: ((FormationCategory) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            // Header row
            headerRow

            // Horizontal scroll of category cards
            if categories.isEmpty {
                emptyState
            } else {
                categoryScroll
            }
        }
    }

    // MARK: - Subviews

    private var headerRow: some View {
        HStack {
            Text("Catégories")
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
            .accessibilityLabel("Voir toutes les catégories")
        }
    }

    private var categoryScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MadiniaSpacing.sm) {
                ForEach(categories, id: \.id) { category in
                    CategoryCard(category: category) {
                        onCategoryTap?(category)
                    }
                }
            }
            .padding(.horizontal, MadiniaSpacing.xxs) // For shadow visibility
        }
        .padding(.horizontal, -MadiniaSpacing.xxs) // Compensate
    }

    private var emptyState: some View {
        Text("Aucune catégorie disponible")
            .font(MadiniaTypography.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, MadiniaSpacing.lg)
    }
}

// MARK: - Preview

#Preview("Categories Section") {
    VStack {
        CategoriesSection(
            categories: [
                FormationCategory(id: 1, name: "IA Générative", slug: "ia-generative", description: nil, color: "#8B5CF6", icon: nil, formationsCount: 7),
                FormationCategory(id: 2, name: "Marketing Digital", slug: "marketing-digital", description: nil, color: "#EC4899", icon: nil, formationsCount: 5),
                FormationCategory(id: 3, name: "Business", slug: "business", description: nil, color: "#F59E0B", icon: nil, formationsCount: 12),
                FormationCategory(id: 4, name: "Technologie", slug: "technologie", description: nil, color: "#10B981", icon: nil, formationsCount: 3),
            ],
            onViewAllTap: { print("View all tapped") },
            onCategoryTap: { print("Category tapped: \($0.name)") }
        )
        .padding(.horizontal, MadiniaSpacing.md)

        Spacer()
    }
}

#Preview("Empty State") {
    CategoriesSection(categories: [])
        .padding(.horizontal, MadiniaSpacing.md)
}
