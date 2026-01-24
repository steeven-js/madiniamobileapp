//
//  SearchBar.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// Custom search bar for the Search screen.
/// Styled to match Figma mockup (16 Search).
struct SearchBar: View {
    /// Search text binding
    @Binding var text: String

    /// Placeholder text
    var placeholder: String = "Rechercher..."

    /// Focus state
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: MadiniaSpacing.sm) {
            // Search icon
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .font(.body)

            // Text field
            TextField(placeholder, text: $text)
                .font(MadiniaTypography.body)
                .focused($isFocused)
                .submitLabel(.search)

            // Clear button
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, MadiniaSpacing.sm)
        .padding(.vertical, MadiniaSpacing.xs)
        .background(Color(UIColor.tertiarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.sm))
        .onTapGesture {
            isFocused = true
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: MadiniaSpacing.lg) {
        SearchBar(text: .constant(""))
        SearchBar(text: .constant("Intelligence artificielle"))
    }
    .padding()
}
