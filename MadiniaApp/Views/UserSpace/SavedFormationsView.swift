//
//  SavedFormationsView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-25.
//

import SwiftUI

/// View displaying the user's saved (favorited) formations.
/// Accessible from the UserSpaceView "Formations sauvegardées" card.
struct SavedFormationsView: View {
    @State private var viewModel = SavedFormationsViewModel()
    @State private var selectedFormation: Formation?

    var body: some View {
        Group {
            switch viewModel.loadingState {
            case .idle, .loading:
                loadingView
            case .loaded(let formations):
                if formations.isEmpty {
                    emptyStateView
                } else {
                    formationsListView(formations: formations)
                }
            case .error(let message):
                errorView(message: message)
            }
        }
        .navigationTitle("Formations sauvegardées")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadSavedFormations()
        }
        .refreshable {
            await viewModel.refresh()
        }
        .sheet(item: $selectedFormation) { formation in
            FormationDetailSheetView(formation: formation)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: MadiniaSpacing.lg) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Chargement de vos favoris...")
                .font(MadiniaTypography.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: MadiniaSpacing.xl) {
            Image(systemName: "bookmark")
                .font(.system(size: 60))
                .foregroundStyle(MadiniaColors.gold.opacity(0.6))

            VStack(spacing: MadiniaSpacing.sm) {
                Text("Aucune formation sauvegardée")
                    .font(MadiniaTypography.title2)
                    .foregroundStyle(.primary)

                Text("Appuyez sur le coeur d'une formation pour l'ajouter à vos favoris.")
                    .font(MadiniaTypography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, MadiniaSpacing.xl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 100) // Account for tab bar
    }

    // MARK: - Formations List

    private func formationsListView(formations: [Formation]) -> some View {
        ScrollView {
            LazyVStack(spacing: MadiniaSpacing.md) {
                ForEach(formations) { formation in
                    SavedFormationCard(formation: formation) {
                        selectedFormation = formation
                    } onRemove: {
                        Task {
                            await viewModel.removeFavorite(formationId: formation.id)
                        }
                    }
                }
            }
            .padding(MadiniaSpacing.md)
            .padding(.bottom, 100) // Space for tab bar
        }
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
                    await viewModel.loadSavedFormations()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(MadiniaColors.violet)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Saved Formation Card

/// Card component for displaying a saved formation with remove option.
struct SavedFormationCard: View {
    let formation: Formation
    let onTap: () -> Void
    let onRemove: () -> Void

    @State private var showRemoveConfirmation = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: MadiniaSpacing.md) {
                // Image
                formationImage

                // Content
                VStack(alignment: .leading, spacing: MadiniaSpacing.xs) {
                    Text(formation.title)
                        .font(MadiniaTypography.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    if let shortDescription = formation.shortDescription {
                        Text(shortDescription)
                            .font(MadiniaTypography.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }

                    // Info row
                    HStack(spacing: MadiniaSpacing.sm) {
                        if formation.durationHours ?? 0 > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 11))
                                Text(formation.duration)
                                    .font(.system(size: 12))
                            }
                            .foregroundStyle(.secondary)
                        }

                        if let category = formation.category {
                            let categoryColor = Color(hex: category.color ?? "#8B5CF6") ?? .madiniaViolet
                            Text(category.name)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(categoryColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(categoryColor.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }

                Spacer()

                // Remove button
                Button {
                    showRemoveConfirmation = true
                } label: {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.red)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(MadiniaSpacing.md)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
        .confirmationDialog(
            "Retirer des favoris ?",
            isPresented: $showRemoveConfirmation,
            titleVisibility: .visible
        ) {
            Button("Retirer", role: .destructive) {
                onRemove()
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Cette formation sera retirée de vos favoris.")
        }
    }

    private var formationImage: some View {
        Group {
            if let imageUrl = formation.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        imagePlaceholder
                    @unknown default:
                        imagePlaceholder
                    }
                }
            } else {
                imagePlaceholder
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.sm))
    }

    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: MadiniaRadius.sm)
            .fill(
                LinearGradient(
                    colors: [MadiniaColors.violet.opacity(0.3), MadiniaColors.violet.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: "book.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.7))
            }
    }
}

// MARK: - Previews

#Preview("With Formations") {
    NavigationStack {
        SavedFormationsView()
    }
}

#Preview("Empty State") {
    NavigationStack {
        SavedFormationsView()
    }
}

#Preview("Card") {
    SavedFormationCard(
        formation: Formation.sample,
        onTap: {},
        onRemove: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
