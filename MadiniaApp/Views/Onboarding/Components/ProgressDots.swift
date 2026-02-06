//
//  ProgressDots.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-05.
//

import SwiftUI

/// Progress indicator component showing dots for onboarding steps.
/// Active step is highlighted with accent color and larger size.
struct ProgressDots: View {
    /// Current step index (0-based)
    let currentStep: Int

    /// Total number of steps
    let totalSteps: Int

    /// Size of inactive dots
    private let dotSize: CGFloat = 8

    /// Size of active dot
    private let activeDotSize: CGFloat = 10

    var body: some View {
        HStack(spacing: MadiniaSpacing.xs) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Circle()
                    .fill(index == currentStep ? MadiniaColors.accent : MadiniaColors.violet.opacity(0.3))
                    .frame(
                        width: index == currentStep ? activeDotSize : dotSize,
                        height: index == currentStep ? activeDotSize : dotSize
                    )
                    .animation(.easeInOut(duration: 0.2), value: currentStep)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Étape \(currentStep + 1) sur \(totalSteps)")
    }
}

// MARK: - Previews

#Preview("Progress Dots") {
    VStack(spacing: MadiniaSpacing.xl) {
        ProgressDots(currentStep: 0, totalSteps: 4)
        ProgressDots(currentStep: 1, totalSteps: 4)
        ProgressDots(currentStep: 2, totalSteps: 4)
        ProgressDots(currentStep: 3, totalSteps: 4)
    }
    .padding()
}
