//
//  DetailContextualTips.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-15.
//

import SwiftUI
import TipKit

// MARK: - Detail Action Tips

/// Tip 17: Favorite button — unlocked after History tip is dismissed
struct FavoriteTip: Tip {
    @Parameter
    static var hasSeenHistory: Bool = false

    var rules: [Rule] {
        #Rule(Self.$hasSeenHistory) { $0 == true }
    }

    var title: Text {
        Text("Favoris")
    }

    var message: Text? {
        Text("Étape 17/20 — Sauvegarder cette formation en favoris.")
    }

    var image: Image? {
        Image(systemName: "heart.fill")
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

/// Tip 18: Offline Download button — unlocked after Favorite tip is dismissed
struct OfflineDownloadTip: Tip {
    @Parameter
    static var hasSeenFavorite: Bool = false

    var rules: [Rule] {
        #Rule(Self.$hasSeenFavorite) { $0 == true }
    }

    var title: Text {
        Text("Hors ligne")
    }

    var message: Text? {
        Text("Étape 18/20 — Télécharger pour consulter sans connexion.")
    }

    var image: Image? {
        Image(systemName: "arrow.down.circle.fill")
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

/// Tip 19: Share button — unlocked after Offline Download tip is dismissed
struct ShareTip: Tip {
    @Parameter
    static var hasSeenDownload: Bool = false

    var rules: [Rule] {
        #Rule(Self.$hasSeenDownload) { $0 == true }
    }

    var title: Text {
        Text("Partager")
    }

    var message: Text? {
        Text("Étape 19/20 — Partager cette formation avec vos contacts.")
    }

    var image: Image? {
        Image(systemName: "square.and.arrow.up.fill")
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

/// Tip 20: Pre-registration CTA — unlocked after Share tip is dismissed
struct PreRegistrationCTATip: Tip {
    @Parameter
    static var hasSeenShare: Bool = false

    var rules: [Rule] {
        #Rule(Self.$hasSeenShare) { $0 == true }
    }

    var title: Text {
        Text("Pré-inscription")
    }

    var message: Text? {
        Text("Étape 20/20 — Envoyez votre demande de pré-inscription.")
    }

    var image: Image? {
        Image(systemName: "paperplane.fill")
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
