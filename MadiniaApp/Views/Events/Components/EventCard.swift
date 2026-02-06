//
//  EventCard.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-06.
//

import SwiftUI

/// Card component displaying an event in the events feed.
/// Shows event type badge, title, date/time, location, and availability.
struct EventCard: View {
    /// The event to display
    let event: Event

    /// Whether to show as a compact horizontal card (for carousel)
    var isCompact: Bool = false

    /// Check if user is registered for this event
    private var isRegistered: Bool {
        EventsService.shared.isRegistered(eventId: event.id)
    }

    var body: some View {
        if isCompact {
            compactCard
        } else {
            fullCard
        }
    }

    // MARK: - Full Card (for list)

    private var fullCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Hero image with type badge
            heroSection

            // Content
            VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
                // Title
                Text(event.title)
                    .font(MadiniaTypography.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                // Description
                if let description = event.shortDescription {
                    Text(description)
                        .font(MadiniaTypography.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                // Date & Time
                HStack(spacing: MadiniaSpacing.xs) {
                    Image(systemName: "calendar")
                        .foregroundStyle(event.eventType.color)
                    Text(event.formattedDate)
                        .font(MadiniaTypography.subheadline)
                    Text("•")
                        .foregroundStyle(.tertiary)
                    Text(event.formattedTime)
                        .font(MadiniaTypography.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Location
                HStack(spacing: MadiniaSpacing.xs) {
                    Image(systemName: event.isOnline == true ? "video.fill" : "mappin.circle.fill")
                        .foregroundStyle(event.eventType.color)
                    Text(event.locationDisplay)
                        .font(MadiniaTypography.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                // Bottom row: availability + registered badge
                HStack {
                    if let spotsText = event.spotsRemainingText {
                        Text(spotsText)
                            .font(MadiniaTypography.caption)
                            .foregroundStyle(event.isFull == true ? .red : .secondary)
                    }

                    Spacer()

                    if isRegistered {
                        registeredBadge
                    }
                }
            }
            .padding(MadiniaSpacing.md)
        }
        .background(MadiniaColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.lg))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("Appuyez pour voir les détails de l'événement")
    }

    // MARK: - Compact Card (for carousel)

    private var compactCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Hero image with type badge
            ZStack(alignment: .topLeading) {
                if let imageUrl = event.imageUrl, let url = URL(string: imageUrl) {
                    CachedAsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ShimmerPlaceholder()
                    }
                } else {
                    placeholderGradient
                }

                // Type badge
                eventTypeBadge
                    .padding(MadiniaSpacing.xs)
            }
            .frame(height: 120)
            .clipped()

            // Content
            VStack(alignment: .leading, spacing: MadiniaSpacing.xs) {
                Text(event.title)
                    .font(MadiniaTypography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                HStack(spacing: MadiniaSpacing.xxs) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundStyle(event.eventType.color)
                    Text(event.shortFormattedDate)
                        .font(MadiniaTypography.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    if isRegistered {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            }
            .padding(MadiniaSpacing.sm)
        }
        .frame(width: 200)
        .background(MadiniaColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    // MARK: - Subviews

    private var heroSection: some View {
        ZStack(alignment: .topLeading) {
            if let imageUrl = event.imageUrl, let url = URL(string: imageUrl) {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ShimmerPlaceholder()
                }
            } else {
                placeholderGradient
            }

            // Type badge
            eventTypeBadge
                .padding(MadiniaSpacing.sm)
        }
        .frame(height: 160)
        .clipped()
    }

    private var placeholderGradient: some View {
        LinearGradient(
            colors: [event.eventType.color.opacity(0.8), event.eventType.color.opacity(0.4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: event.eventType.icon)
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    private var eventTypeBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: event.eventType.icon)
                .font(.caption2)
            Text(event.eventType.displayName)
                .font(MadiniaTypography.caption2)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, MadiniaSpacing.xs)
        .padding(.vertical, MadiniaSpacing.xxs)
        .background(event.eventType.color)
        .foregroundStyle(.white)
        .clipShape(Capsule())
    }

    private var registeredBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption2)
            Text("Inscrit")
                .font(MadiniaTypography.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, MadiniaSpacing.xs)
        .padding(.vertical, MadiniaSpacing.xxs)
        .background(Color.green.opacity(0.15))
        .foregroundStyle(.green)
        .clipShape(Capsule())
    }

    // MARK: - Accessibility

    private var accessibilityDescription: String {
        var parts: [String] = [
            event.eventType.displayName,
            event.title,
            event.formattedDate,
            event.formattedTime,
            event.locationDisplay
        ]
        if isRegistered {
            parts.append("Vous êtes inscrit")
        }
        if event.isFull == true {
            parts.append("Complet")
        } else if let spots = event.availableSpots {
            parts.append("\(spots) places disponibles")
        }
        return parts.joined(separator: ", ")
    }
}

// MARK: - Previews

#Preview("Full Card") {
    ScrollView {
        VStack(spacing: MadiniaSpacing.md) {
            ForEach(Event.samples) { event in
                EventCard(event: event)
            }
        }
        .padding()
    }
}

#Preview("Compact Cards") {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: MadiniaSpacing.md) {
            ForEach(Event.samples) { event in
                EventCard(event: event, isCompact: true)
            }
        }
        .padding()
    }
}
