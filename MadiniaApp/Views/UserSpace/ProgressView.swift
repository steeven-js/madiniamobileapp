//
//  ProgressView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-07.
//

import SwiftUI

/// Tab options for progress view
enum ProgressTab: String, CaseIterable {
    case overview = "Aperçu"
    case badges = "Badges"
    case history = "Historique"
}

/// Main progress tracking view with 3 tabs
struct UserProgressView: View {
    @State private var selectedTab: ProgressTab = .overview

    private var progressService: ProgressTrackingService {
        ProgressTrackingService.shared
    }

    var body: some View {
        ScrollView {
            VStack(spacing: MadiniaSpacing.lg) {
                // Tab selector
                tabSelector

                // Tab content
                switch selectedTab {
                case .overview:
                    overviewContent
                case .badges:
                    badgesContent
                case .history:
                    historyContent
                }
            }
            .padding(MadiniaSpacing.md)
            .tabBarSafeArea()
        }
        .navigationTitle("Ma progression")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            // Refresh achievements on appear
            progressService.checkAndUnlockAchievements()
        }
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(ProgressTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(selectedTab == tab ? .white : .secondary)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedTab == tab ? MadiniaColors.accent : Color.clear)
                        )
                }
            }
        }
        .padding(4)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Overview Tab

    private var overviewContent: some View {
        VStack(spacing: MadiniaSpacing.lg) {
            // Main stats grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: MadiniaSpacing.md) {
                StatCard(
                    icon: "eye.fill",
                    value: "\(progressService.statistics.uniqueFormationsViewed)",
                    label: "Formations vues"
                )

                StatCard(
                    icon: "flame.fill",
                    value: "\(progressService.statistics.currentStreak)",
                    label: "Jours consécutifs",
                    iconColor: .orange
                )

                StatCard(
                    icon: "square.grid.2x2.fill",
                    value: "\(progressService.statistics.categoriesCount)",
                    label: "Catégories explorées"
                )

                StatCard(
                    icon: "clock.fill",
                    value: formatTime(progressService.statistics.totalTimeSpentMinutes),
                    label: "Temps total"
                )
            }

            // Weekly activity chart
            WeeklyActivitySimple(data: progressService.getWeeklyActivityData())

            // Recent achievements
            if !progressService.unlockedAchievements().isEmpty {
                VStack(alignment: .leading, spacing: MadiniaSpacing.md) {
                    HStack {
                        Text("Badges récents")
                            .font(MadiniaTypography.headline)

                        Spacer()

                        Button {
                            withAnimation {
                                selectedTab = .badges
                            }
                        } label: {
                            Text("Voir tout")
                                .font(MadiniaTypography.caption)
                                .foregroundStyle(MadiniaColors.accent)
                        }
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: MadiniaSpacing.md) {
                            ForEach(progressService.unlockedAchievements().prefix(4)) { achievement in
                                AchievementBadge(achievement: achievement, size: 70)
                            }
                        }
                    }
                }
                .padding(MadiniaSpacing.md)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
            }

            // Streak info
            if progressService.statistics.longestStreak > 0 {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(MadiniaColors.goldTier)
                    Text("Record: \(progressService.statistics.longestStreak) jours consécutifs")
                        .font(MadiniaTypography.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(MadiniaSpacing.md)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
            }
        }
    }

    // MARK: - Badges Tab

    private var badgesContent: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.lg) {
            // Unlocked count
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(MadiniaColors.accent)
                Text("\(progressService.unlockedAchievements().count)/\(progressService.achievements.count) badges débloqués")
                    .font(MadiniaTypography.headline)
                Spacer()
            }

            // Badge grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: MadiniaSpacing.lg) {
                ForEach(progressService.achievements) { achievement in
                    AchievementBadge(achievement: achievement, size: 80)
                }
            }

            // Achievement list with details
            VStack(spacing: MadiniaSpacing.sm) {
                ForEach(progressService.achievements.sorted { ($0.unlockedAt ?? .distantFuture) > ($1.unlockedAt ?? .distantFuture) }) { achievement in
                    AchievementListItem(achievement: achievement)
                }
            }
        }
    }

    // MARK: - History Tab

    private var historyContent: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.md) {
            if progressService.getFormationHistory().isEmpty {
                emptyHistoryView
            } else {
                ForEach(progressService.getFormationHistory()) { progress in
                    FormationHistoryCard(progress: progress)
                }
            }
        }
    }

    private var emptyHistoryView: some View {
        VStack(spacing: MadiniaSpacing.md) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Aucune formation consultée")
                .font(MadiniaTypography.headline)
                .foregroundStyle(.secondary)

            Text("Vos formations consultées apparaîtront ici")
                .font(MadiniaTypography.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MadiniaSpacing.xxl)
    }

    // MARK: - Helpers

    private func formatTime(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)min"
        }
        let hours = minutes / 60
        let mins = minutes % 60
        if mins == 0 {
            return "\(hours)h"
        }
        return "\(hours)h\(mins)"
    }
}

// MARK: - Formation History Card

struct FormationHistoryCard: View {
    let progress: FormationProgress

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }

    var body: some View {
        HStack(spacing: MadiniaSpacing.md) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(MadiniaColors.accent.opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: "book.fill")
                    .foregroundStyle(MadiniaColors.accent)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(progress.formationTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                HStack(spacing: MadiniaSpacing.sm) {
                    if let category = progress.categoryName {
                        Text(category)
                            .font(.system(size: 11))
                            .foregroundStyle(MadiniaColors.accent)
                    }

                    Text("• \(progress.viewCount) vue\(progress.viewCount > 1 ? "s" : "")")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Text(dateFormatter.string(from: progress.lastViewedAt))
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(MadiniaSpacing.sm)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.sm))
    }
}

// MARK: - Previews

#Preview("Progress View") {
    NavigationStack {
        UserProgressView()
    }
}

#Preview("Progress View - Dark") {
    NavigationStack {
        UserProgressView()
    }
    .preferredColorScheme(.dark)
}
