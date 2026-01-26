//
//  AllServicesListView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-25.
//

import SwiftUI

/// List view showing all services in a grid layout.
struct AllServicesListView: View {
    /// All services to display
    let services: [Service]

    /// Selected service for detail sheet
    @State private var selectedService: Service?

    /// Grid columns
    private let columns = [
        GridItem(.flexible(), spacing: MadiniaSpacing.md),
        GridItem(.flexible(), spacing: MadiniaSpacing.md)
    ]

    var body: some View {
        ScrollView {
            if services.isEmpty {
                emptyStateView
            } else {
                LazyVGrid(columns: columns, spacing: MadiniaSpacing.md) {
                    ForEach(services) { service in
                        ServiceCard(service: service) {
                            selectedService = service
                        }
                    }
                }
                .padding(MadiniaSpacing.md)
            }
        }
        .navigationTitle("Nos Services")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedService) { service in
            ServiceDetailView(service: service)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: MadiniaSpacing.sm) {
            Image(systemName: "briefcase")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("Aucun service disponible")
                .font(MadiniaTypography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MadiniaSpacing.xxl)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AllServicesListView(services: Service.samples)
    }
}
