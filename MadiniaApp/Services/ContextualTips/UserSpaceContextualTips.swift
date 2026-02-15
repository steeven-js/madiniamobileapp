//
//  UserSpaceContextualTips.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-15.
//

import SwiftUI
import TipKit

// MARK: - User Space Section Tips

/// Tip 13: Saved Formations — unlocked after Hub Contact tip is dismissed
struct SavedFormationsTip: Tip {
    @Parameter
    static var hasSeenHubContact: Bool = false

    var rules: [Rule] {
        #Rule(Self.$hasSeenHubContact) { $0 == true }
    }

    var title: Text {
        Text("Formations sauvegardées")
    }

    var message: Text? {
        Text("Étape 13/20 — Vos formations favorites, accessibles en un clic.")
    }

    var image: Image? {
        Image(systemName: "bookmark.fill")
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

/// Tip 14: Pre-Registrations — unlocked after Saved Formations tip is dismissed
struct PreRegistrationsTip: Tip {
    @Parameter
    static var hasSeenSaved: Bool = false

    var rules: [Rule] {
        #Rule(Self.$hasSeenSaved) { $0 == true }
    }

    var title: Text {
        Text("Pré-inscriptions")
    }

    var message: Text? {
        Text("Étape 14/20 — Suivi de vos demandes de pré-inscription.")
    }

    var image: Image? {
        Image(systemName: "doc.text.fill")
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

/// Tip 15: Progress — unlocked after Pre-Registrations tip is dismissed
struct ProgressTip: Tip {
    @Parameter
    static var hasSeenPreReg: Bool = false

    var rules: [Rule] {
        #Rule(Self.$hasSeenPreReg) { $0 == true }
    }

    var title: Text {
        Text("Ma progression")
    }

    var message: Text? {
        Text("Étape 15/20 — Statistiques, badges et accomplissements.")
    }

    var image: Image? {
        Image(systemName: "chart.line.uptrend.xyaxis")
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

/// Tip 16: History — unlocked after Progress tip is dismissed
struct HistoryTip: Tip {
    @Parameter
    static var hasSeenProgress: Bool = false

    var rules: [Rule] {
        #Rule(Self.$hasSeenProgress) { $0 == true }
    }

    var title: Text {
        Text("Historique")
    }

    var message: Text? {
        Text("Étape 16/20 — Formations que vous avez consultées récemment.")
    }

    var image: Image? {
        Image(systemName: "clock.arrow.circlepath")
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
