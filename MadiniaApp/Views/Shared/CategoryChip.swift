//
//  CategoryChip.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Chip component for category filtering.
/// Shows category name with optional color and selected state.
struct CategoryChip: View {
    /// The category name to display
    let name: String

    /// Optional category color (hex converted)
    let color: Color?

    /// Whether this chip is currently selected
    let isSelected: Bool

    /// Action when chip is tapped
    var onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            Text(name)
                .font(MadiniaTypography.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, MadiniaSpacing.md)
                .padding(.vertical, MadiniaSpacing.xs)
                .background(chipBackground)
                .foregroundStyle(chipForeground)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(name), \(isSelected ? "sélectionné" : "non sélectionné")")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Computed Properties

    private var chipBackground: Color {
        if isSelected {
            // Selected: gold background
            return MadiniaColors.accent
        } else {
            // Unselected: violet 15% opacity background
            return MadiniaColors.violet.opacity(0.15)
        }
    }

    private var chipForeground: Color {
        if isSelected {
            // Selected: dark text on gold
            return MadiniaColors.darkGray
        } else {
            // Unselected: violet text
            return MadiniaColors.violet
        }
    }
}

// MARK: - Previews

#Preview("Category Chips") {
    VStack(spacing: 20) {
        HStack(spacing: 8) {
            CategoryChip(name: "Toutes", color: nil, isSelected: true) { }
            CategoryChip(name: "IA Générative", color: Color(hex: "#8B5CF6"), isSelected: false) { }
            CategoryChip(name: "Marketing", color: .orange, isSelected: false) { }
        }

        HStack(spacing: 8) {
            CategoryChip(name: "Toutes", color: nil, isSelected: false) { }
            CategoryChip(name: "IA Générative", color: Color(hex: "#8B5CF6"), isSelected: true) { }
            CategoryChip(name: "Marketing", color: .orange, isSelected: false) { }
        }
    }
    .padding()
}
