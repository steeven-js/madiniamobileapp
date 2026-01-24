//
//  ServiceCard.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// Card component displaying a service in the horizontal scroll section.
/// Similar to the "New Courses" card style from Figma (16 Search).
struct ServiceCard: View {
    /// The service to display
    let service: Service

    /// Action when card is tapped
    var onTap: (() -> Void)?

    /// Card dimensions (matching Figma mockup)
    private let cardWidth: CGFloat = 200
    private let cardHeight: CGFloat = 200
    private let imageHeight: CGFloat = 130

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Hero image
                heroSection

                // Content: title and description
                contentSection
            }
            .frame(width: cardWidth, height: cardHeight)
            .background(MadiniaColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.lg))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(service.name)
        .accessibilityHint("Appuyez pour voir les détails de ce service")
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        ZStack(alignment: .topLeading) {
            // Image or gradient placeholder
            if let imageUrl = service.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        placeholderGradient
                    @unknown default:
                        placeholderGradient
                    }
                }
            } else {
                placeholderGradient
            }
        }
        .frame(width: cardWidth, height: imageHeight)
        .clipped()
    }

    private var placeholderGradient: some View {
        MadiniaColors.placeholderGradient
            .overlay {
                serviceIcon
            }
    }

    private var serviceIcon: some View {
        Image(systemName: iconSystemName)
            .font(.system(size: 32))
            .foregroundStyle(.white.opacity(0.7))
    }

    /// Maps heroicon names to SF Symbols
    private var iconSystemName: String {
        guard let icon = service.icon else { return "briefcase.fill" }

        switch icon {
        case "heroicon-o-presentation-chart-line":
            return "chart.line.uptrend.xyaxis"
        case "heroicon-o-clipboard-document-check":
            return "doc.text.magnifyingglass"
        case "heroicon-o-user-group":
            return "person.2.fill"
        default:
            return "briefcase.fill"
        }
    }

    // MARK: - Content Section

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.xxs) {
            // Title (2 lines max)
            Text(service.name)
                .font(MadiniaTypography.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            // Short description
            if let description = service.shortDescription {
                Text(description)
                    .font(MadiniaTypography.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(MadiniaSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Previews

#Preview("Horizontal Scroll") {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: MadiniaSpacing.sm) {
            ForEach(Service.samples) { service in
                ServiceCard(service: service) {
                    print("Tapped: \(service.name)")
                }
            }
        }
        .padding(MadiniaSpacing.md)
    }
}

#Preview("Single Card") {
    ServiceCard(service: .sample)
        .padding()
}
