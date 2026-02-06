//
//  EventsView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-06.
//

import SwiftUI

/// Main view for displaying upcoming events.
/// Shows featured events in a carousel, filter chips, and a list of upcoming events.
/// Can be used standalone or embedded in MadiniaHubView.
struct EventsView: View {
    /// ViewModel managing events data and loading state
    @State private var viewModel = EventsViewModel()

    /// Whether to show within its own NavigationStack (false when embedded)
    var embedded: Bool = false

    var body: some View {
        if embedded {
            content
                .navigationDestination(for: Event.self) { event in
                    EventDetailView(event: event)
                }
                .task {
                    await viewModel.loadEvents()
                }
        } else {
            NavigationStack {
                content
                    .navigationTitle("Événements")
                    .navigationDestination(for: Event.self) { event in
                        EventDetailView(event: event)
                    }
            }
            .task {
                await viewModel.loadEvents()
            }
        }
    }

    // MARK: - Content View

    @ViewBuilder
    private var content: some View {
        switch viewModel.loadingState {
        case .idle, .loading:
            LoadingView(message: "Chargement des événements...")

        case .loaded:
            if viewModel.hasEvents {
                eventsList
            } else {
                emptyState
            }

        case .error(let message):
            ErrorView(message: message) {
                Task { await viewModel.loadEvents() }
            }
        }
    }

    // MARK: - Events List

    private var eventsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: MadiniaSpacing.lg) {
                // Featured carousel
                if viewModel.hasFeaturedEvents {
                    featuredSection
                }

                // Filter chips
                VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
                    Text("Tous les événements")
                        .font(MadiniaTypography.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, MadiniaSpacing.md)

                    EventTypeFilter(selectedType: $viewModel.selectedEventType)
                }

                // Events list
                VStack(spacing: MadiniaSpacing.md) {
                    ForEach(viewModel.filteredEvents) { event in
                        NavigationLink(value: event) {
                            EventCard(event: event)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, MadiniaSpacing.md)

                // Empty filter state
                if viewModel.filteredEvents.isEmpty && viewModel.selectedEventType != nil {
                    ContentUnavailableView {
                        Label("Aucun événement", systemImage: "calendar.badge.exclamationmark")
                    } description: {
                        Text("Aucun \(viewModel.selectedEventType?.displayName.lowercased() ?? "événement") prévu pour le moment.")
                    }
                    .padding(.vertical, MadiniaSpacing.xl)
                }
            }
            .padding(.vertical, MadiniaSpacing.md)
            .tabBarSafeArea()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Featured Section

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            HStack {
                Text("À la une")
                    .font(MadiniaTypography.title2)
                    .fontWeight(.bold)

                Spacer()

                Image(systemName: "star.fill")
                    .foregroundStyle(MadiniaColors.accent)
            }
            .padding(.horizontal, MadiniaSpacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MadiniaSpacing.md) {
                    ForEach(viewModel.featuredEvents) { event in
                        NavigationLink(value: event) {
                            EventCard(event: event, isCompact: true)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, MadiniaSpacing.md)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ScrollView {
            VStack(spacing: MadiniaSpacing.lg) {
                ContentUnavailableView {
                    Label("Événements", systemImage: "calendar.badge.clock")
                } description: {
                    Text("Les événements Madin.IA arrivent bientôt !\n\nRetrouvez ici nos webinaires, ateliers et rencontres à venir.")
                }
                .padding(.top, MadiniaSpacing.xl)
            }
            .padding(MadiniaSpacing.md)
            .tabBarSafeArea()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

// MARK: - Previews

#Preview {
    EventsView()
}

#Preview("Embedded") {
    NavigationStack {
        EventsView(embedded: true)
            .navigationTitle("Événements")
    }
}
