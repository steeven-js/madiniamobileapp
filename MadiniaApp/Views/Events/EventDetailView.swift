//
//  EventDetailView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-06.
//

import SwiftUI

/// Detail view for displaying full event information and registration.
struct EventDetailView: View {
    /// The event to display
    let event: Event

    /// ViewModel for managing event details and registration
    @State private var viewModel: EventDetailViewModel

    /// Whether to show registration sheet
    @State private var showRegistrationSheet = false

    @Environment(\.dismiss) private var dismiss

    init(event: Event) {
        self.event = event
        self._viewModel = State(initialValue: EventDetailViewModel(event: event))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero Section
                    heroSection

                    // Content Section
                    VStack(alignment: .leading, spacing: MadiniaSpacing.md) {
                        // Title
                        Text(viewModel.displayEvent.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.primary)

                        // Event type badge
                        eventTypeBadge

                        // Date & Time
                        dateTimeSection

                        // Location
                        locationSection

                        // Availability
                        if let maxParticipants = viewModel.displayEvent.maxParticipants {
                            availabilitySection(max: maxParticipants)
                        }

                        // Tags
                        if let tags = viewModel.displayEvent.tags, !tags.isEmpty {
                            tagsSection(tags: tags)
                        }

                        Divider()
                            .padding(.vertical, MadiniaSpacing.sm)

                        // Description
                        descriptionSection
                    }
                    .padding(MadiniaSpacing.md)
                    .padding(.bottom, 120)
                }
            }
            .ignoresSafeArea(edges: .top)

            // Bottom action bar
            bottomActionBar
        }
        .navigationBarHidden(true)
        .background(Color(.systemBackground))
        .task {
            await viewModel.loadEventDetails()
        }
        .sheet(isPresented: $showRegistrationSheet) {
            EventRegistrationView(event: viewModel.displayEvent) { registration in
                viewModel.setRegistered(registration)
            }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                if let imageUrl = viewModel.displayEvent.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: 280)
                                .clipped()
                        default:
                            placeholderGradient
                        }
                    }
                } else {
                    placeholderGradient
                }

                // Gradient overlay
                LinearGradient(
                    colors: [.clear, Color(.systemBackground).opacity(0.8)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                // Back button
                VStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        Spacer()

                        // Share button
                        ShareLink(item: shareURL) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, MadiniaSpacing.md)
                    .padding(.top, 50)
                    Spacer()
                }
            }
        }
        .frame(height: 280)
    }

    private var placeholderGradient: some View {
        LinearGradient(
            colors: [
                viewModel.displayEvent.eventType.color.opacity(0.8),
                viewModel.displayEvent.eventType.color.opacity(0.4)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: viewModel.displayEvent.eventType.icon)
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    // MARK: - Event Type Badge

    private var eventTypeBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: viewModel.displayEvent.eventType.icon)
                .font(.subheadline)
            Text(viewModel.displayEvent.eventType.displayName)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, MadiniaSpacing.sm)
        .padding(.vertical, MadiniaSpacing.xs)
        .background(viewModel.displayEvent.eventType.color)
        .foregroundStyle(.white)
        .clipShape(Capsule())
    }

    // MARK: - Date & Time Section

    private var dateTimeSection: some View {
        HStack(spacing: MadiniaSpacing.md) {
            // Calendar icon with date
            VStack(spacing: 2) {
                Text(dayOfMonth)
                    .font(.system(size: 24, weight: .bold))
                Text(monthAbbr)
                    .font(.caption)
                    .textCase(.uppercase)
            }
            .frame(width: 50, height: 50)
            .background(viewModel.displayEvent.eventType.color.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.sm))

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.displayEvent.formattedDate)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(viewModel.displayEvent.formattedTime)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(MadiniaSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
    }

    private var dayOfMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: viewModel.displayEvent.startDate)
    }

    private var monthAbbr: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "MMM"
        return formatter.string(from: viewModel.displayEvent.startDate)
    }

    // MARK: - Location Section

    private var locationSection: some View {
        HStack(spacing: MadiniaSpacing.sm) {
            Image(systemName: viewModel.displayEvent.isOnline == true ? "video.fill" : "mappin.circle.fill")
                .font(.title2)
                .foregroundStyle(viewModel.displayEvent.eventType.color)
                .frame(width: 44, height: 44)
                .background(viewModel.displayEvent.eventType.color.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.displayEvent.isOnline == true ? "Événement en ligne" : "Lieu")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(viewModel.displayEvent.locationDisplay)
                    .font(.subheadline)
                    .fontWeight(.medium)

                // Meeting URL button for online events
                if let meetingUrl = viewModel.displayEvent.meetingUrl,
                   let url = URL(string: meetingUrl),
                   viewModel.isRegistered {
                    Link(destination: url) {
                        HStack(spacing: 4) {
                            Image(systemName: "link")
                            Text("Rejoindre la réunion")
                        }
                        .font(.caption)
                        .foregroundStyle(MadiniaColors.accent)
                    }
                }
            }

            Spacer()
        }
        .padding(MadiniaSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
    }

    // MARK: - Availability Section

    private func availabilitySection(max: Int) -> some View {
        let current = viewModel.displayEvent.currentParticipants ?? 0
        let available = viewModel.displayEvent.availableSpots ?? (max - current)
        let progress = Double(current) / Double(max)

        return VStack(alignment: .leading, spacing: MadiniaSpacing.xs) {
            HStack {
                Image(systemName: "person.3.fill")
                    .foregroundStyle(viewModel.displayEvent.eventType.color)
                Text("Places disponibles")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(available) / \(max)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(available == 0 ? .red : .primary)
            }

            ProgressView(value: progress)
                .tint(available == 0 ? .red : viewModel.displayEvent.eventType.color)
        }
        .padding(MadiniaSpacing.sm)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
    }

    // MARK: - Tags Section

    private func tagsSection(tags: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MadiniaSpacing.xs) {
                ForEach(tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(viewModel.displayEvent.eventType.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(viewModel.displayEvent.eventType.color.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Description Section

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            Text("À propos de cet événement")
                .font(.headline)

            if let description = viewModel.displayEvent.description {
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
            } else if let shortDesc = viewModel.displayEvent.shortDescription {
                Text(shortDesc)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
            }
        }
    }

    // MARK: - Bottom Action Bar

    private var bottomActionBar: some View {
        HStack(spacing: MadiniaSpacing.md) {
            if viewModel.isRegistered {
                // Already registered state
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                    Text("Inscrit")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(.green)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.green.opacity(0.15))
                .clipShape(Capsule())

                Spacer()

                // Cancel registration button
                Button {
                    Task { await viewModel.cancelRegistration() }
                } label: {
                    Text("Annuler")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.red)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Capsule())
                }
            } else {
                Spacer()

                // Register button
                Button {
                    showRegistrationSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar.badge.plus")
                        Text("S'inscrire")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(MadiniaColors.darkGrayFixed)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(MadiniaColors.accent)
                    .clipShape(Capsule())
                }
                .disabled(viewModel.displayEvent.isFull == true || viewModel.displayEvent.isPast)
                .opacity((viewModel.displayEvent.isFull == true || viewModel.displayEvent.isPast) ? 0.5 : 1)
            }
        }
        .padding(.horizontal, MadiniaSpacing.md)
        .padding(.vertical, MadiniaSpacing.sm)
        .padding(.bottom, 80)
        .background(
            LinearGradient(
                colors: [Color(.systemBackground).opacity(0), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        )
    }

    // MARK: - Helpers

    private var shareURL: URL {
        URL(string: "https://madinia.fr/events/\(event.slug)") ??
        URL(string: "https://madinia.fr")!
    }
}

// MARK: - Event Detail ViewModel

@Observable
final class EventDetailViewModel {
    private(set) var isLoading = false
    private(set) var isRegistered = false
    private(set) var registration: EventRegistration?

    private let initialEvent: Event
    private var fullEvent: Event?
    private let eventsService: EventsService

    /// Returns full event if loaded, otherwise initial event
    var displayEvent: Event {
        fullEvent ?? initialEvent
    }

    init(event: Event, eventsService: EventsService = .shared) {
        self.initialEvent = event
        self.eventsService = eventsService
        self.isRegistered = eventsService.isRegistered(eventId: event.id)
        self.registration = eventsService.registration(for: event.id)
    }

    @MainActor
    func loadEventDetails() async {
        isLoading = true

        if let result = await eventsService.fetchEvent(slug: initialEvent.slug) {
            fullEvent = result.event
            isRegistered = result.isRegistered
        }

        isLoading = false
    }

    func setRegistered(_ registration: EventRegistration) {
        self.registration = registration
        self.isRegistered = true
    }

    @MainActor
    func cancelRegistration() async {
        guard let registration = registration else { return }

        do {
            try await eventsService.cancelRegistration(registration)
            self.registration = nil
            self.isRegistered = false
        } catch {
            print("Failed to cancel registration: \(error)")
        }
    }
}

// MARK: - Previews

#Preview("Event Detail") {
    NavigationStack {
        EventDetailView(event: Event.sample)
    }
}
