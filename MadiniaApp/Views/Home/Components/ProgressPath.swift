//
//  ProgressPath.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

// MARK: - ProgressStep Model

/// Represents a step in the progress path (Starter, Performer, Master)
struct ProgressStep: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let color: Color

    /// Static list of all progress steps in order
    static let steps: [ProgressStep] = [
        ProgressStep(
            id: "starter",
            name: "Starter",
            description: "Fondations IA",
            icon: "star.fill",
            color: .green
        ),
        ProgressStep(
            id: "performer",
            name: "Performer",
            description: "Maîtrise avancée",
            icon: "flame.fill",
            color: .orange
        ),
        ProgressStep(
            id: "master",
            name: "Master",
            description: "Expertise complète",
            icon: "crown.fill",
            color: .red
        )
    ]
}

// MARK: - ProgressPath View

/// Visual progression path showing Starter→Performer→Master journey.
/// Displays on home screen to help users understand the learning path.
struct ProgressPath: View {
    /// Action when a step is tapped
    var onStepTap: ((ProgressStep) -> Void)?

    /// The steps to display
    private let steps = ProgressStep.steps

    var body: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            // Section header
            Text("Votre parcours")
                .font(MadiniaTypography.title2)
                .fontWeight(.bold)

            // Steps with connectors
            HStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    stepView(step)

                    if index < steps.count - 1 {
                        connectorLine
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    /// Individual step view with icon, name, and description
    private func stepView(_ step: ProgressStep) -> some View {
        Button {
            onStepTap?(step)
        } label: {
            VStack(spacing: MadiniaSpacing.xs) {
                // Icon circle with colored background
                ZStack {
                    Circle()
                        .fill(step.color.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: step.icon)
                        .font(.title2)
                        .foregroundStyle(step.color)
                }

                // Pack name
                Text(step.name)
                    .font(MadiniaTypography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                // Brief description
                Text(step.description)
                    .font(MadiniaTypography.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, minHeight: 100) // Ensure touch target >= 44pt
            .contentShape(Rectangle()) // Ensure full area is tappable
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("\(step.name), \(step.description)")
        .accessibilityHint("Appuyez pour voir les formations \(step.name)")
    }

    /// Connector line between steps (gold)
    private var connectorLine: some View {
        Rectangle()
            .fill(MadiniaColors.gold.opacity(0.6))
            .frame(height: 2)
            .frame(maxWidth: 24)
            .padding(.bottom, 40) // Align with circles
    }
}

// MARK: - Previews

#Preview {
    VStack {
        ProgressPath { step in
            print("Tapped: \(step.name)")
        }
    }
    .padding()
}

#Preview("Without Tap Handler") {
    ProgressPath()
        .padding()
}
