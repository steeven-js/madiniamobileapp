//
//  ServiceDetailView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// Detail view for a service using the unified detail design.
struct ServiceDetailView: View {
    /// The service to display
    let service: Service

    /// Environment dismiss action
    @Environment(\.dismiss) private var dismiss

    /// Navigation context for contact navigation
    @Environment(\.navigationContext) private var navigationContext

    var body: some View {
        NavigationStack {
            UnifiedDetailView(config: configuration)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Fermer") {
                            dismiss()
                        }
                    }
                }
        }
    }

    // MARK: - Configuration

    private var configuration: DetailViewConfiguration {
        DetailViewConfiguration(
            title: service.name,
            subtitle: service.shortDescription,
            imageUrl: service.imageUrl,
            description: service.description ?? service.shortDescription,
            availableTabs: [.about],
            ctaTitle: "Nous contacter",
            ctaAction: {
                navigationContext.navigateToContact(from: service)
                dismiss()
            },
            shareUrl: shareURL
        )
    }

    private var shareURL: URL? {
        guard let href = service.href else { return nil }
        return URL(string: "https://madinia.fr\(href)")
    }
}

// MARK: - Preview

#Preview {
    ServiceDetailView(service: .sample)
}
