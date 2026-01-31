//
//  AllFormationsListView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// List view showing all formations.
struct AllFormationsListView: View {
    /// All formations to display
    let formations: [Formation]

    @State private var selectedFormation: Formation?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: MadiniaSpacing.sm) {
                ForEach(formations) { formation in
                    FormationRowCard(formation: formation) {
                        selectedFormation = formation
                    }
                }

                if formations.isEmpty {
                    emptyStateView
                }
            }
            .padding(MadiniaSpacing.md)
            .tabBarSafeArea()
        }
        .navigationTitle("Toutes les formations")
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

            Text("Aucune formation disponible")
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
        AllFormationsListView(formations: Formation.samples)
    }
}
