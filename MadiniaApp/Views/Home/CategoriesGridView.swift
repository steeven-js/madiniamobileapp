//
//  CategoriesGridView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// Full-screen grid view displaying all categories.
/// Accessed via "View all" from the home screen categories section.
/// Uses masonry layout with alternating card heights.
struct CategoriesGridView: View {
    /// Repository for formations data
    private let repository = FormationsRepository.shared

    /// Action when a category is selected
    var onCategorySelected: ((FormationCategory) -> Void)?

    var body: some View {
        ScrollView {
            HStack(alignment: .top, spacing: MadiniaSpacing.md) {
                // Left column
                VStack(spacing: MadiniaSpacing.md) {
                    ForEach(Array(leftColumnCategories.enumerated()), id: \.element.id) { index, category in
                        CategoryGridCard(
                            category: category,
                            formationCount: category.formationsCount ?? 0,
                            heightVariant: leftColumnHeight(for: index)
                        ) {
                            onCategorySelected?(category)
                        }
                    }
                }

                // Right column
                VStack(spacing: MadiniaSpacing.md) {
                    ForEach(Array(rightColumnCategories.enumerated()), id: \.element.id) { index, category in
                        CategoryGridCard(
                            category: category,
                            formationCount: category.formationsCount ?? 0,
                            heightVariant: rightColumnHeight(for: index)
                        ) {
                            onCategorySelected?(category)
                        }
                    }
                }
            }
            .padding(.horizontal, MadiniaSpacing.md)
            .padding(.vertical, MadiniaSpacing.md)
        }
        .navigationTitle("Catégories")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(UIColor.systemGroupedBackground))
    }

    // MARK: - Computed Properties

    /// Categories for left column (even indices)
    private var leftColumnCategories: [FormationCategory] {
        repository.categories.enumerated().compactMap { index, category in
            index % 2 == 0 ? category : nil
        }
    }

    /// Categories for right column (odd indices)
    private var rightColumnCategories: [FormationCategory] {
        repository.categories.enumerated().compactMap { index, category in
            index % 2 == 1 ? category : nil
        }
    }

    // MARK: - Helpers

    /// Height variant for left column: short, tall, short, tall...
    private func leftColumnHeight(for index: Int) -> CategoryGridCard.HeightVariant {
        index % 2 == 0 ? .short : .tall
    }

    /// Height variant for right column: tall, short, tall, short... (opposite of left)
    private func rightColumnHeight(for index: Int) -> CategoryGridCard.HeightVariant {
        index % 2 == 0 ? .tall : .short
    }
}

// MARK: - Preview

#Preview("Categories Grid - Masonry") {
    NavigationStack {
        CategoriesGridView { category in
            print("Selected: \(category.name)")
        }
    }
}
