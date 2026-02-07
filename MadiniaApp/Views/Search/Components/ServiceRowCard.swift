//
//  ServiceRowCard.swift
//  MadiniaApp
//
//  Carte horizontale pour afficher un service dans une liste verticale.
//

import SwiftUI

/// Horizontal row card for services in vertical list sections.
/// Shows thumbnail, name, short description, view count, and favorite button.
struct ServiceRowCard: View {
    /// The service to display
    let service: Service

    /// Action when card is tapped
    var onTap: (() -> Void)?

    /// Card dimensions
    private let thumbnailSize: CGFloat = 70
    private let cardHeight: CGFloat = 100

    /// Check if service is favorited
    private var isFavorite: Bool {
        FavoritesService.shared.isServiceFavorite(serviceId: service.id)
    }

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: MadiniaSpacing.sm) {
                // Thumbnail
                thumbnailView

                // Content
                VStack(alignment: .leading, spacing: MadiniaSpacing.xxs) {
                    // Name
                    Text(service.name)
                        .font(MadiniaTypography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)

                    // Short description
                    if let description = service.shortDescription {
                        Text(description)
                            .font(MadiniaTypography.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    // Metadata row
                    HStack(spacing: MadiniaSpacing.sm) {
                        // Service badge
                        HStack(spacing: MadiniaSpacing.xxs) {
                            Image(systemName: "briefcase.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(MadiniaColors.violet)

                            Text("Service")
                                .font(MadiniaTypography.caption2)
                                .foregroundStyle(MadiniaColors.violet)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(MadiniaColors.violet.opacity(0.1))
                        .clipShape(Capsule())

                        Spacer()

                        // View count
                        if let viewsCount = service.viewsCount, viewsCount > 0 {
                            Label("\(viewsCount) vues", systemImage: "eye")
                                .font(MadiniaTypography.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Favorite button
                Button {
                    HapticManager.favoriteAdded()
                    Task {
                        await FavoritesService.shared.toggleServiceFavorite(serviceId: service.id)
                    }
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 18))
                        .foregroundStyle(isFavorite ? .red : .secondary.opacity(0.5))
                        .animation(.spring(response: 0.3), value: isFavorite)
                }
                .buttonStyle(.plain)
            }
            .padding(MadiniaSpacing.sm)
            .frame(height: cardHeight)
            .background(MadiniaColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
            .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .pressScale(0.98)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("Appuyez pour voir les détails de ce service")
    }

    private var accessibilityDescription: String {
        var desc = service.name
        if let viewsCount = service.viewsCount {
            desc += ", \(viewsCount) vues"
        }
        return desc
    }

    // MARK: - Thumbnail

    private var thumbnailView: some View {
        Group {
            if let imageUrl = service.imageUrl, let url = URL(string: imageUrl) {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ShimmerPlaceholder()
                }
            } else {
                placeholderView
            }
        }
        .frame(width: thumbnailSize, height: thumbnailSize)
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.sm))
    }

    private var placeholderView: some View {
        LinearGradient(
            colors: [MadiniaColors.violet.opacity(0.6), MadiniaColors.accent.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: iconForService)
                .font(.title2)
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    /// Icon based on service type
    private var iconForService: String {
        switch service.slug {
        case "conference-ia", "conferences-ia":
            return "person.3.fill"
        case "audit-et-conseils-ia", "audit-conseils":
            return "checkmark.shield.fill"
        case "accompagnement-perso", "accompagnement":
            return "person.2.fill"
        default:
            return "briefcase.fill"
        }
    }
}

// MARK: - Previews

#Preview("Service Row Card") {
    VStack(spacing: MadiniaSpacing.sm) {
        ForEach(Service.samples) { service in
            ServiceRowCard(service: service) {
                print("Tapped: \(service.name)")
            }
        }
    }
    .padding(MadiniaSpacing.md)
}

#Preview("Single Card") {
    ServiceRowCard(service: .sample)
        .padding()
}
