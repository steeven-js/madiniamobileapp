//
//  HapticManager.swift
//  MadiniaApp
//
//  Gestionnaire de feedback haptique pour les interactions utilisateur.
//  Centralise tous les retours haptiques de l'application.
//

import UIKit
import SwiftUI

/// Gestionnaire centralisé des feedbacks haptiques
enum HapticManager {
    // MARK: - Impact Feedbacks

    /// Feedback léger - pour les sélections, toggles, hover
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Feedback moyen - pour les actions confirmées (ajout favori, validation)
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Feedback fort - pour les actions importantes (suppression, envoi)
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    /// Feedback rigide - pour les fins d'actions (snap, drop)
    static func rigid() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }

    /// Feedback doux - pour les animations fluides
    static func soft() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }

    // MARK: - Notification Feedbacks

    /// Succès - action réussie (envoi formulaire, inscription)
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Avertissement - attention requise
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    /// Erreur - action échouée
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    // MARK: - Selection Feedback

    /// Sélection - pour les pickers, segmented controls
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // MARK: - Semantic Actions

    /// Favori ajouté
    static func favoriteAdded() {
        medium()
    }

    /// Favori retiré
    static func favoriteRemoved() {
        light()
    }

    /// Téléchargement démarré
    static func downloadStarted() {
        light()
    }

    /// Téléchargement terminé
    static func downloadCompleted() {
        success()
    }

    /// Formulaire envoyé
    static func formSubmitted() {
        success()
    }

    /// Navigation (tap sur tab, bouton)
    static func tap() {
        light()
    }

    /// Pull to refresh déclenché
    static func pullToRefresh() {
        medium()
    }

    /// Action destructive (suppression)
    static func destructiveAction() {
        heavy()
    }

    /// Badge ou achievement débloqué
    static func achievementUnlocked() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        // Double tap pour effet spécial
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
            impactGenerator.impactOccurred()
        }
    }

    /// Toggle switch
    static func toggle() {
        rigid()
    }

    /// Scroll snap (carousel, pagination)
    static func snap() {
        soft()
    }
}

// MARK: - View Modifier for Haptic on Tap

/// View modifier qui ajoute un feedback haptique au tap
struct HapticOnTap: ViewModifier {
    let style: HapticStyle

    enum HapticStyle {
        case light, medium, heavy, success, selection, tap
    }

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(TapGesture().onEnded {
                triggerHaptic()
            })
    }

    private func triggerHaptic() {
        switch style {
        case .light:
            HapticManager.light()
        case .medium:
            HapticManager.medium()
        case .heavy:
            HapticManager.heavy()
        case .success:
            HapticManager.success()
        case .selection:
            HapticManager.selection()
        case .tap:
            HapticManager.tap()
        }
    }
}

extension View {
    /// Ajoute un feedback haptique au tap
    func hapticOnTap(_ style: HapticOnTap.HapticStyle = .tap) -> some View {
        modifier(HapticOnTap(style: style))
    }
}
