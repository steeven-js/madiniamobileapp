//
//  AchievementBadge.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-07.
//

import SwiftUI

/// Badge component for displaying achievements
struct AchievementBadge: View {
    let achievement: Achievement
    var size: CGFloat = 80
    var showLabel: Bool = true

    private var tierColor: Color {
        switch achievement.tier {
        case .bronze:
            return MadiniaColors.bronzeTier
        case .silver:
            return MadiniaColors.silverTier
        case .gold:
            return MadiniaColors.goldTier
        }
    }

    var body: some View {
        VStack(spacing: MadiniaSpacing.xs) {
            // Badge circle
            ZStack {
                // Background circle
                Circle()
                    .fill(achievement.isUnlocked ? tierColor.opacity(0.15) : Color.gray.opacity(0.1))
                    .frame(width: size, height: size)

                // Border ring with progress
                Circle()
                    .stroke(
                        achievement.isUnlocked ? tierColor : Color.gray.opacity(0.3),
                        lineWidth: 3
                    )
                    .frame(width: size, height: size)

                // Progress ring (for locked achievements)
                if !achievement.isUnlocked && achievement.progressPercentage > 0 {
                    Circle()
                        .trim(from: 0, to: achievement.progressPercentage)
                        .stroke(tierColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: size, height: size)
                        .rotationEffect(.degrees(-90))
                }

                // Icon or lock
                if achievement.isUnlocked {
                    Image(systemName: achievement.icon)
                        .font(.system(size: size * 0.35, weight: .semibold))
                        .foregroundStyle(tierColor)
                } else {
                    ZStack {
                        Image(systemName: achievement.icon)
                            .font(.system(size: size * 0.3, weight: .semibold))
                            .foregroundStyle(.gray.opacity(0.4))

                        // Lock overlay
                        Image(systemName: "lock.fill")
                            .font(.system(size: size * 0.2))
                            .foregroundStyle(.gray.opacity(0.6))
                            .offset(x: size * 0.15, y: size * 0.15)
                    }
                }
            }

            // Label
            if showLabel {
                VStack(spacing: 2) {
                    Text(achievement.name)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(achievement.isUnlocked ? .primary : .secondary)
                        .lineLimit(1)

                    if !achievement.isUnlocked {
                        Text("\(achievement.progress)/\(achievement.requirement)")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: size + 20)
            }
        }
    }
}

/// Compact badge for lists
struct AchievementListItem: View {
    let achievement: Achievement

    private var tierColor: Color {
        switch achievement.tier {
        case .bronze:
            return MadiniaColors.bronzeTier
        case .silver:
            return MadiniaColors.silverTier
        case .gold:
            return MadiniaColors.goldTier
        }
    }

    var body: some View {
        HStack(spacing: MadiniaSpacing.md) {
            // Badge icon
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? tierColor.opacity(0.15) : Color.gray.opacity(0.1))
                    .frame(width: 50, height: 50)

                Circle()
                    .stroke(achievement.isUnlocked ? tierColor : Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 50, height: 50)

                Image(systemName: achievement.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(achievement.isUnlocked ? tierColor : .gray.opacity(0.4))
            }

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(achievement.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(achievement.isUnlocked ? .primary : .secondary)

                    if achievement.isUnlocked {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.green)
                    }
                }

                Text(achievement.description)
                    .font(MadiniaTypography.caption)
                    .foregroundStyle(.secondary)

                if !achievement.isUnlocked {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(tierColor)
                                .frame(width: geometry.size.width * achievement.progressPercentage, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
            }

            Spacer()

            // Tier indicator
            Text(achievement.tier.rawValue.capitalized)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(tierColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(tierColor.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(MadiniaSpacing.sm)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.sm))
    }
}

// MARK: - Previews

#Preview("Achievement Badge") {
    HStack(spacing: 20) {
        AchievementBadge(
            achievement: Achievement(
                id: "test1",
                name: "Premier pas",
                description: "Test",
                icon: "eye.fill",
                tier: .bronze,
                requirement: 1,
                progress: 1,
                unlockedAt: Date()
            )
        )

        AchievementBadge(
            achievement: Achievement(
                id: "test2",
                name: "Explorateur",
                description: "Test",
                icon: "binoculars.fill",
                tier: .silver,
                requirement: 5,
                progress: 3,
                unlockedAt: nil
            )
        )

        AchievementBadge(
            achievement: Achievement(
                id: "test3",
                name: "Passionné",
                description: "Test",
                icon: "flame.fill",
                tier: .gold,
                requirement: 25,
                progress: 25,
                unlockedAt: Date()
            )
        )
    }
    .padding()
}

#Preview("Achievement List Item") {
    VStack(spacing: 8) {
        AchievementListItem(
            achievement: Achievement(
                id: "test1",
                name: "Premier pas",
                description: "Consultez votre 1ère formation",
                icon: "eye.fill",
                tier: .bronze,
                requirement: 1,
                progress: 1,
                unlockedAt: Date()
            )
        )

        AchievementListItem(
            achievement: Achievement(
                id: "test2",
                name: "Explorateur",
                description: "Consultez 5 formations",
                icon: "binoculars.fill",
                tier: .bronze,
                requirement: 5,
                progress: 3,
                unlockedAt: nil
            )
        )
    }
    .padding()
}
