//
//  CategoryCard.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// Card component displaying a category in the horizontal scroll.
/// Width adapts to title length, fixed height (Nuton-style).
struct CategoryCard: View {
    /// The category to display
    let category: FormationCategory

    /// Action when card is tapped
    var onTap: (() -> Void)?

    /// Card height (fixed at 89pt like Figma mockup)
    private let cardHeight: CGFloat = 89

    var body: some View {
        Button {
            onTap?()
        } label: {
            ZStack(alignment: .bottomLeading) {
                // Gradient background
                RoundedRectangle(cornerRadius: MadiniaRadius.sm)
                    .fill(cardGradient)

                // Category name - left aligned at bottom
                Text(category.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .padding(.horizontal, MadiniaSpacing.sm)
                    .padding(.vertical, MadiniaSpacing.sm)
            }
            .frame(height: cardHeight)
            .fixedSize(horizontal: true, vertical: false) // Width adapts to content
            .shadow(color: categoryColor.opacity(0.25), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Catégorie \(category.name)")
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

    /// Gradient from category color (darker to lighter)
    private var cardGradient: LinearGradient {
        LinearGradient(
            colors: [
                categoryColor.opacity(0.9),
                categoryColor.opacity(0.6)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Preview

#Preview("Category Cards - Adaptive Width") {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: MadiniaSpacing.sm) {
            CategoryCard(category: FormationCategory(
                id: 1,
                name: "Business",
                slug: "business",
                description: nil,
                color: "#6366F1",
                icon: nil,
                formationsCount: 12
            ))

            CategoryCard(category: FormationCategory(
                id: 2,
                name: "Technology",
                slug: "technology",
                description: nil,
                color: "#8B5CF6",
                icon: nil,
                formationsCount: 7
            ))

            CategoryCard(category: FormationCategory(
                id: 3,
                name: "Digital Marketing",
                slug: "digital-marketing",
                description: nil,
                color: "#EC4899",
                icon: nil,
                formationsCount: 23
            ))

            CategoryCard(category: FormationCategory(
                id: 4,
                name: "IA Générative",
                slug: "ia-generative",
                description: nil,
                color: "#10B981",
                icon: nil,
                formationsCount: 5
            ))
        }
        .padding(MadiniaSpacing.md)
    }
}
