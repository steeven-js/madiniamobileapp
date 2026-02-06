//
//  EventTypeFilter.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-06.
//

import SwiftUI

/// Horizontal scrolling filter chips for filtering events by type.
struct EventTypeFilter: View {
    /// Currently selected type (nil means "All")
    @Binding var selectedType: EventType?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MadiniaSpacing.xs) {
                // "All" chip
                FilterChip(
                    label: "Tous",
                    icon: "calendar",
                    isSelected: selectedType == nil,
                    color: MadiniaColors.accent
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedType = nil
                    }
                }

                // Type chips
                ForEach(EventType.allCases, id: \.self) { type in
                    FilterChip(
                        label: type.displayName,
                        icon: type.icon,
                        isSelected: selectedType == type,
                        color: type.color
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedType = type
                        }
                    }
                }
            }
            .padding(.horizontal, MadiniaSpacing.md)
        }
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(MadiniaTypography.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, MadiniaSpacing.sm)
            .padding(.vertical, MadiniaSpacing.xs)
            .background(isSelected ? color : Color(.tertiarySystemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(isSelected ? color : Color(.separator), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(label), filtre")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Previews

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedType: EventType?

        var body: some View {
            VStack(alignment: .leading, spacing: MadiniaSpacing.lg) {
                Text("Sélection: \(selectedType?.displayName ?? "Tous")")
                    .font(.headline)
                    .padding(.horizontal)

                EventTypeFilter(selectedType: $selectedType)
            }
            .padding(.vertical)
        }
    }

    return PreviewWrapper()
}
