//
//  ContactHubView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-02.
//

import SwiftUI

/// Hub view for contact options: appointment booking (Calendly) or contact form.
struct ContactHubView: View {
    /// Whether this view is embedded in another NavigationStack
    var embedded: Bool = false

    /// Selected sub-view
    @State private var selectedOption: ContactOption?

    /// Navigation context for handling contact navigation from services
    @Environment(\.navigationContext) private var navigationContext

    var body: some View {
        Group {
            if embedded {
                content
                    .navigationTitle("Contact")
            } else {
                NavigationStack {
                    content
                        .navigationTitle("Contact")
                }
            }
        }
    }

    // MARK: - Content

    private var content: some View {
        ScrollView {
            VStack(spacing: MadiniaSpacing.xl) {
                // Header
                headerSection

                // Contact options
                VStack(spacing: MadiniaSpacing.md) {
                    // Appointment option
                    ContactOptionCard(
                        icon: "calendar.badge.clock",
                        title: "Prendre rendez-vous",
                        description: "Réservez un créneau pour un appel découverte avec notre équipe.",
                        accentColor: MadiniaColors.accent,
                        action: {
                            selectedOption = .appointment
                        }
                    )

                    // Form option
                    ContactOptionCard(
                        icon: "envelope.fill",
                        title: "Envoyer un message",
                        description: "Remplissez notre formulaire de contact et nous vous répondrons sous 24-48h.",
                        accentColor: MadiniaColors.violet,
                        action: {
                            selectedOption = .form
                        }
                    )
                }
            }
            .padding(MadiniaSpacing.md)
            .tabBarSafeArea()
        }
        .navigationDestination(item: $selectedOption) { option in
            switch option {
            case .appointment:
                CalendlyView(embedded: true)
            case .form:
                ContactFormView(embedded: true)
                    .environment(\.navigationContext, navigationContext)
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: MadiniaSpacing.md) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 50))
                .foregroundStyle(MadiniaColors.accent)

            Text("Comment pouvons-nous vous aider ?")
                .font(.system(size: 22, weight: .bold))
                .multilineTextAlignment(.center)

            Text("Choisissez l'option qui vous convient le mieux")
                .font(MadiniaTypography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, MadiniaSpacing.lg)
    }
}

// MARK: - Contact Option Enum

enum ContactOption: String, Identifiable, Hashable {
    case appointment
    case form

    var id: String { rawValue }
}

// MARK: - Contact Option Card

private struct ContactOptionCard: View {
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: MadiniaSpacing.md) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(accentColor)
                    .frame(width: 60, height: 60)
                    .background(accentColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))

                // Text content
                VStack(alignment: .leading, spacing: MadiniaSpacing.xxs) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text(description)
                        .font(MadiniaTypography.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(MadiniaSpacing.md)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.lg))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview {
    ContactHubView()
}

#Preview("Embedded") {
    NavigationStack {
        ContactHubView(embedded: true)
    }
}
