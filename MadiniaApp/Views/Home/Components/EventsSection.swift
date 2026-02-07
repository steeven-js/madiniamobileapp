//
//  EventsSection.swift
//  MadiniaApp
//
//  Section des événements sur l'écran d'accueil.
//  Affiche les prochains événements dans un carousel horizontal.
//

import SwiftUI

/// Section affichant les prochains événements sur l'écran d'accueil
struct EventsSection: View {
    /// Événements à afficher
    let events: [Event]

    /// Action lors du tap sur "Voir tout"
    var onViewAllTap: (() -> Void)?

    /// Action lors du tap sur un événement
    var onEventTap: ((Event) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            // Header
            HStack {
                Text("Événements")
                    .font(MadiniaTypography.title2)
                    .fontWeight(.bold)

                Spacer()

                if !events.isEmpty {
                    Button {
                        onViewAllTap?()
                    } label: {
                        HStack(spacing: MadiniaSpacing.xxs) {
                            Text("Voir tout")
                                .font(MadiniaTypography.subheadline)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundStyle(MadiniaColors.accent)
                    }
                }
            }

            // Content
            if events.isEmpty {
                emptyState
            } else {
                // Horizontal carousel of events
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: MadiniaSpacing.md) {
                        ForEach(events) { event in
                            EventTeaserCard(event: event)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    HapticManager.tap()
                                    onEventTap?(event)
                                }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    private var emptyState: some View {
        HStack {
            Spacer()
            VStack(spacing: MadiniaSpacing.xs) {
                Image(systemName: "calendar")
                    .font(.title)
                    .foregroundStyle(.tertiary)
                Text("Aucun événement à venir")
                    .font(MadiniaTypography.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, MadiniaSpacing.lg)
            Spacer()
        }
    }
}

// MARK: - Previews

#Preview("Events Section") {
    ScrollView {
        EventsSection(
            events: Event.samples,
            onViewAllTap: { print("View all") },
            onEventTap: { print("Event: \($0.title)") }
        )
        .padding()
    }
}

#Preview("Empty State") {
    EventsSection(events: [])
        .padding()
}
