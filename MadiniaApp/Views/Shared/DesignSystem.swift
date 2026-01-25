//
//  DesignSystem.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

// MARK: - Madinia Colors

/// Brand colors following the Madin.IA design guidelines
enum MadiniaColors {
    // Primary brand colors
    static let gold = Color(red: 238/255, green: 208/255, blue: 118/255) // #EED076

    /// Violet - adaptive for dark mode (lighter purple for better visibility)
    static let violet = Color(UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            // Lighter lavender/purple for dark mode - better accessibility
            return UIColor(red: 180/255, green: 140/255, blue: 220/255, alpha: 1) // #B48CDC
        } else {
            // Original violet for light mode
            return UIColor(red: 88/255, green: 37/255, blue: 134/255, alpha: 1) // #582586
        }
    })

    /// Dark gray - adaptive for dark mode (white text on dark backgrounds)
    static let darkGray = Color(UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            // White for dark mode
            return UIColor.white
        } else {
            // Original dark gray for light mode
            return UIColor(red: 10/255, green: 18/255, blue: 27/255, alpha: 1) // #0A121B
        }
    })

    /// Original dark gray (always dark) - use for text on gold backgrounds for contrast
    static let darkGrayFixed = Color(red: 10/255, green: 18/255, blue: 27/255) // #0A121B

    /// Original violet (always dark) - use when you need the original violet
    static let violetFixed = Color(red: 88/255, green: 37/255, blue: 134/255) // #582586

    // Level colors (semantic)
    static let levelStarter = Color.green
    static let levelPerformer = Color.orange
    static let levelMaster = Color.red

    // Functional colors
    static let cardBackground = Color(UIColor.secondarySystemBackground)
    static let surfaceBackground = Color(UIColor.systemBackground)

    // Semantic colors for adaptive theming
    /// Primary text color - adapts to light/dark mode
    static let primaryText = Color.primary
    /// Secondary text color - adapts to light/dark mode
    static let secondaryText = Color.secondary
    /// Elevated background for cards and sheets
    static let elevatedBackground = Color(UIColor.secondarySystemBackground)
    /// Grouped background for list sections
    static let groupedBackground = Color(UIColor.systemGroupedBackground)

    /// Returns the appropriate color for a formation level
    static func levelColor(for level: String) -> Color {
        switch level.lowercased() {
        case "debutant", "starter":
            return levelStarter
        case "intermediaire", "performer":
            return levelPerformer
        case "avance", "expert", "master":
            return levelMaster
        default:
            return gold
        }
    }

    // MARK: - Gradients

    /// Violet to gold gradient (for decorative elements)
    static let brandGradient = LinearGradient(
        colors: [violet, gold],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Dark overlay gradient (for image cards)
    static let imageOverlayGradient = LinearGradient(
        colors: [.clear, darkGray.opacity(0.8)],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Placeholder gradient (for missing images)
    static let placeholderGradient = LinearGradient(
        colors: [violet.opacity(0.6), gold.opacity(0.4)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Madinia Spacing

/// Consistent spacing values based on 4pt grid
enum MadiniaSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Madinia Radius

/// Corner radius values for consistent UI elements
enum MadiniaRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
}

// MARK: - Madinia Shadow

/// Shadow styles for depth hierarchy
enum MadiniaShadow {
    /// Light shadow for cards
    static func card(_ color: Color = .black) -> some View {
        Color.clear
            .shadow(color: color.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    /// Medium shadow for elevated elements
    static func elevated(_ color: Color = .black) -> some View {
        Color.clear
            .shadow(color: color.opacity(0.15), radius: 8, x: 0, y: 4)
    }

    /// Strong shadow for FAB
    static func fab(_ color: Color = MadiniaColors.violet) -> some View {
        Color.clear
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Madinia Typography

/// Typography styles following the design system
enum MadiniaTypography {
    /// Large title - 28pt bold
    static let largeTitle = Font.system(size: 28, weight: .bold)

    /// Title - 22pt bold
    static let title = Font.system(size: 22, weight: .bold)

    /// Title 2 - 20pt semibold
    static let title2 = Font.system(size: 20, weight: .semibold)

    /// Headline - 17pt semibold
    static let headline = Font.system(size: 17, weight: .semibold)

    /// Body - 17pt regular
    static let body = Font.system(size: 17, weight: .regular)

    /// Callout - 16pt regular
    static let callout = Font.system(size: 16, weight: .regular)

    /// Subheadline - 15pt regular
    static let subheadline = Font.system(size: 15, weight: .regular)

    /// Caption - 12pt regular
    static let caption = Font.system(size: 12, weight: .regular)

    /// Caption 2 - 11pt regular
    static let caption2 = Font.system(size: 11, weight: .regular)
}

// MARK: - Madinia Card Sizes

/// Standard card dimensions
enum MadiniaCardSize {
    /// Formation card in grid (2 columns)
    static let formationCard = CGSize(width: 170, height: 240)

    /// Highlight card (horizontal scroll)
    static let highlightCard = CGSize(width: 320, height: 200)

    /// Article card (full width, use .infinity in frame modifier)
    static let articleCardHeight: CGFloat = 320

    /// Hero image height in cards
    static let heroImageHeight: CGFloat = 120

    /// Highlight hero image height
    static let highlightHeroHeight: CGFloat = 200
}

// MARK: - View Modifiers

/// Card style modifier applying consistent styling
struct MadiniaCardStyle: ViewModifier {
    var cornerRadius: CGFloat = MadiniaRadius.lg
    var shadowColor: Color = .black

    func body(content: Content) -> some View {
        content
            .background(MadiniaColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: shadowColor.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

/// Gold accent button style
struct MadiniaGoldButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, MadiniaSpacing.md)
            .padding(.vertical, MadiniaSpacing.xs)
            .background(MadiniaColors.gold)
            .foregroundStyle(MadiniaColors.darkGrayFixed) // Always dark text on gold
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

// MARK: - View Extensions

extension View {
    /// Applies Madinia card styling
    func madiniaCardStyle(cornerRadius: CGFloat = MadiniaRadius.lg) -> some View {
        modifier(MadiniaCardStyle(cornerRadius: cornerRadius))
    }

    /// Applies gold pill badge style
    func madiniaGoldPill() -> some View {
        self
            .font(MadiniaTypography.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, MadiniaSpacing.xs)
            .padding(.vertical, MadiniaSpacing.xxs)
            .background(MadiniaColors.gold)
            .foregroundStyle(MadiniaColors.darkGrayFixed) // Always dark text on gold
            .clipShape(Capsule())
    }

    /// Applies violet tinted chip style (unselected state)
    func madiniaVioletChip() -> some View {
        self
            .font(MadiniaTypography.caption)
            .padding(.horizontal, MadiniaSpacing.sm)
            .padding(.vertical, MadiniaSpacing.xs)
            .background(MadiniaColors.violet.opacity(0.15))
            .foregroundStyle(MadiniaColors.violet)
            .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview("Design System Colors") {
    VStack(spacing: 20) {
        HStack(spacing: 16) {
            colorSwatch("Gold", MadiniaColors.gold)
            colorSwatch("Violet", MadiniaColors.violet)
            colorSwatch("Dark Gray", MadiniaColors.darkGray)
        }

        HStack(spacing: 16) {
            colorSwatch("Starter", MadiniaColors.levelStarter)
            colorSwatch("Performer", MadiniaColors.levelPerformer)
            colorSwatch("Master", MadiniaColors.levelMaster)
        }

        RoundedRectangle(cornerRadius: MadiniaRadius.lg)
            .fill(MadiniaColors.brandGradient)
            .frame(height: 60)
            .overlay {
                Text("Brand Gradient")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
            }

        RoundedRectangle(cornerRadius: MadiniaRadius.lg)
            .fill(MadiniaColors.placeholderGradient)
            .frame(height: 60)
            .overlay {
                Text("Placeholder Gradient")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
            }
    }
    .padding()
}

private struct ColorSwatch: View {
    let name: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 60, height: 60)
            Text(name)
                .font(.caption)
        }
    }
}

private func colorSwatch(_ name: String, _ color: Color) -> ColorSwatch {
    ColorSwatch(name: name, color: color)
}

#Preview("Design System Components") {
    VStack(spacing: 24) {
        Text("Gold Pill Badge")
            .madiniaGoldPill()

        Text("Violet Chip")
            .madiniaVioletChip()

        Text("Card Style")
            .padding()
            .frame(maxWidth: .infinity)
            .madiniaCardStyle()
    }
    .padding()
}
