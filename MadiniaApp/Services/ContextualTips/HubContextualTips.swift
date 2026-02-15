//
//  HubContextualTips.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-15.
//

import SwiftUI
import TipKit

// MARK: - Hub Sub-Tab Tips

/// Tip 9: About sub-tab in MadiniaHubView — first contextual tip, gated by MainTourGate
struct HubAboutTabTip: Tip {
    var rules: [Rule] {
        #Rule(MainTourGate.$hasCompleted) { $0 == true }
    }

    var title: Text {
        Text("À propos")
    }

    var message: Text? {
        Text("Étape 9/20 — Découvrez la mission et l'équipe Madin.IA.")
    }

    var image: Image? {
        Image(systemName: "info.circle.fill")
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

/// Tip 10: Blog sub-tab — unlocked after About tip is dismissed
struct HubBlogTabTip: Tip {
    @Parameter
    static var hasSeenAbout: Bool = false

    var rules: [Rule] {
        #Rule(Self.$hasSeenAbout) { $0 == true }
    }

    var title: Text {
        Text("Blog")
    }

    var message: Text? {
        Text("Étape 10/20 — Articles sur l'IA et les bonnes pratiques.")
    }

    var image: Image? {
        Image(systemName: "doc.richtext.fill")
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

/// Tip 11: Events sub-tab — unlocked after Blog tip is dismissed
struct HubEventsTabTip: Tip {
    @Parameter
    static var hasSeenBlog: Bool = false

    var rules: [Rule] {
        #Rule(Self.$hasSeenBlog) { $0 == true }
    }

    var title: Text {
        Text("Événements")
    }

    var message: Text? {
        Text("Étape 11/20 — Conférences, ateliers et webinaires.")
    }

    var image: Image? {
        Image(systemName: "calendar.badge.clock")
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

/// Tip 12: Contact sub-tab — unlocked after Events tip is dismissed
struct HubContactTabTip: Tip {
    @Parameter
    static var hasSeenEvents: Bool = false

    var rules: [Rule] {
        #Rule(Self.$hasSeenEvents) { $0 == true }
    }

    var title: Text {
        Text("Contact")
    }

    var message: Text? {
        Text("Étape 12/20 — Contactez-nous ou réservez un rendez-vous.")
    }

    var image: Image? {
        Image(systemName: "envelope.fill")
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
