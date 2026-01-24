//
//  FormationDetailView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Full detail view for a formation using the unified detail design.
/// Fetches complete formation data from API to display all fields.
struct FormationDetailView: View {
    /// The formation from the list (partial data)
    let formation: Formation

    /// Navigation context for contact form pre-fill
    @Environment(\.navigationContext) private var navigationContext

    /// Full formation data loaded from API
    @State private var fullFormation: Formation?

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
            }
        }
        .task {
            await loadFullFormation()
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
            fullFormation = try await apiService.fetchFormation(slug: formation.slug)
        } catch {
            // Use partial data as fallback
            fullFormation = nil
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
            availableTabs: [.about, .prerequisites],
            ctaTitle: "Pré-inscription",
            ctaAction: { showPreRegistration = true },
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
