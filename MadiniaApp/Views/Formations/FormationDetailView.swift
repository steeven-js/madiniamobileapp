//
//  FormationDetailView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Full detail view for a formation.
/// Displays complete information including description, objectives, prerequisites, and program.
struct FormationDetailView: View {
    /// The formation to display details for
    let formation: Formation

    /// Navigation context for contact form pre-fill
    @Environment(\.navigationContext) private var navigationContext

    /// Controls the pre-registration alert (placeholder until Epic 3)
    @State private var showPreRegistration = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Section
                headerSection

                // Info Badges
                infoBadgesSection

                Divider()

                // Content Sections
                contentSections
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            ctaButton
        }
        .navigationTitle("Détail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                shareButton
            }
        }
        .sheet(isPresented: $showPreRegistration) {
            PreRegistrationSheet(formation: formation)
        }
        .onAppear {
            navigationContext.setFormation(formation)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category badge
            if let category = formation.category {
                let color = category.color.flatMap { Color(hex: $0) }
                InfoBadge(style: .category(category.name, color))
            }

            // Title
            Text(formation.title)
                .font(.title)
                .fontWeight(.bold)
                .accessibilityAddTraits(.isHeader)

            // Short description
            if let shortDesc = formation.shortDescription {
                Text(shortDesc)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Info Badges Section

    private var infoBadgesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                InfoBadge(style: .duration(formation.duration))
                InfoBadge(style: .level(formation.levelLabel, levelColor))
                if formation.certification == true {
                    InfoBadge(style: .certification)
                }
                if let hours = formation.durationHours {
                    InfoBadge(style: .duration("\(hours)h de formation"))
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(badgesAccessibilityLabel)
    }

    // MARK: - Content Sections

    @ViewBuilder
    private var contentSections: some View {
        // Description
        if let description = formation.description, !description.isEmpty {
            DetailSection(title: "Description", content: description, icon: "text.alignleft")
        }

        // Objectives
        if let objectives = formation.objectives, !objectives.isEmpty {
            DetailSection(title: "Objectifs", content: objectives, icon: "target")
        }

        // Prerequisites
        if let prerequisites = formation.prerequisites, !prerequisites.isEmpty {
            DetailSection(title: "Prérequis", content: prerequisites, icon: "checkmark.circle")
        }

        // Program
        if let program = formation.program, !program.isEmpty {
            DetailSection(title: "Programme", content: program, icon: "list.bullet.rectangle")
        }

        // Target Audience
        if let audience = formation.targetAudience, !audience.isEmpty {
            DetailSection(title: "Public cible", content: audience, icon: "person.2")
        }

        // Training Methods
        if let methods = formation.trainingMethods, !methods.isEmpty {
            DetailSection(title: "Méthodes pédagogiques", content: methods, icon: "lightbulb")
        }

        // PDF Download link
        if let pdfUrl = formation.pdfFileUrl, !pdfUrl.isEmpty {
            pdfDownloadSection(url: pdfUrl)
        }

        // Spacer for CTA button
        Spacer()
            .frame(height: 80)
    }

    // MARK: - PDF Download Section

    private func pdfDownloadSection(url: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Programme détaillé", systemImage: "doc.fill")
                .font(.headline)

            if let pdfURL = URL(string: url) {
                Link(destination: pdfURL) {
                    HStack {
                        Image(systemName: "arrow.down.doc")
                        Text("Télécharger le PDF")
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.accentColor)
                }
                .accessibilityLabel("Télécharger le programme détaillé en PDF")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - CTA Button

    private var ctaButton: some View {
        Button {
            showPreRegistration = true
        } label: {
            Text("Pré-inscription")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .accessibilityLabel("Se pré-inscrire à la formation \(formation.title)")
        .accessibilityHint("Ouvre le formulaire de pré-inscription")
    }

    // MARK: - Share Button

    private var shareButton: some View {
        ShareLink(
            item: shareURL,
            subject: Text(formation.title),
            message: Text("Découvrez cette formation: \(formation.title)")
        ) {
            Image(systemName: "square.and.arrow.up")
        }
        .accessibilityLabel("Partager cette formation")
    }

    // MARK: - Computed Properties

    private var levelColor: Color {
        switch formation.level.lowercased() {
        case "debutant": return .green
        case "intermediaire": return .orange
        case "avance", "expert": return .red
        default: return .blue
        }
    }

    private var shareURL: URL {
        URL(string: "https://madinia.fr/formations/\(formation.slug)") ??
        URL(string: "https://madinia.fr")!
    }

    private var badgesAccessibilityLabel: String {
        var parts: [String] = []
        parts.append("Durée: \(formation.duration)")
        parts.append("Niveau: \(formation.levelLabel)")
        if formation.certification == true {
            parts.append("Formation certifiante")
        }
        return parts.joined(separator: ", ")
    }
}

// MARK: - Detail Section Component

/// Reusable section component for formation detail content
struct DetailSection: View {
    let title: String
    let content: String
    var icon: String = "info.circle"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)

            // Content - strip HTML tags for display
            Text(strippedContent)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
    }

    /// Strips basic HTML tags from content for display
    private var strippedContent: String {
        var result = content
        // Remove common HTML tags
        let patterns = ["<[^>]+>", "&nbsp;", "&amp;", "&lt;", "&gt;", "&quot;"]
        let replacements = ["", " ", "&", "<", ">", "\""]

        for (pattern, replacement) in zip(patterns, replacements) {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(result.startIndex..., in: result)
                result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: replacement)
            }
        }

        // Clean up multiple spaces and newlines
        result = result.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Previews

#Preview("Full Detail") {
    NavigationStack {
        FormationDetailView(formation: Formation(
            id: 1,
            title: "Starter Pack - IA Générative",
            slug: "starter-pack-ia-generative",
            shortDescription: "Découvrez les fondamentaux de l'IA générative et apprenez à utiliser les outils modernes.",
            duration: "14 heures",
            durationHours: 14,
            level: "debutant",
            levelLabel: "Débutant",
            certification: false,
            certificationLabel: "Non certifiante",
            imageUrl: nil,
            category: FormationCategory(id: 1, name: "IA Générative", slug: "ia-generative", color: "#8B5CF6", icon: nil),
            description: "Cette formation vous permettra de maîtriser les bases de l'intelligence artificielle générative. Vous apprendrez à utiliser ChatGPT, Midjourney et d'autres outils pour améliorer votre productivité.",
            objectives: "• Comprendre les principes de l'IA générative\n• Maîtriser le prompt engineering\n• Créer du contenu avec l'IA",
            prerequisites: "Aucun prérequis technique. Une curiosité pour les nouvelles technologies est un plus.",
            program: "Module 1: Introduction à l'IA\nModule 2: ChatGPT avancé\nModule 3: Création d'images\nModule 4: Automatisation",
            targetAudience: "Professionnels souhaitant intégrer l'IA dans leur quotidien",
            trainingMethods: "Formation en ligne avec exercices pratiques",
            pdfFileUrl: "https://madinia.fr/formations/starter-pack.pdf",
            viewsCount: 150,
            publishedAt: "2026-01-15"
        ))
    }
}

#Preview("Minimal Detail") {
    NavigationStack {
        FormationDetailView(formation: .sample)
    }
}
