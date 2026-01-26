//
//  UnifiedDetailView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// Tab options for the detail view
enum DetailTab: String, CaseIterable {
    case about = "À propos"
    case prerequisites = "Prérequis"
    case related = "Similaires"
}

/// Configuration for the unified detail view
struct DetailViewConfiguration {
    let title: String
    let subtitle: String?
    let imageUrl: String?
    let viewsCount: Int?
    let duration: String?
    let level: String?
    let certification: String?
    let description: String?
    let objectives: String?
    let prerequisites: String?
    let targetAudience: String?
    let trainingMethods: String?
    let relatedFormations: [Formation]
    let availableTabs: [DetailTab]
    let ctaTitle: String
    let ctaAction: () -> Void
    let onRelatedFormationTap: ((Formation) -> Void)?
    let shareUrl: URL?
    let formationId: Int?

    init(
        title: String,
        subtitle: String? = nil,
        imageUrl: String? = nil,
        viewsCount: Int? = nil,
        duration: String? = nil,
        level: String? = nil,
        certification: String? = nil,
        description: String? = nil,
        objectives: String? = nil,
        prerequisites: String? = nil,
        targetAudience: String? = nil,
        trainingMethods: String? = nil,
        relatedFormations: [Formation] = [],
        availableTabs: [DetailTab] = [.about, .prerequisites],
        ctaTitle: String = "S'inscrire",
        ctaAction: @escaping () -> Void = {},
        onRelatedFormationTap: ((Formation) -> Void)? = nil,
        shareUrl: URL? = nil,
        formationId: Int? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.viewsCount = viewsCount
        self.duration = duration
        self.level = level
        self.certification = certification
        self.description = description
        self.objectives = objectives
        self.prerequisites = prerequisites
        self.targetAudience = targetAudience
        self.trainingMethods = trainingMethods
        self.relatedFormations = relatedFormations
        self.availableTabs = availableTabs
        self.ctaTitle = ctaTitle
        self.ctaAction = ctaAction
        self.onRelatedFormationTap = onRelatedFormationTap
        self.shareUrl = shareUrl
        self.formationId = formationId
    }
}

/// Unified detail view following Figma design "20 Course Details-2 version"
struct UnifiedDetailView: View {
    let config: DetailViewConfiguration

    @State private var selectedTab: DetailTab = .about
    @State private var showFullScreenImage: Bool = false
    @Environment(\.dismiss) private var dismiss

    /// Computed property to check if current formation is favorite
    private var isFavorite: Bool {
        guard let formationId = config.formationId else { return false }
        return FavoritesService.shared.isFavorite(formationId: formationId)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main scroll content
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero Section - Full width image with dark background
                    heroSection

                    // Content on white background
                    VStack(alignment: .leading, spacing: 0) {
                        // Title
                        Text(config.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)

                        // Info Row (views count, duration, level, certification)
                        if config.viewsCount != nil || config.duration != nil || config.level != nil || config.certification != nil {
                            infoRow
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                        }

                        // Tab Bar
                        tabBar
                            .padding(.top, 20)

                        // Tab Content
                        tabContent
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 180) // Extra space for CTA button + tab bar
                    }
                    .background(Color(.systemBackground))
                }
            }
            .ignoresSafeArea(edges: .top)

            // CTA Button
            ctaButton
        }
        .navigationBarHidden(true)
        .background(Color(.systemBackground))
        .fullScreenCover(isPresented: $showFullScreenImage) {
            FullScreenImageViewer(
                imageUrl: config.imageUrl,
                isPresented: $showFullScreenImage
            )
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark background
                Color(red: 0.15, green: 0.15, blue: 0.2)

                // Image positioned towards bottom, taking available height
                VStack(spacing: 0) {
                    // Top spacing for nav buttons (safe area + button height)
                    Spacer()
                        .frame(height: 100)

                    // Image content (real or placeholder) - fills remaining space
                    heroImageContent(availableWidth: geometry.size.width)
                        .onTapGesture {
                            showFullScreenImage = true
                        }

                    // Small bottom padding
                    Spacer()
                        .frame(height: 20)
                }

                // Back button (top-left)
                VStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 50) // Safe area offset
                    Spacer()
                }

                // Favorite button (bottom-left, large) - only show for formations
                if config.formationId != nil {
                    VStack {
                        Spacer()
                        HStack {
                            Button {
                                guard let formationId = config.formationId else { return }
                                Task {
                                    await FavoritesService.shared.toggleFavorite(formationId: formationId)
                                }
                            } label: {
                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundStyle(isFavorite ? .red : .white)
                                    .frame(width: 56, height: 56)
                                    .background(Color.black.opacity(0.4))
                                    .clipShape(Circle())
                                    .animation(.spring(response: 0.3), value: isFavorite)
                            }
                            .padding(.leading, 20)
                            .padding(.bottom, 16)
                            Spacer()
                        }
                    }
                }
            }
        }
        .frame(height: 380)
    }

    /// Hero image content with expand icon overlay
    @ViewBuilder
    private func heroImageContent(availableWidth: CGFloat) -> some View {
        let imageWidth = availableWidth - 40 // 20px padding on each side
        let imageHeight: CGFloat = 260 // Taller image

        ZStack(alignment: .bottomTrailing) {
            if let imageUrl = config.imageUrl, let url = URL(string: imageUrl) {
                // Real image from API
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .tint(.white)
                            .frame(width: imageWidth, height: imageHeight)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: imageWidth, maxHeight: imageHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    case .failure:
                        placeholderImage(width: imageWidth, height: imageHeight)
                    @unknown default:
                        placeholderImage(width: imageWidth, height: imageHeight)
                    }
                }
            } else {
                // Placeholder when no image URL
                placeholderImage(width: imageWidth, height: imageHeight)
            }

            // Expand icon indicator
            expandIcon
        }
    }

    /// Expand icon overlay to indicate tap-to-zoom
    private var expandIcon: some View {
        Image(systemName: "arrow.up.left.and.arrow.down.right")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.white)
            .padding(8)
            .background(Color.black.opacity(0.5))
            .clipShape(Circle())
            .padding(12)
    }

    private func placeholderImage(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.4, green: 0.5, blue: 0.9),
                        Color(red: 0.6, green: 0.7, blue: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: width, height: height)
            .overlay {
                // Decorative circles like in Figma
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 100, height: 100)
                        .offset(x: -60, y: -40)

                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 60, height: 60)
                        .offset(x: 80, y: 60)

                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 40, height: 40)
                        .offset(x: 50, y: -50)

                    // Main icon
                    Image(systemName: "book.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
    }

    // MARK: - Info Row

    private var infoRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            // First row: views, duration
            HStack(spacing: 12) {
                if let viewsCount = config.viewsCount, viewsCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(MadiniaColors.violet)
                        Text("\(viewsCount) vues")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }

                if let duration = config.duration {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(MadiniaColors.violet)
                        Text(duration)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Second row: level, certification badges
            if config.level != nil || config.certification != nil {
                HStack(spacing: 8) {
                    if let level = config.level {
                        infoBadge(icon: "chart.bar.fill", text: level)
                    }

                    if let certification = config.certification {
                        infoBadge(icon: "checkmark.seal.fill", text: certification)
                    }
                }
            }
        }
    }

    private func infoBadge(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
            Text(text)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundStyle(MadiniaColors.violet)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(MadiniaColors.violet.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(config.availableTabs, id: \.self) { tab in
                    tabButton(for: tab)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func tabButton(for tab: DetailTab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            Text(tab.rawValue.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(selectedTab == tab ? MadiniaColors.violet : .secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedTab == tab ? MadiniaColors.violet : Color.clear, lineWidth: 1.5)
                )
        }
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .about:
            aboutContent
        case .prerequisites:
            prerequisitesContent
        case .related:
            relatedContent
        }
    }

    /// Tab 1: À propos - Description, Objectifs, Public cible
    private var aboutContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Description
            if let description = config.description {
                Text("Description")
                    .font(.system(size: 18, weight: .bold))

                Text(stripHTML(from: description))
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
                    .lineSpacing(4)
            }

            // Objectives
            if let objectives = config.objectives {
                Text("Objectifs")
                    .font(.system(size: 18, weight: .bold))
                    .padding(.top, 8)

                Text(stripHTML(from: objectives))
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
                    .lineSpacing(4)
            }

            // Target Audience
            if let targetAudience = config.targetAudience {
                Text("Public cible")
                    .font(.system(size: 18, weight: .bold))
                    .padding(.top, 8)

                Text(stripHTML(from: targetAudience))
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
                    .lineSpacing(4)
            }
        }
    }

    /// Tab 2: Prérequis - Prérequis, Méthodes pédagogiques
    private var prerequisitesContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Prerequisites
            if let prerequisites = config.prerequisites {
                Text("Prérequis")
                    .font(.system(size: 18, weight: .bold))

                Text(stripHTML(from: prerequisites))
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
                    .lineSpacing(4)
            } else {
                Text("Prérequis")
                    .font(.system(size: 18, weight: .bold))

                Text("Aucun prérequis")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }

            // Training Methods
            if let trainingMethods = config.trainingMethods {
                Text("Méthodes pédagogiques")
                    .font(.system(size: 18, weight: .bold))
                    .padding(.top, 8)

                Text(stripHTML(from: trainingMethods))
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
                    .lineSpacing(4)
            }
        }
    }

    /// Tab 3: Similaires - Formations liées
    private var relatedContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Formations similaires")
                .font(.system(size: 18, weight: .bold))

            if config.relatedFormations.isEmpty {
                Text("Aucune formation similaire")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(config.relatedFormations) { formation in
                        TopRatedCard(formation: formation) {
                            config.onRelatedFormationTap?(formation)
                        }
                    }
                }
            }
        }
    }

    // MARK: - CTA Button

    private var ctaButton: some View {
        Button(action: config.ctaAction) {
            Text(config.ctaTitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(MadiniaColors.darkGrayFixed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(MadiniaColors.gold)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.leading, 20)
        .padding(.trailing, 88) // Leave space for Madi FAB on the right
        .padding(.bottom, 100) // Account for custom tab bar height
        .background(
            LinearGradient(
                colors: [Color(.systemBackground).opacity(0), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        )
    }

    // MARK: - Helpers

    private func stripHTML(from content: String) -> String {
        var result = content
        let patterns = ["<[^>]+>", "&nbsp;", "&amp;", "&lt;", "&gt;", "&quot;", "&#039;"]
        let replacements = ["", " ", "&", "<", ">", "\"", "'"]

        for (pattern, replacement) in zip(patterns, replacements) {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(result.startIndex..., in: result)
                result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: replacement)
            }
        }

        result = result.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Preview

#Preview("Formation Detail") {
    UnifiedDetailView(config: DetailViewConfiguration(
        title: "Assistant administratif et IA : nouvelles compétences au service de l'organisation",
        subtitle: nil,
        imageUrl: nil,
        viewsCount: 2719,
        duration: "14 heures",
        description: "Utilisez l'IA pour transformer votre rôle d'assistant administratif et gagner en efficacité au quotidien.",
        objectives: "• Comprendre les principes de l'IA\n• Maîtriser le prompt engineering",
        prerequisites: "Aucun prérequis technique",
        targetAudience: "Assistants administratifs souhaitant intégrer l'IA dans leur quotidien",
        trainingMethods: "Formation en ligne avec exercices pratiques et cas concrets",
        availableTabs: [.about, .prerequisites],
        ctaTitle: "Pré-inscription"
    ))
}

#Preview("Service Detail") {
    UnifiedDetailView(config: DetailViewConfiguration(
        title: "Conférences IA",
        subtitle: nil,
        imageUrl: nil,
        description: "Nos conférences permettent de sensibiliser vos équipes aux enjeux de l'intelligence artificielle.",
        availableTabs: [.about],
        ctaTitle: "Nous contacter"
    ))
}
