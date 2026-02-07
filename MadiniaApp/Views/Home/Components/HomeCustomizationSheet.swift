//
//  HomeCustomizationSheet.swift
//  MadiniaApp
//
//  Feuille de personnalisation de l'écran d'accueil.
//  Permet de réorganiser et masquer les sections.
//

import SwiftUI

/// Sheet de personnalisation de l'écran d'accueil
struct HomeCustomizationSheet: View {
    @Environment(\.dismiss) private var dismiss

    /// Service de préférences
    private let preferencesService = HomePreferencesService.shared

    /// État local pour l'édition
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationStack {
            List {
                // Instructions
                Section {
                    VStack(alignment: .leading, spacing: MadiniaSpacing.xs) {
                        Label("Personnalisez votre accueil", systemImage: "sparkles")
                            .font(MadiniaTypography.headline)
                            .foregroundStyle(MadiniaColors.accent)

                        Text("Activez ou désactivez les sections et réorganisez-les selon vos préférences.")
                            .font(MadiniaTypography.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, MadiniaSpacing.xs)
                }

                // Sections visibles
                Section("Sections visibles") {
                    ForEach(visibleSections) { pref in
                        SectionRow(preference: pref, isVisible: true) {
                            preferencesService.toggleSection(pref.section)
                        }
                    }
                    .onMove { source, destination in
                        preferencesService.moveSection(from: source, to: destination)
                    }
                }

                // Sections masquées
                if !hiddenSections.isEmpty {
                    Section("Sections masquées") {
                        ForEach(hiddenSections) { pref in
                            SectionRow(preference: pref, isVisible: false) {
                                preferencesService.toggleSection(pref.section)
                            }
                        }
                    }
                }

                // Reset button
                if preferencesService.hasCustomizations {
                    Section {
                        Button(role: .destructive) {
                            preferencesService.resetToDefaults()
                        } label: {
                            Label("Réinitialiser", systemImage: "arrow.counterclockwise")
                        }
                    }
                }
            }
            .navigationTitle("Personnaliser")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    EditButton()
                }
            }
            .environment(\.editMode, $editMode)
        }
    }

    // MARK: - Computed Properties

    private var visibleSections: [HomeSectionPreference] {
        preferencesService.sectionPreferences
            .filter { $0.isVisible }
            .sorted { $0.order < $1.order }
    }

    private var hiddenSections: [HomeSectionPreference] {
        preferencesService.sectionPreferences
            .filter { !$0.isVisible }
            .sorted { $0.order < $1.order }
    }
}

// MARK: - Section Row

/// Ligne représentant une section dans la liste de personnalisation
private struct SectionRow: View {
    let preference: HomeSectionPreference
    let isVisible: Bool
    var onToggle: (() -> Void)?

    var body: some View {
        HStack(spacing: MadiniaSpacing.sm) {
            // Icon
            Image(systemName: preference.section.icon)
                .font(.system(size: 18))
                .foregroundStyle(isVisible ? MadiniaColors.accent : .secondary)
                .frame(width: 28)

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(preference.section.displayTitle)
                    .font(MadiniaTypography.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(isVisible ? .primary : .secondary)

                Text(preference.section.description)
                    .font(MadiniaTypography.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            // Toggle
            Button {
                onToggle?()
            } label: {
                Image(systemName: isVisible ? "eye.fill" : "eye.slash")
                    .font(.system(size: 16))
                    .foregroundStyle(isVisible ? MadiniaColors.accent : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, MadiniaSpacing.xxs)
        .contentShape(Rectangle())
    }
}

// MARK: - Previews

#Preview("Customization Sheet") {
    HomeCustomizationSheet()
}
