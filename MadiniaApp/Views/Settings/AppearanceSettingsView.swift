//
//  AppearanceSettingsView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-25.
//

import SwiftUI

/// View for selecting app appearance theme (Light/Dark)
/// Dark mode is the default for Madin.IA
struct AppearanceSettingsView: View {
    @Bindable private var themeManager = ThemeManager.shared

    var body: some View {
        List {
            Section {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    themeRow(for: theme)
                }
            } header: {
                Text("Thème de l'application")
            } footer: {
                Text("Le mode sombre est recommandé pour une meilleure expérience.")
            }
        }
        .navigationTitle("Apparence")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func themeRow(for theme: AppTheme) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                themeManager.currentTheme = theme
            }
        } label: {
            HStack(spacing: MadiniaSpacing.md) {
                Image(systemName: theme.icon)
                    .font(.title3)
                    .foregroundStyle(themeManager.currentTheme == theme ? MadiniaColors.accent : .secondary)
                    .frame(width: 28)

                Text(theme.title)
                    .foregroundStyle(.primary)

                Spacer()

                if themeManager.currentTheme == theme {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(MadiniaColors.accent)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(theme.title)
        .accessibilityAddTraits(themeManager.currentTheme == theme ? .isSelected : [])
    }
}

#Preview {
    NavigationStack {
        AppearanceSettingsView()
    }
}

#Preview("Dark Mode") {
    NavigationStack {
        AppearanceSettingsView()
    }
    .preferredColorScheme(.dark)
}
