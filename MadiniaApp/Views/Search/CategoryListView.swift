//
//  CategoryListView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// List view showing all formations in a specific category.
/// Based on Figma mockup "15 Category List".
struct CategoryListView: View {
    /// The category to display
    let category: FormationCategory

    /// All formations (filtered by this category)
    let formations: [Formation]

    /// Computed filtered formations for this category
    private var categoryFormations: [Formation] {
        formations.filter { $0.category?.id == category.id }
    }

    @State private var selectedFormation: Formation?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: MadiniaSpacing.sm) {
                ForEach(categoryFormations) { formation in
                    FormationRowCard(formation: formation) {
                        selectedFormation = formation
                    }
                }

                if categoryFormations.isEmpty {
                    emptyStateView
                }
            }
            .padding(MadiniaSpacing.md)
            .tabBarSafeArea()
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedFormation) { formation in
            FormationDetailSheetView(formation: formation)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: MadiniaSpacing.sm) {
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("Aucune formation dans cette catégorie")
                .font(MadiniaTypography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MadiniaSpacing.xxl)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CategoryListView(
            category: FormationCategory(
                id: 1,
                name: "IA Générative",
                slug: "ia-generative",
                description: nil,
                color: "#8B5CF6",
                icon: nil,
                formationsCount: 7
            ),
            formations: Formation.samples
        )
    }
}
