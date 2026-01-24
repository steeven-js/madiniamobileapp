//
//  CategoryGridCard.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// Large category card for the Category Grid screen.
/// Displays category name, formation count, and gradient background.
/// Supports variable heights for masonry-style layout.
struct CategoryGridCard: View {
    /// Card height variants for masonry effect
    enum HeightVariant {
        case short  // 140pt
        case tall   // 200pt

        var height: CGFloat {
            switch self {
            case .short: return 140
            case .tall: return 200
            }
        }
    }

    /// The category to display
    let category: FormationCategory

    /// Number of formations in this category
    let formationCount: Int

    /// Height variant for masonry layout
    var heightVariant: HeightVariant = .short

    /// Action when card is tapped
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            ZStack(alignment: .bottomLeading) {
                // Gradient background
                RoundedRectangle(cornerRadius: MadiniaRadius.md)
                    .fill(cardGradient)

                // Content overlay
                VStack(alignment: .leading, spacing: MadiniaSpacing.xxs) {
                    Spacer()

                    // Category name
                    Text(category.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    // Formation count
                    Text("\(formationCount) Formation\(formationCount > 1 ? "s" : "")")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding(MadiniaSpacing.md)
            }
            .frame(height: heightVariant.height)
            .shadow(color: categoryColor.opacity(0.3), radius: 6, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(category.name), \(formationCount) formations")
        .accessibilityHint("Appuyez pour voir les formations de cette catégorie")
    }

    // MARK: - Computed Properties

    /// Base color from category or default to violet
    private var categoryColor: Color {
        if let hexColor = category.color, let color = Color(hex: hexColor) {
            return color
        }
        return MadiniaColors.violet
    }

    /// Gradient from category color (darker to lighter, diagonal)
    private var cardGradient: LinearGradient {
        LinearGradient(
            colors: [
                categoryColor.opacity(0.95),
                categoryColor.opacity(0.7)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Preview

#Preview("Category Grid Card - Masonry") {
    ScrollView {
        HStack(alignment: .top, spacing: MadiniaSpacing.md) {
            // Left column: short, tall, short
            VStack(spacing: MadiniaSpacing.md) {
                CategoryGridCard(
                    category: FormationCategory(
                        id: 1,
                        name: "Technology",
                        slug: "technology",
                        description: nil,
                        color: "#6366F1",
                        icon: nil,
                        formationsCount: 7
                    ),
                    formationCount: 7,
                    heightVariant: .short
                )

                CategoryGridCard(
                    category: FormationCategory(
                        id: 3,
                        name: "Design UI/UX",
                        slug: "design-ui-ux",
                        description: nil,
                        color: "#8B5CF6",
                        icon: nil,
                        formationsCount: 17
                    ),
                    formationCount: 17,
                    heightVariant: .tall
                )

                CategoryGridCard(
                    category: FormationCategory(
                        id: 5,
                        name: "Computer Games",
                        slug: "computer-games",
                        description: nil,
                        color: "#06B6D4",
                        icon: nil,
                        formationsCount: 5
                    ),
                    formationCount: 5,
                    heightVariant: .short
                )
            }

            // Right column: tall, short, tall
            VStack(spacing: MadiniaSpacing.md) {
                CategoryGridCard(
                    category: FormationCategory(
                        id: 2,
                        name: "Business",
                        slug: "business",
                        description: nil,
                        color: "#10B981",
                        icon: nil,
                        formationsCount: 20
                    ),
                    formationCount: 20,
                    heightVariant: .tall
                )

                CategoryGridCard(
                    category: FormationCategory(
                        id: 4,
                        name: "Digital Marketing",
                        slug: "digital-marketing",
                        description: nil,
                        color: "#EC4899",
                        icon: nil,
                        formationsCount: 23
                    ),
                    formationCount: 23,
                    heightVariant: .short
                )

                CategoryGridCard(
                    category: FormationCategory(
                        id: 6,
                        name: "Analytics",
                        slug: "analytics",
                        description: nil,
                        color: "#14B8A6",
                        icon: nil,
                        formationsCount: 14
                    ),
                    formationCount: 14,
                    heightVariant: .tall
                )
            }
        }
        .padding(MadiniaSpacing.md)
    }
}
