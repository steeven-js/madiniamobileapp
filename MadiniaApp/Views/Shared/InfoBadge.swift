//
//  InfoBadge.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Reusable badge component for displaying formation metadata.
/// Used in FormationCard and HighlightCard for consistent info display.
struct InfoBadge: View {
    /// Badge display style
    enum Style {
        case duration(String)           // "14 heures"
        case level(String, Color)       // "Débutant", .green
        case certification              // Shows "Certifiante" with checkmark
        case category(String, Color?)   // "IA Générative", optional hex color
    }

    let style: Style

    var body: some View {
        HStack(spacing: MadiniaSpacing.xxs) {
            Image(systemName: iconName)
                .font(.caption2)

            Text(labelText)
                .font(MadiniaTypography.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, MadiniaSpacing.xs)
        .padding(.vertical, MadiniaSpacing.xxs)
        .background(backgroundColor.opacity(0.15))
        .foregroundStyle(foregroundColor)
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    // MARK: - Computed Properties

    private var iconName: String {
        switch style {
        case .duration: return "clock"
        case .level: return "chart.bar.fill"
        case .certification: return "checkmark.seal.fill"
        case .category: return "folder.fill"
        }
    }

    private var labelText: String {
        switch style {
        case .duration(let text): return text
        case .level(let text, _): return text
        case .certification: return "Certifiante"
        case .category(let text, _): return text
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .duration: return .secondary
        case .level(_, let color): return color
        case .certification: return MadiniaColors.accent
        case .category(_, let color): return color ?? MadiniaColors.accent
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .duration: return .secondary
        case .level(_, let color): return color
        case .certification: return MadiniaColors.accent
        case .category(_, let color): return color ?? MadiniaColors.accent
        }
    }

    private var accessibilityText: String {
        switch style {
        case .duration(let text): return "Durée: \(text)"
        case .level(let text, _): return "Niveau: \(text)"
        case .certification: return "Formation certifiante"
        case .category(let text, _): return "Catégorie: \(text)"
        }
    }
}

// MARK: - Preview

#Preview("All Styles") {
    VStack(spacing: 16) {
        InfoBadge(style: .duration("14 heures"))
        InfoBadge(style: .level("Débutant", .green))
        InfoBadge(style: .level("Intermédiaire", .orange))
        InfoBadge(style: .level("Avancé", .red))
        InfoBadge(style: .certification)
        InfoBadge(style: .category("IA Générative", .purple))
        InfoBadge(style: .category("Expert", nil))
    }
    .padding()
}
