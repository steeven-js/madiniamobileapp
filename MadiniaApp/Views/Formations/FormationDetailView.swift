//
//  FormationDetailView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

// MARK: - Sheet Wrapper

/// Wrapper view for presenting FormationDetailView in a sheet.
/// Manages its own state to allow replacing the current formation without stacking sheets.
struct FormationDetailSheetView: View {
    /// Initial formation to display
    let initialFormation: Formation

    /// Current formation being displayed (can change when tapping related)
    @State private var currentFormation: Formation

    /// Environment dismiss
    @Environment(\.dismiss) private var dismiss

    init(formation: Formation) {
        self.initialFormation = formation
        self._currentFormation = State(initialValue: formation)
    }

    var body: some View {
        NavigationStack {
            FormationDetailView(
                formation: currentFormation,
                onRelatedFormationTap: { newFormation in
                    // Replace current formation instead of opening new sheet
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentFormation = newFormation
                    }
                }
            )
        }
        .id(currentFormation.id) // Force view refresh when formation changes
    }
}

// MARK: - Main View

/// Full detail view for a formation using the unified detail design.
/// Fetches complete formation data from API to display all fields.
struct FormationDetailView: View {
    /// The formation from the list (partial data)
    let formation: Formation

    /// Optional callback for related formation tap (used in sheet mode)
    var onRelatedFormationTap: ((Formation) -> Void)?

    /// Navigation context for contact form pre-fill
    @Environment(\.navigationContext) private var navigationContext

    /// Full formation data loaded from API
    @State private var fullFormation: Formation?

    /// Related formations from API
    @State private var relatedFormations: [Formation] = []

    /// Selected related formation for navigation (only used when not in sheet mode)
    @State private var selectedRelatedFormation: Formation?

    /// Loading state
    @State private var isLoading = true

    /// Error message
    @State private var errorMessage: String?

    /// Controls the pre-registration sheet
    @State private var showPreRegistration = false

    /// API service
    private let apiService = APIService.shared

    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if let error = errorMessage {
                errorView(message: error)
            } else {
                UnifiedDetailView(config: configuration)
                    .sheet(isPresented: $showPreRegistration) {
                        PreRegistrationSheet(formation: displayFormation)
                    }
                    .sheet(item: $selectedRelatedFormation) { relatedFormation in
                        FormationDetailSheetView(formation: relatedFormation)
                    }
            }
        }
        .task(id: formation.id) {
            await loadFullFormation()
        }
        .onChange(of: formation.id) { _, _ in
            // Reset state when formation changes (for sheet replacement)
            fullFormation = nil
            relatedFormations = []
            isLoading = true
        }
        .onAppear {
            navigationContext.setFormation(formation)
        }
    }

    // MARK: - Views

    private var loadingView: some View {
        ZStack {
            Color(.systemBackground)
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                Text("Chargement...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationBarHidden(true)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Réessayer") {
                Task { await loadFullFormation() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: - Data Loading

    @MainActor
    private func loadFullFormation() async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await apiService.fetchFormationWithRelated(slug: formation.slug)
            fullFormation = result.formation
            relatedFormations = result.related
        } catch {
            // Use partial data as fallback
            fullFormation = nil
            relatedFormations = []
            #if DEBUG
            print("Failed to load full formation: \(error)")
            #endif
        }

        isLoading = false
    }

    // MARK: - Configuration

    /// Use full formation if available, otherwise use partial data
    private var displayFormation: Formation {
        fullFormation ?? formation
    }

    private var configuration: DetailViewConfiguration {
        let f = displayFormation
        // Show related tab only if there are related formations
        let tabs: [DetailTab] = relatedFormations.isEmpty
            ? [.about, .prerequisites]
            : [.about, .prerequisites, .related]

        return DetailViewConfiguration(
            title: f.title,
            subtitle: f.shortDescription,
            imageUrl: f.imageUrl,
            viewsCount: f.viewsCount,
            duration: formattedDuration,
            level: f.levelLabel,
            certification: f.certificationLabel,
            description: f.description ?? f.shortDescription,
            objectives: f.objectives,
            prerequisites: f.prerequisites,
            targetAudience: f.targetAudience,
            trainingMethods: f.trainingMethods,
            relatedFormations: relatedFormations,
            availableTabs: tabs,
            ctaTitle: "Pré-inscription",
            ctaAction: { showPreRegistration = true },
            onRelatedFormationTap: { tappedFormation in
                // If we have a callback (sheet mode), use it to replace current formation
                // Otherwise, open a new sheet
                if let callback = onRelatedFormationTap {
                    callback(tappedFormation)
                } else {
                    selectedRelatedFormation = tappedFormation
                }
            },
            shareUrl: shareURL
        )
    }

    private var formattedDuration: String {
        let f = displayFormation
        if let hours = f.durationHours {
            return "\(hours) heures"
        }
        return f.duration
    }

    private var shareURL: URL {
        URL(string: "https://madinia.fr/formations/\(formation.slug)") ??
        URL(string: "https://madinia.fr")!
    }
}

// MARK: - Previews

#Preview("Full Detail") {
    NavigationStack {
        FormationDetailView(formation: Formation(
            id: 1,
            title: "Starter Pack - IA Générative",
            slug: "starter-pack-ia-generative",
            shortDescription: "Découvrez les fondamentaux de l'IA générative.",
            duration: "14 heures",
            durationHours: 14,
            level: "debutant",
            levelLabel: "Débutant",
            certification: false,
            certificationLabel: "Non certifiante",
            imageUrl: nil,
            category: FormationCategory(id: 1, name: "IA Générative", slug: "ia-generative", color: "#8B5CF6", icon: nil),
            description: nil,
            objectives: nil,
            prerequisites: nil,
            program: nil,
            targetAudience: nil,
            trainingMethods: nil,
            pdfFileUrl: nil,
            viewsCount: 150,
            publishedAt: "2026-01-15"
        ))
    }
}
