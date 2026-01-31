//
//  SettingsView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-25.
//

import SwiftUI

/// Main settings hub view with navigation to sub-settings
struct SettingsView: View {
    var body: some View {
        List {
            Section {
                NavigationLink {
                    AppearanceSettingsView()
                } label: {
                    settingsRow(
                        icon: "paintbrush.fill",
                        title: "Apparence",
                        subtitle: "Thème clair, sombre ou automatique"
                    )
                }

                NavigationLink {
                    NotificationSettingsView()
                } label: {
                    settingsRow(
                        icon: "bell.fill",
                        title: "Notifications",
                        subtitle: "Gérer les alertes et les rappels"
                    )
                }

                NavigationLink {
                    WhatsNewView(isModal: false)
                } label: {
                    settingsRow(
                        icon: "sparkles",
                        title: "Nouveautés",
                        subtitle: "Découvrir les dernières mises à jour"
                    )
                }
            }

            Section {
                appInfoRow
            } header: {
                Text("À propos")
            }
        }
        .navigationTitle("Paramètres")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func settingsRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: MadiniaSpacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(MadiniaColors.accent)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(MadiniaTypography.body)

                Text(subtitle)
                    .font(MadiniaTypography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, MadiniaSpacing.xxs)
    }

    private var appInfoRow: some View {
        HStack(spacing: MadiniaSpacing.md) {
            Image("madinia-logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.sm))

            VStack(alignment: .leading, spacing: 2) {
                Text("Madin.IA")
                    .font(MadiniaTypography.headline)

                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                   let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                    Text("Version \(version) (\(build))")
                        .font(MadiniaTypography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, MadiniaSpacing.xxs)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}

#Preview("Dark Mode") {
    NavigationStack {
        SettingsView()
    }
    .preferredColorScheme(.dark)
}
