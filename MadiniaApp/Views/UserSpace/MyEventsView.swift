//
//  MyEventsView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-03-18.
//

import SwiftUI

/// View displaying the user's event registrations fetched from the API.
struct MyEventsView: View {
    /// Events service for registrations
    @State private var eventsService = EventsService.shared

    /// Loading state
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                LoadingView(message: "Chargement de vos événements...")
            } else if eventsService.registrations.isEmpty {
                emptyState
            } else {
                registrationsList
            }
        }
        .navigationTitle("Mes événements")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await eventsService.fetchRegistrations()
            isLoading = false
        }
        .refreshable {
            await eventsService.fetchRegistrations()
        }
    }

    // MARK: - Registrations List

    private var registrationsList: some View {
        ScrollView {
            LazyVStack(spacing: MadiniaSpacing.md) {
                ForEach(eventsService.registrations) { registration in
                    registrationCard(registration)
                }
            }
            .padding(MadiniaSpacing.md)
            .tabBarSafeArea()
        }
    }

    // MARK: - Registration Card

    private func registrationCard(_ registration: EventRegistration) -> some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            // Event title
            HStack {
                Text(registration.event?.title ?? "Événement")
                    .font(MadiniaTypography.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Spacer()

                // Status badge
                statusBadge(registration.status)
            }

            // Event date
            if let startDate = registration.event?.startDate {
                HStack(spacing: MadiniaSpacing.xs) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(startDate.formatted(date: .long, time: .shortened))
                        .font(MadiniaTypography.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Event type
            if let eventType = registration.event?.eventType {
                HStack(spacing: MadiniaSpacing.xs) {
                    Image(systemName: eventType.icon)
                        .font(.caption)
                        .foregroundStyle(eventType.color)

                    Text(eventType.displayName)
                        .font(MadiniaTypography.caption)
                        .foregroundStyle(eventType.color)
                }
            }

            // Registration info
            HStack(spacing: MadiniaSpacing.sm) {
                if registration.enablePushReminder {
                    Label("Rappel", systemImage: "bell.fill")
                        .font(MadiniaTypography.caption)
                        .foregroundStyle(.secondary)
                }

                if registration.enableCalendarReminder {
                    Label("Calendrier", systemImage: "calendar.badge.checkmark")
                        .font(MadiniaTypography.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(MadiniaSpacing.md)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - Status Badge

    private func statusBadge(_ status: RegistrationStatus) -> some View {
        Text(status.displayName)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor(status).opacity(0.15))
            .foregroundStyle(statusColor(status))
            .clipShape(Capsule())
    }

    private func statusColor(_ status: RegistrationStatus) -> Color {
        switch status {
        case .confirmed: return .green
        case .pending: return .orange
        case .cancelled: return .red
        case .attended: return .blue
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ScrollView {
            ContentUnavailableView {
                Label("Aucune inscription", systemImage: "calendar.badge.exclamationmark")
            } description: {
                Text("Vous n'êtes inscrit à aucun événement pour le moment.\n\nDécouvrez nos prochains webinaires, ateliers et MasterClass !")
            }
            .padding(.top, MadiniaSpacing.xl)
            .tabBarSafeArea()
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        MyEventsView()
    }
}
