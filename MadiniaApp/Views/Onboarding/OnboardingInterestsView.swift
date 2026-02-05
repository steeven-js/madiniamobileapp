//
//  OnboardingInterestsView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-05.
//

import SwiftUI

/// Second screen of the onboarding flow.
/// Allows users to select their interests for personalized content.
struct OnboardingInterestsView: View {
    /// Callback when user taps continue
    let onContinue: () -> Void

    /// Local state for selected interests (synced with service on continue)
    @State private var selectedInterests: Set<String> = []

    /// Data repository for dynamic categories
    private let dataRepository = AppDataRepository.shared

    /// Predefined interest topics
    private let predefinedInterests = [
        Interest(id: "ia-generative", name: "IA Générative"),
        Interest(id: "data-science", name: "Data Science & Analytics"),
        Interest(id: "automation", name: "Automatisation & No-Code"),
        Interest(id: "development", name: "Développement & API"),
        Interest(id: "business", name: "Business & Stratégie")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection

            // Interests selection
            ScrollView {
                VStack(alignment: .leading, spacing: MadiniaSpacing.lg) {
                    // Predefined interests
                    interestSection(
                        title: "Centres d'intérêt",
                        interests: predefinedInterests
                    )

                    // Dynamic categories from API
                    if !dynamicCategories.isEmpty {
                        interestSection(
                            title: "Catégories de formations",
                            interests: dynamicCategories
                        )
                    }
                }
                .padding(MadiniaSpacing.lg)
            }

            // Bottom section
            bottomSection
        }
        .background(MadiniaColors.surfaceBackground)
        .onAppear {
            // Load existing selections from service
            selectedInterests = Set(OnboardingService.shared.selectedInterests)
        }
    }

    // MARK: - Actions

    private func toggleInterest(_ id: String) {
        if selectedInterests.contains(id) {
            selectedInterests.remove(id)
        } else {
            selectedInterests.insert(id)
        }
    }

    private func saveAndContinue() {
        // Save to service
        OnboardingService.shared.selectedInterests = Array(selectedInterests)
        onContinue()
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: MadiniaSpacing.sm) {
            Text("Vos centres d'intérêt")
                .font(MadiniaTypography.largeTitle)
                .foregroundStyle(MadiniaColors.darkGray)

            Text("Sélectionnez les sujets qui vous intéressent pour personnaliser votre expérience")
                .font(MadiniaTypography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, MadiniaSpacing.lg)
        }
        .padding(.top, MadiniaSpacing.xxl)
        .padding(.bottom, MadiniaSpacing.lg)
    }

    // MARK: - Interest Section

    private func interestSection(title: String, interests: [Interest]) -> some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            Text(title)
                .font(MadiniaTypography.headline)
                .foregroundStyle(MadiniaColors.darkGray)

            FlowLayout(spacing: MadiniaSpacing.xs) {
                ForEach(interests) { interest in
                    InterestChip(
                        name: interest.name,
                        isSelected: selectedInterests.contains(interest.id)
                    ) {
                        toggleInterest(interest.id)
                    }
                }
            }
        }
    }

    // MARK: - Bottom Section

    private var bottomSection: some View {
        VStack(spacing: MadiniaSpacing.lg) {
            // Selection count hint
            if selectedInterests.isEmpty {
                Text("Sélectionnez au moins un centre d'intérêt")
                    .font(MadiniaTypography.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("\(selectedInterests.count) sélectionné(s)")
                    .font(MadiniaTypography.caption)
                    .foregroundStyle(MadiniaColors.accent)
            }

            // Continue button
            Button {
                saveAndContinue()
            } label: {
                Text("Continuer")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(MadiniaColors.darkGrayFixed)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, MadiniaSpacing.md)
                    .background(MadiniaColors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
            }

            // Skip option
            Button {
                saveAndContinue()
            } label: {
                Text("Passer cette étape")
                    .font(MadiniaTypography.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Progress dots
            ProgressDots(currentStep: 1, totalSteps: 4)
                .padding(.bottom, MadiniaSpacing.md)
        }
        .padding(.horizontal, MadiniaSpacing.lg)
        .padding(.top, MadiniaSpacing.md)
    }

    // MARK: - Computed Properties

    /// Dynamic categories from AppDataRepository converted to Interest model
    private var dynamicCategories: [Interest] {
        dataRepository.categories.map { category in
            Interest(id: category.slug ?? "category-\(category.id)", name: category.name)
        }
    }
}

// MARK: - Interest Model

/// Simple model for interest selection
struct Interest: Identifiable {
    let id: String
    let name: String
}

// MARK: - Previews

#Preview("Interests View") {
    OnboardingInterestsView {
        print("Continue tapped")
    }
}
