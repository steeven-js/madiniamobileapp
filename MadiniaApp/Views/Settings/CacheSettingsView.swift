//
//  CacheSettingsView.swift
//  MadiniaApp
//
//  Vue des paramètres de cache avec indicateurs de fraîcheur.
//

import SwiftUI

/// Vue de gestion du cache avec indicateurs de fraîcheur
struct CacheSettingsView: View {
    private let cacheService = CacheService.shared
    private let dataRepository = AppDataRepository.shared

    @State private var isRefreshing = false
    @State private var showClearConfirmation = false

    var body: some View {
        List {
            // Freshness status section
            Section {
                ForEach(CacheContentType.allCases, id: \.self) { type in
                    cacheStatusRow(for: type)
                }
            } header: {
                Text("État du cache")
            } footer: {
                Text("Les données sont automatiquement rafraîchies lorsqu'elles expirent.")
            }

            // Statistics section
            Section("Statistiques") {
                HStack {
                    Label("Taille du cache", systemImage: "externaldrive.fill")
                    Spacer()
                    Text(cacheService.formattedCacheSize)
                        .foregroundStyle(.secondary)
                }

                if let lastRefresh = dataRepository.lastRefreshTime {
                    HStack {
                        Label("Dernière mise à jour", systemImage: "clock")
                        Spacer()
                        Text(lastRefresh, style: .relative)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Actions section
            Section("Actions") {
                // Refresh expired button
                Button {
                    Task {
                        isRefreshing = true
                        await dataRepository.refreshExpiredContent()
                        cacheService.refreshFreshnessState()
                        isRefreshing = false
                    }
                } label: {
                    HStack {
                        Label("Rafraîchir le contenu expiré", systemImage: "arrow.clockwise")
                        Spacer()
                        if isRefreshing {
                            ProgressView()
                        } else if !cacheService.typesNeedingRefresh.isEmpty {
                            Text("\(cacheService.typesNeedingRefresh.count)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.orange)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                }
                .disabled(isRefreshing || cacheService.typesNeedingRefresh.isEmpty)

                // Refresh all button
                Button {
                    Task {
                        isRefreshing = true
                        await dataRepository.refresh()
                        cacheService.refreshFreshnessState()
                        isRefreshing = false
                    }
                } label: {
                    Label("Tout rafraîchir", systemImage: "arrow.triangle.2.circlepath")
                }
                .disabled(isRefreshing)

                // Clear cache button
                Button(role: .destructive) {
                    showClearConfirmation = true
                } label: {
                    Label("Vider le cache", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Cache")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Vider le cache ?",
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Vider", role: .destructive) {
                cacheService.clearAll()
                HapticManager.success()
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Toutes les données en cache seront supprimées. Elles seront retéléchargées au prochain lancement.")
        }
        .onAppear {
            cacheService.refreshFreshnessState()
        }
    }

    // MARK: - Subviews

    private func cacheStatusRow(for type: CacheContentType) -> some View {
        let freshness = cacheService.freshness(for: type)
        let age = cacheService.age(for: type)

        return HStack {
            // Icon
            Image(systemName: freshness.icon)
                .foregroundStyle(freshnessColor(freshness))
                .frame(width: 24)

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(type.displayName)
                    .font(.body)

                if let age = age {
                    Text(formatAge(age))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Non mis en cache")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            // TTL info
            Text(formatTTL(type.ttl))
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helpers

    private func freshnessColor(_ freshness: CacheFreshness) -> Color {
        switch freshness {
        case .fresh: return .green
        case .stale: return .orange
        case .expired: return .red
        case .none: return .gray
        }
    }

    private func formatAge(_ seconds: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.day, .hour, .minute]
        return "Il y a \(formatter.string(from: seconds) ?? "?")"
    }

    private func formatTTL(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds / 3600)
        if hours >= 24 {
            let days = hours / 24
            return "TTL: \(days)j"
        }
        return "TTL: \(hours)h"
    }
}

// MARK: - Previews

#Preview("Cache Settings") {
    NavigationStack {
        CacheSettingsView()
    }
}
