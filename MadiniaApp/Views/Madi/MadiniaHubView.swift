//
//  MadiniaHubView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// Hub view containing all Madinia-related content: Blog, About, and News.
/// Uses a segmented tab control at the top for navigation between sections.
struct MadiniaHubView: View {
    /// Currently selected tab - default to About since Blog/News have no content yet
    @State private var selectedTab: HubTab = .about

    var body: some View {
        NavigationStack {
            tabContent
                .safeAreaInset(edge: .top, spacing: 0) {
                    tabSelector
                        .background(.regularMaterial)
                }
                .navigationTitle("Madin.IA")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(HubTab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, MadiniaSpacing.md)
        .padding(.vertical, MadiniaSpacing.sm)
    }

    private func tabButton(for tab: HubTab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: MadiniaSpacing.sm) {
                Text(tab.title)
                    .font(MadiniaTypography.headline)
                    .foregroundStyle(selectedTab == tab ? MadiniaColors.darkGray : .secondary)

                // Underline indicator
                Rectangle()
                    .fill(selectedTab == tab ? MadiniaColors.gold : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .about:
            aboutContent
        case .blog:
            blogContent
        case .news:
            newsContent
        }
    }

    // MARK: - Blog Content

    private var blogContent: some View {
        ScrollView {
            VStack(spacing: MadiniaSpacing.lg) {
                ContentUnavailableView {
                    Label("Blog", systemImage: "doc.text.fill")
                } description: {
                    Text("Nos articles de blog arrivent bientôt !\n\nRetrouvez ici nos conseils, tutoriels et actualités sur l'Intelligence Artificielle.")
                }
                .padding(.top, MadiniaSpacing.xl)
            }
            .padding(MadiniaSpacing.md)
        }
    }

    // MARK: - About Content

    private var aboutContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MadiniaSpacing.lg) {
                // Hero section
                VStack(spacing: MadiniaSpacing.md) {
                    Image("madinia-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.lg))

                    Text("Madin.IA")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(MadiniaColors.darkGray)

                    Text("Former vous à l'Intelligence Artificielle")
                        .font(MadiniaTypography.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, MadiniaSpacing.xl)

                // About sections
                aboutSection(
                    icon: "target",
                    title: "Notre Mission",
                    content: "Démocratiser l'accès à la formation en Intelligence Artificielle pour tous les professionnels souhaitant développer leurs compétences."
                )

                aboutSection(
                    icon: "lightbulb.fill",
                    title: "Notre Vision",
                    content: "Devenir la référence de la formation IA accessible et pratique, en accompagnant chaque apprenant dans son parcours de montée en compétences."
                )

                aboutSection(
                    icon: "person.3.fill",
                    title: "Notre Équipe",
                    content: "Une équipe passionnée d'experts en IA et en pédagogie, dédiée à créer des formations de qualité adaptées aux besoins du marché."
                )

                // Contact CTA
                VStack(spacing: MadiniaSpacing.md) {
                    Text("Une question ?")
                        .font(MadiniaTypography.headline)
                        .foregroundStyle(MadiniaColors.darkGray)

                    Text("N'hésitez pas à nous contacter pour en savoir plus sur nos formations.")
                        .font(MadiniaTypography.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(MadiniaSpacing.lg)
                .background(MadiniaColors.gold.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.lg))
            }
            .padding(MadiniaSpacing.md)
        }
    }

    private func aboutSection(icon: String, title: String, content: String) -> some View {
        HStack(alignment: .top, spacing: MadiniaSpacing.md) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(MadiniaColors.gold)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: MadiniaSpacing.xs) {
                Text(title)
                    .font(MadiniaTypography.headline)
                    .foregroundStyle(MadiniaColors.darkGray)

                Text(content)
                    .font(MadiniaTypography.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(MadiniaSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - News Content

    private var newsContent: some View {
        ScrollView {
            VStack(spacing: MadiniaSpacing.lg) {
                ContentUnavailableView {
                    Label("Actualités", systemImage: "newspaper.fill")
                } description: {
                    Text("Les actualités Madin.IA arrivent bientôt !\n\nSuivez nos dernières nouvelles, événements et annonces ici.")
                }
                .padding(.top, MadiniaSpacing.xl)
            }
            .padding(MadiniaSpacing.md)
        }
    }
}

// MARK: - Hub Tab Enum

enum HubTab: String, CaseIterable {
    case about
    case blog
    case news

    var title: String {
        switch self {
        case .about: return "À propos"
        case .blog: return "Blog"
        case .news: return "Actualités"
        }
    }
}

// MARK: - Previews

#Preview {
    MadiniaHubView()
}

#Preview("About Tab") {
    MadiniaHubView()
}
