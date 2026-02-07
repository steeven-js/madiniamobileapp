//
//  HistoryView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-07.
//

import SwiftUI

/// Standalone history view for viewing formation history
struct HistoryView: View {
    private var contextService: MadiContextService {
        MadiContextService.shared
    }

    private var progressService: ProgressTrackingService {
        ProgressTrackingService.shared
    }

    private var groupedHistory: [(String, [ViewedFormation])] {
        let formations = contextService.viewedFormations
        let grouped = Dictionary(grouping: formations) { formation in
            formatDateGroup(formation.viewedAt)
        }

        // Sort by date (most recent first)
        return grouped.sorted { pair1, pair2 in
            guard let date1 = formations.first(where: { formatDateGroup($0.viewedAt) == pair1.key })?.viewedAt,
                  let date2 = formations.first(where: { formatDateGroup($0.viewedAt) == pair2.key })?.viewedAt else {
                return false
            }
            return date1 > date2
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: MadiniaSpacing.lg) {
                if contextService.viewedFormations.isEmpty {
                    emptyStateView
                } else {
                    // Stats summary
                    statsSummary

                    // Grouped history
                    ForEach(groupedHistory, id: \.0) { group in
                        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
                            Text(group.0)
                                .font(MadiniaTypography.headline)
                                .foregroundStyle(.primary)
                                .padding(.horizontal, MadiniaSpacing.xs)

                            ForEach(group.1, id: \.formationId) { formation in
                                HistoryItemCard(formation: formation)
                            }
                        }
                    }
                }
            }
            .padding(MadiniaSpacing.md)
            .tabBarSafeArea()
        }
        .navigationTitle("Historique")
        .navigationBarTitleDisplayMode(.large)
    }

    private var statsSummary: some View {
        HStack(spacing: MadiniaSpacing.md) {
            StatRow(
                icon: "eye.fill",
                value: "\(contextService.viewedFormations.count)",
                label: "Consultations"
            )

            StatRow(
                icon: "book.fill",
                value: "\(Set(contextService.viewedFormations.map { $0.formationId }).count)",
                label: "Formations uniques"
            )
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: MadiniaSpacing.lg) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            VStack(spacing: MadiniaSpacing.xs) {
                Text("Aucun historique")
                    .font(MadiniaTypography.title2)
                    .foregroundStyle(.primary)

                Text("Les formations que vous consulterez apparaîtront ici")
                    .font(MadiniaTypography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            NavigationLink {
                // Navigate to formations
            } label: {
                Text("Découvrir les formations")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(MadiniaColors.darkGrayFixed)
                    .padding(.horizontal, MadiniaSpacing.lg)
                    .padding(.vertical, MadiniaSpacing.sm)
                    .background(MadiniaColors.accent)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MadiniaSpacing.xxl)
    }

    private func formatDateGroup(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Aujourd'hui"
        } else if calendar.isDateInYesterday(date) {
            return "Hier"
        } else if let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()),
                  date > weekAgo {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            formatter.locale = Locale(identifier: "fr_FR")
            return formatter.string(from: date).capitalized
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.locale = Locale(identifier: "fr_FR")
            return formatter.string(from: date)
        }
    }
}

// MARK: - History Item Card

struct HistoryItemCard: View {
    let formation: ViewedFormation

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }

    var body: some View {
        HStack(spacing: MadiniaSpacing.md) {
            // Time badge
            Text(timeFormatter.string(from: formation.viewedAt))
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 45)

            // Vertical line
            Rectangle()
                .fill(MadiniaColors.accent.opacity(0.3))
                .frame(width: 2)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(formation.formationTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                if let category = formation.categoryName {
                    Text(category)
                        .font(.system(size: 12))
                        .foregroundStyle(MadiniaColors.accent)
                }
            }

            Spacer()

            // Chevron for navigation
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(MadiniaSpacing.sm)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.sm))
    }
}

// MARK: - Previews

#Preview("History View") {
    NavigationStack {
        HistoryView()
    }
}

#Preview("History View - Empty") {
    NavigationStack {
        HistoryView()
    }
}
