//
//  WeeklyActivityChart.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-07.
//

import SwiftUI

/// Bar chart showing weekly activity (last 7 days)
struct WeeklyActivityChart: View {
    let data: [DailyActivity]

    private let barWidth: CGFloat = 32
    private let maxBarHeight: CGFloat = 100

    private var maxMinutes: Int {
        max(data.map { $0.minutesActive }.max() ?? 1, 1)
    }

    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }

    private var dateParser: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.md) {
            // Title
            Text("Activité de la semaine")
                .font(MadiniaTypography.headline)
                .foregroundStyle(.primary)

            // Chart
            HStack(alignment: .bottom, spacing: MadiniaSpacing.sm) {
                ForEach(data) { activity in
                    VStack(spacing: MadiniaSpacing.xs) {
                        // Bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(barColor(for: activity))
                            .frame(width: barWidth, height: barHeight(for: activity))

                        // Day label
                        Text(dayLabel(for: activity.date))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, MadiniaSpacing.sm)

            // Legend
            HStack(spacing: MadiniaSpacing.lg) {
                legendItem(color: MadiniaColors.accent, label: "Actif")
                legendItem(color: Color.gray.opacity(0.3), label: "Inactif")
            }
            .font(.system(size: 11))
        }
        .padding(MadiniaSpacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
    }

    private func barHeight(for activity: DailyActivity) -> CGFloat {
        guard activity.minutesActive > 0 else { return 8 } // Minimum height
        let ratio = CGFloat(activity.minutesActive) / CGFloat(maxMinutes)
        return max(ratio * maxBarHeight, 8)
    }

    private func barColor(for activity: DailyActivity) -> Color {
        activity.minutesActive > 0 ? MadiniaColors.accent : Color.gray.opacity(0.3)
    }

    private func dayLabel(for dateString: String) -> String {
        guard let date = dateParser.date(from: dateString) else { return "?" }
        return dayFormatter.string(from: date).prefix(1).uppercased()
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }
}

/// Simpler version showing just numbers
struct WeeklyActivitySimple: View {
    let data: [DailyActivity]

    var totalMinutes: Int {
        data.reduce(0) { $0 + $1.minutesActive }
    }

    var totalFormations: Int {
        data.reduce(0) { $0 + $1.formationsViewed }
    }

    var activeDays: Int {
        data.filter { $0.minutesActive > 0 }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.md) {
            Text("Cette semaine")
                .font(MadiniaTypography.headline)
                .foregroundStyle(.primary)

            HStack(spacing: MadiniaSpacing.md) {
                statPill(value: "\(activeDays)", label: "jours actifs", icon: "calendar")
                statPill(value: formatMinutes(totalMinutes), label: "temps total", icon: "clock")
                statPill(value: "\(totalFormations)", label: "formations", icon: "book")
            }
        }
        .padding(MadiniaSpacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
    }

    private func statPill(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(MadiniaColors.accent)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.primary)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatMinutes(_ minutes: Int) -> String {
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

// MARK: - Previews

#Preview("Weekly Activity Chart") {
    WeeklyActivityChart(data: [
        DailyActivity(date: "2026-02-01", minutesActive: 45, formationsViewed: 2),
        DailyActivity(date: "2026-02-02", minutesActive: 0, formationsViewed: 0),
        DailyActivity(date: "2026-02-03", minutesActive: 30, formationsViewed: 1),
        DailyActivity(date: "2026-02-04", minutesActive: 60, formationsViewed: 3),
        DailyActivity(date: "2026-02-05", minutesActive: 15, formationsViewed: 1),
        DailyActivity(date: "2026-02-06", minutesActive: 0, formationsViewed: 0),
        DailyActivity(date: "2026-02-07", minutesActive: 20, formationsViewed: 1)
    ])
    .padding()
}

#Preview("Weekly Activity Simple") {
    WeeklyActivitySimple(data: [
        DailyActivity(date: "2026-02-01", minutesActive: 45, formationsViewed: 2),
        DailyActivity(date: "2026-02-02", minutesActive: 0, formationsViewed: 0),
        DailyActivity(date: "2026-02-03", minutesActive: 30, formationsViewed: 1),
        DailyActivity(date: "2026-02-04", minutesActive: 60, formationsViewed: 3),
        DailyActivity(date: "2026-02-05", minutesActive: 15, formationsViewed: 1),
        DailyActivity(date: "2026-02-06", minutesActive: 0, formationsViewed: 0),
        DailyActivity(date: "2026-02-07", minutesActive: 20, formationsViewed: 1)
    ])
    .padding()
}
