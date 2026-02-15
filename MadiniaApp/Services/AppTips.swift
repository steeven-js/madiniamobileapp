//
//  AppTips.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-09.
//

import SwiftUI
import TipKit

// MARK: - Main Tour Gate

/// Shared gate parameter: contextual tips only appear after the main tour is completed.
enum MainTourGate {
    @Parameter
    static var hasCompleted: Bool = false
}

// MARK: - Tip 1: Home Tab

/// First tip in the coach marks tour - appears immediately on first launch
struct HomeTabTip: Tip {
    var title: Text {
        Text("Accueil")
    }

    var message: Text? {
        Text("Étape 1/20 — Retrouvez ici vos formations en cours, les dernières actualités et les événements à venir.")
    }

    var image: Image? {
        Image(systemName: "house.fill")
    }

    var actions: [Action] {
        [
            Action(id: "next", title: "Suivant", perform: {
                CoachMarkService.shared.advanceToNextStep()
            }),
            Action(id: "skip-tour", title: "Passer le guide", perform: {
                CoachMarkService.shared.skipTour()
            })
        ]
    }
}

// MARK: - Tip 2: Madin.IA Tab

struct MadiniaTabTip: Tip {
    @Parameter
    static var hasDismissedHomeTab: Bool = false

    var rules: [Rule] {
        #Rule(Self.$hasDismissedHomeTab) { $0 == true }
    }

    var title: Text {
        Text("Madin.IA")
    }

    var message: Text? {
        Text("Étape 2/20 — Explorez les articles du blog, les vidéos et toutes les ressources Madin.IA.")
    }

    var image: Image? {
        Image(systemName: "newspaper.fill")
    }

    var actions: [Action] {
        [
            Action(id: "next", title: "Suivant", perform: {
                CoachMarkService.shared.advanceToNextStep()
            }),
            Action(id: "skip-tour", title: "Passer le guide", perform: {
                CoachMarkService.shared.skipTour()
            })
        ]
    }
}

// MARK: - Tip 3: L'IA&Vous Tab

struct UserSpaceTabTip: Tip {
    @Parameter
    static var hasDismissedMadiniaTab: Bool = false

    var rules: [Rule] {
        #Rule(Self.$hasDismissedMadiniaTab) { $0 == true }
    }

    var title: Text {
        Text("L'IA&Vous")
    }

    var message: Text? {
        Text("Étape 3/20 — Votre espace personnel : favoris, progression et historique de formations.")
    }

    var image: Image? {
        Image(systemName: "person.crop.circle")
    }

    var actions: [Action] {
        [
            Action(id: "next", title: "Suivant", perform: {
                CoachMarkService.shared.advanceToNextStep()
            }),
            Action(id: "skip-tour", title: "Passer le guide", perform: {
                CoachMarkService.shared.skipTour()
            })
        ]
    }
}

// MARK: - Tip 4: Search Tab

struct SearchTabTip: Tip {
    @Parameter
    static var hasDismissedUserSpaceTab: Bool = false

    var rules: [Rule] {
        #Rule(Self.$hasDismissedUserSpaceTab) { $0 == true }
    }

    var title: Text {
        Text("Recherche")
    }

    var message: Text? {
        Text("Étape 4/20 — Trouvez rapidement une formation, un service ou une catégorie.")
    }

    var image: Image? {
        Image(systemName: "magnifyingglass")
    }

    var actions: [Action] {
        [
            Action(id: "next", title: "Suivant", perform: {
                CoachMarkService.shared.advanceToNextStep()
            }),
            Action(id: "skip-tour", title: "Passer le guide", perform: {
                CoachMarkService.shared.skipTour()
            })
        ]
    }
}

// MARK: - Tip 5: Madi FAB

struct MadiFABTip: Tip {
    @Parameter
    static var hasDismissedSearchTab: Bool = false

    var rules: [Rule] {
        #Rule(Self.$hasDismissedSearchTab) { $0 == true }
    }

    var title: Text {
        Text("Madi, coach IA")
    }

    var message: Text? {
        Text("Étape 5/20 — Posez vos questions à Madi, votre assistant IA personnel. Il vous guide dans vos formations.")
    }

    var image: Image? {
        Image(systemName: "bubble.left.and.bubble.right.fill")
    }

    var actions: [Action] {
        [
            Action(id: "next", title: "Suivant", perform: {
                CoachMarkService.shared.advanceToNextStep()
            }),
            Action(id: "skip-tour", title: "Passer le guide", perform: {
                CoachMarkService.shared.skipTour()
            })
        ]
    }
}

// MARK: - Tip 6: Settings

struct SettingsTip: Tip {
    @Parameter
    static var hasDismissedMadiFAB: Bool = false

    var rules: [Rule] {
        #Rule(Self.$hasDismissedMadiFAB) { $0 == true }
    }

    var title: Text {
        Text("Paramètres")
    }

    var message: Text? {
        Text("Étape 6/20 — Personnalisez l'apparence, les notifications et gérez vos données.")
    }

    var image: Image? {
        Image(systemName: "gearshape.fill")
    }

    var actions: [Action] {
        [
            Action(id: "next", title: "Suivant", perform: {
                CoachMarkService.shared.advanceToNextStep()
            }),
            Action(id: "skip-tour", title: "Passer le guide", perform: {
                CoachMarkService.shared.skipTour()
            })
        ]
    }
}

// MARK: - Tip 7: Customize Home

struct CustomizeHomeTip: Tip {
    @Parameter
    static var hasDismissedSettings: Bool = false

    var rules: [Rule] {
        #Rule(Self.$hasDismissedSettings) { $0 == true }
    }

    var title: Text {
        Text("Personnaliser l'accueil")
    }

    var message: Text? {
        Text("Étape 7/20 — Choisissez les sections à afficher et réorganisez votre page d'accueil.")
    }

    var image: Image? {
        Image(systemName: "slider.horizontal.3")
    }

    var actions: [Action] {
        [
            Action(id: "next", title: "Suivant", perform: {
                CoachMarkService.shared.advanceToNextStep()
            }),
            Action(id: "skip-tour", title: "Passer le guide", perform: {
                CoachMarkService.shared.skipTour()
            })
        ]
    }
}

// MARK: - Tip 8: Search Filters

struct SearchFiltersTip: Tip {
    @Parameter
    static var hasDismissedCustomizeHome: Bool = false

    var rules: [Rule] {
        #Rule(Self.$hasDismissedCustomizeHome) { $0 == true }
    }

    var title: Text {
        Text("Filtres de recherche")
    }

    var message: Text? {
        Text("Étape 8/20 — Affinez vos résultats par catégorie, durée ou niveau pour trouver la formation idéale.")
    }

    var image: Image? {
        Image(systemName: "line.3.horizontal.decrease.circle.fill")
    }

    var actions: [Action] {
        [
            Action(id: "next", title: "Suivant", perform: {
                CoachMarkService.shared.advanceToNextStep()
            }),
            Action(id: "skip-tour", title: "Passer le guide", perform: {
                CoachMarkService.shared.skipTour()
            })
        ]
    }
}
