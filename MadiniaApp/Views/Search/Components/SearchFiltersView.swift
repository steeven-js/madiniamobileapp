//
//  SearchFiltersView.swift
//  MadiniaApp
//
//  Vue des filtres avancés pour la recherche de formations.
//

import SwiftUI

// MARK: - Filter Models

/// Options de tri pour les formations
enum SortOption: String, CaseIterable, Identifiable {
    case relevance = "Pertinence"
    case popularity = "Popularité"
    case dateNewest = "Plus récent"
    case dateOldest = "Plus ancien"
    case durationShortest = "Durée croissante"
    case durationLongest = "Durée décroissante"
    case alphabetical = "Alphabétique"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .relevance: return "sparkles"
        case .popularity: return "flame.fill"
        case .dateNewest, .dateOldest: return "calendar"
        case .durationShortest, .durationLongest: return "clock"
        case .alphabetical: return "textformat.abc"
        }
    }
}

/// Options de niveau
enum LevelFilter: String, CaseIterable, Identifiable {
    case all = "Tous"
    case debutant = "Débutant"
    case intermediaire = "Intermédiaire"
    case avance = "Avancé"

    var id: String { rawValue }

    var apiValue: String? {
        switch self {
        case .all: return nil
        case .debutant: return "debutant"
        case .intermediaire: return "intermediaire"
        case .avance: return "avance"
        }
    }

    var color: Color {
        switch self {
        case .all: return .gray
        case .debutant: return .green
        case .intermediaire: return .orange
        case .avance: return .red
        }
    }
}

/// Options de durée
enum DurationFilter: String, CaseIterable, Identifiable {
    case all = "Toutes"
    case short = "< 10h"
    case medium = "10-20h"
    case long = "> 20h"

    var id: String { rawValue }

    func matches(hours: Int?) -> Bool {
        guard let hours = hours else { return self == .all }
        switch self {
        case .all: return true
        case .short: return hours < 10
        case .medium: return hours >= 10 && hours <= 20
        case .long: return hours > 20
        }
    }
}

/// État des filtres de recherche
@Observable
final class SearchFilters {
    var sortOption: SortOption = .relevance
    var levelFilter: LevelFilter = .all
    var durationFilter: DurationFilter = .all
    var certificationOnly: Bool = false
    var selectedCategoryId: Int? = nil

    /// Nombre de filtres actifs (hors tri par défaut)
    var activeFiltersCount: Int {
        var count = 0
        if levelFilter != .all { count += 1 }
        if durationFilter != .all { count += 1 }
        if certificationOnly { count += 1 }
        if selectedCategoryId != nil { count += 1 }
        return count
    }

    /// Indique si des filtres sont actifs
    var hasActiveFilters: Bool {
        activeFiltersCount > 0 || sortOption != .relevance
    }

    /// Réinitialise tous les filtres
    func reset() {
        sortOption = .relevance
        levelFilter = .all
        durationFilter = .all
        certificationOnly = false
        selectedCategoryId = nil
    }
}

// MARK: - Search Filters View

/// Vue sheet pour configurer les filtres de recherche
struct SearchFiltersView: View {
    @Bindable var filters: SearchFilters
    let categories: [FormationCategory]
    let onApply: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // Sort section
                sortSection

                // Level filter
                levelSection

                // Duration filter
                durationSection

                // Certification filter
                certificationSection

                // Category filter
                if !categories.isEmpty {
                    categorySection
                }

                // Reset button
                if filters.hasActiveFilters {
                    resetSection
                }
            }
            .navigationTitle("Filtres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Appliquer") {
                        onApply()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Sort Section

    private var sortSection: some View {
        Section {
            ForEach(SortOption.allCases) { option in
                Button {
                    filters.sortOption = option
                } label: {
                    HStack {
                        Image(systemName: option.icon)
                            .foregroundStyle(MadiniaColors.accent)
                            .frame(width: 24)

                        Text(option.rawValue)
                            .foregroundStyle(.primary)

                        Spacer()

                        if filters.sortOption == option {
                            Image(systemName: "checkmark")
                                .foregroundStyle(MadiniaColors.accent)
                        }
                    }
                }
            }
        } header: {
            Text("Trier par")
        }
    }

    // MARK: - Level Section

    private var levelSection: some View {
        Section {
            ForEach(LevelFilter.allCases) { level in
                Button {
                    filters.levelFilter = level
                } label: {
                    HStack {
                        Circle()
                            .fill(level.color)
                            .frame(width: 12, height: 12)

                        Text(level.rawValue)
                            .foregroundStyle(.primary)

                        Spacer()

                        if filters.levelFilter == level {
                            Image(systemName: "checkmark")
                                .foregroundStyle(MadiniaColors.accent)
                        }
                    }
                }
            }
        } header: {
            Text("Niveau")
        }
    }

    // MARK: - Duration Section

    private var durationSection: some View {
        Section {
            ForEach(DurationFilter.allCases) { duration in
                Button {
                    filters.durationFilter = duration
                } label: {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.secondary)
                            .frame(width: 24)

                        Text(duration.rawValue)
                            .foregroundStyle(.primary)

                        Spacer()

                        if filters.durationFilter == duration {
                            Image(systemName: "checkmark")
                                .foregroundStyle(MadiniaColors.accent)
                        }
                    }
                }
            }
        } header: {
            Text("Durée")
        }
    }

    // MARK: - Certification Section

    private var certificationSection: some View {
        Section {
            Toggle(isOn: $filters.certificationOnly) {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)

                    Text("Certifiante uniquement")
                }
            }
            .tint(MadiniaColors.accent)
        } header: {
            Text("Certification")
        }
    }

    // MARK: - Category Section

    private var categorySection: some View {
        Section {
            Button {
                filters.selectedCategoryId = nil
            } label: {
                HStack {
                    Text("Toutes les catégories")
                        .foregroundStyle(.primary)

                    Spacer()

                    if filters.selectedCategoryId == nil {
                        Image(systemName: "checkmark")
                            .foregroundStyle(MadiniaColors.accent)
                    }
                }
            }

            ForEach(categories) { category in
                Button {
                    filters.selectedCategoryId = category.id
                } label: {
                    HStack {
                        if let colorHex = category.color {
                            Circle()
                                .fill(Color(hex: colorHex) ?? .gray)
                                .frame(width: 12, height: 12)
                        }

                        Text(category.name)
                            .foregroundStyle(.primary)

                        Spacer()

                        if filters.selectedCategoryId == category.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(MadiniaColors.accent)
                        }
                    }
                }
            }
        } header: {
            Text("Catégorie")
        }
    }

    // MARK: - Reset Section

    private var resetSection: some View {
        Section {
            Button(role: .destructive) {
                filters.reset()
            } label: {
                HStack {
                    Spacer()
                    Text("Réinitialiser les filtres")
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Filter Chips View

/// Barre horizontale affichant les filtres actifs sous forme de chips
struct ActiveFiltersChipsView: View {
    @Bindable var filters: SearchFilters
    let categories: [FormationCategory]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MadiniaSpacing.xs) {
                // Sort chip (always visible if not default)
                if filters.sortOption != .relevance {
                    filterChip(
                        icon: filters.sortOption.icon,
                        text: filters.sortOption.rawValue,
                        onRemove: { filters.sortOption = .relevance }
                    )
                }

                // Level chip
                if filters.levelFilter != .all {
                    filterChip(
                        icon: "chart.bar.fill",
                        text: filters.levelFilter.rawValue,
                        color: filters.levelFilter.color,
                        onRemove: { filters.levelFilter = .all }
                    )
                }

                // Duration chip
                if filters.durationFilter != .all {
                    filterChip(
                        icon: "clock",
                        text: filters.durationFilter.rawValue,
                        onRemove: { filters.durationFilter = .all }
                    )
                }

                // Certification chip
                if filters.certificationOnly {
                    filterChip(
                        icon: "checkmark.seal.fill",
                        text: "Certifiante",
                        color: .green,
                        onRemove: { filters.certificationOnly = false }
                    )
                }

                // Category chip
                if let categoryId = filters.selectedCategoryId,
                   let category = categories.first(where: { $0.id == categoryId }) {
                    filterChip(
                        icon: "folder.fill",
                        text: category.name,
                        color: Color(hex: category.color ?? "#888888") ?? .gray,
                        onRemove: { filters.selectedCategoryId = nil }
                    )
                }
            }
            .padding(.horizontal, MadiniaSpacing.md)
        }
    }

    private func filterChip(icon: String, text: String, color: Color = MadiniaColors.accent, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))

            Text(text)
                .font(.system(size: 13, weight: .medium))

            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color)
        .clipShape(Capsule())
    }
}

// MARK: - Filter Button

/// Bouton pour ouvrir les filtres avec badge de compteur
struct FilterButton: View {
    let activeCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 16))

                Text("Filtres")
                    .font(.system(size: 14, weight: .medium))

                if activeCount > 0 {
                    Text("\(activeCount)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(MadiniaColors.accent)
                        .clipShape(Capsule())
                }
            }
            .foregroundStyle(activeCount > 0 ? MadiniaColors.accent : .secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemBackground))
            .clipShape(Capsule())
        }
    }
}

// MARK: - Preview

#Preview("Filters Sheet") {
    SearchFiltersView(
        filters: SearchFilters(),
        categories: [
            FormationCategory(id: 1, name: "IA Générative", slug: "ia", description: nil, color: "#8B5CF6", icon: nil),
            FormationCategory(id: 2, name: "Data Science", slug: "data", description: nil, color: "#3B82F6", icon: nil)
        ],
        onApply: {}
    )
}

#Preview("Active Chips") {
    let filters = SearchFilters()
    filters.levelFilter = .intermediaire
    filters.durationFilter = .medium
    filters.sortOption = .popularity

    return ActiveFiltersChipsView(
        filters: filters,
        categories: []
    )
    .padding()
    .background(Color(.systemBackground))
}
