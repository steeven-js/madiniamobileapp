//
//  SettingsView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-25.
//

import SwiftUI
import UIKit

/// Main settings hub view with navigation to sub-settings
struct SettingsView: View {
    /// Device UUID for debugging
    private var deviceUUID: String {
        UIDevice.current.identifierForVendor?.uuidString ?? "Non disponible"
    }
    
    /// Truncated UUID for display
    private var truncatedUUID: String {
        let uuid = deviceUUID
        if uuid.count > 12 {
            let start = uuid.prefix(6)
            let end = uuid.suffix(6)
            return "\(start)...\(end)"
        }
        return uuid
    }
    
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
            
            #if DEBUG
            Section {
                // Device UUID
                HStack {
                    Image(systemName: "number")
                        .font(.title3)
                        .foregroundStyle(.orange)
                        .frame(width: 28)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Device UUID")
                            .font(MadiniaTypography.body)
                        
                        Text(deviceUUID)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    
                    Spacer()
                    
                    Button {
                        UIPasteboard.general.string = deviceUUID
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, MadiniaSpacing.xxs)
                
                // APNs Token (if available)
                if let token = PushNotificationService.shared.deviceToken {
                    HStack {
                        Image(systemName: "bell.badge")
                            .font(.title3)
                            .foregroundStyle(.orange)
                            .frame(width: 28)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("APNs Token")
                                .font(MadiniaTypography.body)
                            
                            Text(token.prefix(20) + "...")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        Button {
                            UIPasteboard.general.string = token
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, MadiniaSpacing.xxs)
                }
                
                // Environment
                HStack {
                    Image(systemName: "hammer")
                        .font(.title3)
                        .foregroundStyle(.orange)
                        .frame(width: 28)
                    
                    Text("Environnement")
                        .font(MadiniaTypography.body)
                    
                    Spacer()
                    
                    Text("DEBUG")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.orange)
                        .clipShape(Capsule())
                }
                .padding(.vertical, MadiniaSpacing.xxs)
            } header: {
                Text("Debug")
            }
            #endif
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
