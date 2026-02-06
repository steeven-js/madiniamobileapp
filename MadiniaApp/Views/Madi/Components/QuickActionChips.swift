//
//  QuickActionChips.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-06.
//

import SwiftUI

// MARK: - Quick Action Chips View

/// Displays a horizontal scrollable list of quick action chips
struct QuickActionChips: View {
    let actions: [QuickAction]
    let onTap: (QuickAction) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(actions) { action in
                    QuickActionChip(action: action) {
                        onTap(action)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Single Chip

/// A single quick action chip button
private struct QuickActionChip: View {
    let action: QuickAction
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: action.icon)
                    .font(.caption)
                Text(action.label)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(MadiniaColors.violet)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(MadiniaColors.violet.opacity(0.12))
            )
            .overlay(
                Capsule()
                    .stroke(MadiniaColors.violet.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(ChipButtonStyle())
        .accessibilityLabel(action.label)
    }
}

// MARK: - Button Style

/// Custom button style for chips with scale animation
private struct ChipButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Message Quick Actions

/// Quick action chips displayed within a message bubble
struct MessageQuickActions: View {
    let actions: [QuickAction]
    let onTap: (QuickAction) -> Void

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(actions) { action in
                Button {
                    onTap(action)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: action.icon)
                            .font(.caption2)
                        Text(action.label)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(MadiniaColors.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(MadiniaColors.accent.opacity(0.1))
                    )
                }
                .buttonStyle(ChipButtonStyle())
            }
        }
    }
}

// MARK: - Previews

#Preview("Quick Action Chips") {
    VStack(spacing: 20) {
        QuickActionChips(
            actions: [
                QuickAction(label: "Recommandations", icon: "sparkles", actionType: .showRecommendations),
                QuickAction(label: "Quiz IA", icon: "brain.head.profile", actionType: .startQuiz),
                QuickAction(label: "Mes favoris", icon: "heart.fill", actionType: .showFavorites)
            ],
            onTap: { action in
                print("Tapped: \(action.label)")
            }
        )

        Divider()

        MessageQuickActions(
            actions: [
                QuickAction(label: "Voir la formation", icon: "book.fill", actionType: .askAboutFormation(slug: "starter")),
                QuickAction(label: "Autre chose", icon: "ellipsis", actionType: .showRecommendations)
            ],
            onTap: { action in
                print("Tapped: \(action.label)")
            }
        )
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .padding()
}
