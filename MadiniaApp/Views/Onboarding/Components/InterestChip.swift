//
//  InterestChip.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-05.
//

import SwiftUI

/// Selectable chip component for interest selection in onboarding.
/// Similar to CategoryChip but optimized for multi-select scenarios.
struct InterestChip: View {
    /// The interest name to display
    let name: String

    /// Whether this chip is currently selected
    let isSelected: Bool

    /// Action when chip is tapped
    var onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: MadiniaSpacing.xxs) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                }
                Text(name)
                    .font(MadiniaTypography.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, MadiniaSpacing.md)
            .padding(.vertical, MadiniaSpacing.xs)
            .background(chipBackground)
            .foregroundStyle(chipForeground)
            .clipShape(Capsule())
            .overlay {
                if isSelected {
                    Capsule()
                        .strokeBorder(MadiniaColors.accent, lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(name), \(isSelected ? "sélectionné" : "non sélectionné")")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint("Appuyez pour \(isSelected ? "désélectionner" : "sélectionner")")
    }

    // MARK: - Computed Properties

    private var chipBackground: Color {
        if isSelected {
            return MadiniaColors.accent.opacity(0.15)
        } else {
            return MadiniaColors.violet.opacity(0.1)
        }
    }

    private var chipForeground: Color {
        if isSelected {
            return MadiniaColors.accent
        } else {
            return MadiniaColors.violet
        }
    }
}

// MARK: - Previews

#Preview("Interest Chips") {
    VStack(spacing: MadiniaSpacing.lg) {
        Text("Unselected")
            .font(MadiniaTypography.caption)
            .foregroundStyle(.secondary)

        FlowLayout(spacing: MadiniaSpacing.xs) {
            InterestChip(name: "IA Générative", isSelected: false) { }
            InterestChip(name: "Data Science", isSelected: false) { }
            InterestChip(name: "Marketing", isSelected: false) { }
        }

        Text("Selected")
            .font(MadiniaTypography.caption)
            .foregroundStyle(.secondary)

        FlowLayout(spacing: MadiniaSpacing.xs) {
            InterestChip(name: "IA Générative", isSelected: true) { }
            InterestChip(name: "Data Science", isSelected: true) { }
            InterestChip(name: "Marketing", isSelected: false) { }
        }
    }
    .padding()
}

// MARK: - Flow Layout Helper

/// Layout that wraps items to the next line when they exceed available width.
/// Used for displaying multiple chips in a flexible grid.
struct FlowLayout: Layout {
    var spacing: CGFloat = MadiniaSpacing.xs

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)

        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
        }

        return (CGSize(width: totalWidth, height: currentY + lineHeight), positions)
    }
}
