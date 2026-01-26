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
    @State private var repository = FormationsRepository.shared

    /// Action when a category is selected
    var onCategorySelected: ((FormationCategory) -> Void)?

    var body: some View {
        Group {
            switch repository.categoriesLoadingState {
            case .idle, .loading:
                loadingView
            case .loaded(_):
                if repository.categories.isEmpty {
                    emptyStateView
                } else {
                    categoriesGridContent
                }
            case .error(let message):
                errorView(message: message)
            }
        }
        .navigationTitle("Catégories")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(UIColor.systemGroupedBackground))
        .task {
            await repository.fetchCategoriesIfNeeded()
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: MadiniaSpacing.lg) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Chargement des catégories...")
                .font(MadiniaTypography.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: MadiniaSpacing.xl) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 60))
                .foregroundStyle(MadiniaColors.violet.opacity(0.6))

            Text("Aucune catégorie disponible")
                .font(MadiniaTypography.title2)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        VStack(spacing: MadiniaSpacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Erreur de chargement")
                .font(MadiniaTypography.title2)
                .foregroundStyle(.primary)

            Text(message)
                .font(MadiniaTypography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, MadiniaSpacing.xl)

            Button("Réessayer") {
                Task {
                    await repository.fetchCategoriesIfNeeded()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(MadiniaColors.violet)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Categories Grid Content

    private var categoriesGridContent: some View {
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
            .padding(.bottom, 100)
        }
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
