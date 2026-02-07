//
//  HomePreferencesService.swift
//  MadiniaApp
//
//  Service de gestion des préférences de l'écran d'accueil.
//  Permet la personnalisation des sections visibles et leur ordre.
//

import Foundation

// MARK: - Home Section

/// Identifiant des sections de l'écran d'accueil
enum HomeSection: String, Codable, CaseIterable, Identifiable {
    case continuelearning = "continue_learning"
    case news = "news"
    case events = "events"
    case booking = "booking"
    case mostViewed = "most_viewed"

    var id: String { rawValue }

    /// Titre affiché pour la section
    var displayTitle: String {
        switch self {
        case .continuelearning:
            return "Reprendre"
        case .news:
            return "Actualités"
        case .events:
            return "Événements"
        case .booking:
            return "Réservation"
        case .mostViewed:
            return "Formations populaires"
        }
    }

    /// Description de la section
    var description: String {
        switch self {
        case .continuelearning:
            return "Reprendre où vous en étiez"
        case .news:
            return "Articles et actualités du blog"
        case .events:
            return "Événements à venir"
        case .booking:
            return "Réserver un créneau de consultation"
        case .mostViewed:
            return "Les formations les plus consultées"
        }
    }

    /// Icône de la section
    var icon: String {
        switch self {
        case .continuelearning:
            return "clock.arrow.circlepath"
        case .news:
            return "newspaper.fill"
        case .events:
            return "calendar"
        case .booking:
            return "calendar.badge.plus"
        case .mostViewed:
            return "chart.bar.fill"
        }
    }

    /// Ordre par défaut
    static var defaultOrder: [HomeSection] {
        [.continuelearning, .news, .events, .booking, .mostViewed]
    }
}

// MARK: - Section Preference

/// Préférence pour une section individuelle
struct HomeSectionPreference: Codable, Identifiable {
    let section: HomeSection
    var isVisible: Bool
    var order: Int

    var id: String { section.id }
}

// MARK: - Home Preferences Service

/// Service de gestion des préférences de l'écran d'accueil
@Observable
final class HomePreferencesService {
    /// Shared singleton instance
    static let shared = HomePreferencesService()

    // MARK: - Storage Keys

    private let preferencesKey = "home_section_preferences"

    // MARK: - Public State

    /// Préférences des sections
    private(set) var sectionPreferences: [HomeSectionPreference] = []

    /// Sections visibles triées par ordre
    var visibleSections: [HomeSection] {
        sectionPreferences
            .filter { $0.isVisible }
            .sorted { $0.order < $1.order }
            .map { $0.section }
    }

    /// Indique si les préférences ont été modifiées
    var hasCustomizations: Bool {
        let defaultOrder = HomeSection.defaultOrder
        let currentOrder = visibleSections

        // Vérifier si toutes les sections sont visibles
        let allVisible = sectionPreferences.allSatisfy { $0.isVisible }
        if !allVisible { return true }

        // Vérifier si l'ordre est différent
        return currentOrder != defaultOrder
    }

    // MARK: - Initialization

    private init() {
        loadPreferences()
    }

    // MARK: - Public Methods

    /// Vérifie si une section est visible
    func isSectionVisible(_ section: HomeSection) -> Bool {
        sectionPreferences.first { $0.section == section }?.isVisible ?? true
    }

    /// Active/désactive une section
    func toggleSection(_ section: HomeSection) {
        if let index = sectionPreferences.firstIndex(where: { $0.section == section }) {
            sectionPreferences[index].isVisible.toggle()
            savePreferences()
            HapticManager.toggle()
        }
    }

    /// Définit la visibilité d'une section
    func setVisibility(for section: HomeSection, visible: Bool) {
        if let index = sectionPreferences.firstIndex(where: { $0.section == section }) {
            sectionPreferences[index].isVisible = visible
            savePreferences()
        }
    }

    /// Déplace une section à un nouvel index
    func moveSection(from source: IndexSet, to destination: Int) {
        var visiblePrefs = sectionPreferences
            .filter { $0.isVisible }
            .sorted { $0.order < $1.order }

        visiblePrefs.move(fromOffsets: source, toOffset: destination)

        // Mettre à jour les ordres
        for (index, pref) in visiblePrefs.enumerated() {
            if let prefIndex = sectionPreferences.firstIndex(where: { $0.section == pref.section }) {
                sectionPreferences[prefIndex].order = index
            }
        }

        savePreferences()
        HapticManager.selection()
    }

    /// Réinitialise les préférences par défaut
    func resetToDefaults() {
        initializeDefaultPreferences()
        savePreferences()
        HapticManager.success()
    }

    // MARK: - Private Methods

    private func loadPreferences() {
        guard let data = UserDefaults.standard.data(forKey: preferencesKey),
              let prefs = try? JSONDecoder().decode([HomeSectionPreference].self, from: data) else {
            initializeDefaultPreferences()
            return
        }

        // Vérifier que toutes les sections sont présentes
        let existingSections = Set(prefs.map { $0.section })
        let allSections = Set(HomeSection.allCases)

        if existingSections == allSections {
            sectionPreferences = prefs
        } else {
            // Ajouter les sections manquantes
            var updatedPrefs = prefs
            let maxOrder = prefs.map { $0.order }.max() ?? -1

            for (index, section) in HomeSection.allCases.enumerated() {
                if !existingSections.contains(section) {
                    updatedPrefs.append(HomeSectionPreference(
                        section: section,
                        isVisible: true,
                        order: maxOrder + 1 + index
                    ))
                }
            }
            sectionPreferences = updatedPrefs
            savePreferences()
        }
    }

    private func initializeDefaultPreferences() {
        sectionPreferences = HomeSection.defaultOrder.enumerated().map { index, section in
            HomeSectionPreference(section: section, isVisible: true, order: index)
        }
    }

    private func savePreferences() {
        guard let data = try? JSONEncoder().encode(sectionPreferences) else { return }
        UserDefaults.standard.set(data, forKey: preferencesKey)
    }
}
