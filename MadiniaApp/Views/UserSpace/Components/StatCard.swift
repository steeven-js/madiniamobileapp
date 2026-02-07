//
//  StatCard.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-07.
//

import SwiftUI

/// Reusable statistic card component for displaying metrics
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    var iconColor: Color = MadiniaColors.accent

    var body: some View {
        VStack(spacing: MadiniaSpacing.xs) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(iconColor)

            // Value
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.primary)

            // Label
            Text(label)
                .font(MadiniaTypography.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(MadiniaSpacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
    }
}

/// Compact horizontal stat row
struct StatRow: View {
    let icon: String
    let value: String
    let label: String
    var iconColor: Color = MadiniaColors.accent

    var body: some View {
        HStack(spacing: MadiniaSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(iconColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(label)
                    .font(MadiniaTypography.caption)
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

#Preview("Stat Card") {
    HStack(spacing: 12) {
        StatCard(icon: "eye.fill", value: "42", label: "Formations vues")
        StatCard(icon: "flame.fill", value: "7", label: "Jours consécutifs")
    }
    .padding()
}

#Preview("Stat Row") {
    VStack(spacing: 8) {
        StatRow(icon: "clock.fill", value: "5h 30min", label: "Temps total")
        StatRow(icon: "star.fill", value: "3", label: "Badges débloqués")
    }
    .padding()
}
