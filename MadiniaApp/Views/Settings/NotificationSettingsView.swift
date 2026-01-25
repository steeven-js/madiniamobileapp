//
//  NotificationSettingsView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// View for managing notification preferences.
struct NotificationSettingsView: View {
    @State private var pushService = PushNotificationService.shared

    var body: some View {
        List {
            // Status section
            Section {
                statusRow
            } footer: {
                Text("Les notifications vous permettent de rester informé des nouvelles formations et articles.")
            }

            // Preferences section (only if enabled)
            if pushService.isEnabled {
                Section("Types de notifications") {
                    Toggle("Nouvelles formations", isOn: Binding(
                        get: { pushService.notifyNewFormations },
                        set: { newValue in
                            pushService.notifyNewFormations = newValue
                            updatePreferences()
                        }
                    ))

                    Toggle("Nouveaux articles", isOn: Binding(
                        get: { pushService.notifyNewArticles },
                        set: { newValue in
                            pushService.notifyNewArticles = newValue
                            updatePreferences()
                        }
                    ))

                    Toggle("Rappels", isOn: Binding(
                        get: { pushService.notifyReminders },
                        set: { newValue in
                            pushService.notifyReminders = newValue
                            updatePreferences()
                        }
                    ))

                    Toggle("Rappels d'engagement", isOn: Binding(
                        get: { pushService.notifyEngagement },
                        set: { newValue in
                            pushService.notifyEngagement = newValue
                            updatePreferences()
                        }
                    ))
                }
            }

            // System settings link
            Section {
                Button {
                    pushService.openSettings()
                } label: {
                    HStack {
                        Text("Paramètres système")
                        Spacer()
                        Image(systemName: "arrow.up.forward.app")
                            .foregroundStyle(.secondary)
                    }
                }
            } footer: {
                Text("Modifiez les paramètres avancés dans les réglages iOS.")
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await pushService.checkAuthorizationStatus()
        }
    }

    // MARK: - Status Row

    @ViewBuilder
    private var statusRow: some View {
        HStack {
            Image(systemName: pushService.isEnabled ? "bell.badge.fill" : "bell.slash.fill")
                .font(.title2)
                .foregroundStyle(pushService.isEnabled ? .green : .secondary)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text("Notifications push")
                    .font(.headline)

                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if !pushService.isEnabled && pushService.authorizationStatus == .notDetermined {
                Button("Activer") {
                    Task {
                        await pushService.requestPermission()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
    }

    private var statusText: String {
        switch pushService.authorizationStatus {
        case .authorized:
            return "Activées"
        case .denied:
            return "Désactivées dans les réglages"
        case .provisional:
            return "Mode silencieux"
        case .notDetermined:
            return "Non configurées"
        case .ephemeral:
            return "Temporaires"
        @unknown default:
            return "Statut inconnu"
        }
    }

    // MARK: - Actions

    private func updatePreferences() {
        Task {
            await pushService.updatePreferences()
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
}
