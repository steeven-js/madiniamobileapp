//
//  ServiceDetailView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// Detail view for a service, presented as a sheet.
/// Shows full description and contact CTA.
struct ServiceDetailView: View {
    /// The service to display
    let service: Service

    /// Environment dismiss action
    @Environment(\.dismiss) private var dismiss

    /// Hero image height
    private let heroHeight: CGFloat = 200

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero image
                    heroSection

                    // Content
                    contentSection
                }
            }
            .navigationTitle(service.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Image or gradient
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

            // Overlay gradient for text readability
            LinearGradient(
                colors: [.clear, .black.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )

            // Icon badge
            VStack {
                Spacer()
                HStack {
                    serviceIcon
                        .padding(MadiniaSpacing.md)
                    Spacer()
                }
            }
        }
        .frame(height: heroHeight)
        .clipped()
    }

    private var placeholderGradient: some View {
        MadiniaColors.placeholderGradient
    }

    private var serviceIcon: some View {
        Image(systemName: iconSystemName)
            .font(.system(size: 28))
            .foregroundStyle(.white)
            .padding(MadiniaSpacing.sm)
            .background(MadiniaColors.violet.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.sm))
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
        VStack(alignment: .leading, spacing: MadiniaSpacing.lg) {
            // Short description
            if let shortDescription = service.shortDescription {
                Text(shortDescription)
                    .font(MadiniaTypography.headline)
                    .foregroundStyle(.secondary)
            }

            // Full description (HTML stripped)
            if let description = service.description {
                Text(stripHTML(from: description))
                    .font(MadiniaTypography.body)
                    .foregroundStyle(.primary)
            }

            // Contact CTA
            contactCTA
        }
        .padding(MadiniaSpacing.md)
    }

    /// Strips HTML tags from content for display
    private func stripHTML(from content: String) -> String {
        var result = content
        // Remove common HTML tags
        let patterns = ["<[^>]+>", "&nbsp;", "&amp;", "&lt;", "&gt;", "&quot;", "&#039;"]
        let replacements = ["", " ", "&", "<", ">", "\"", "'"]

        for (pattern, replacement) in zip(patterns, replacements) {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(result.startIndex..., in: result)
                result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: replacement)
            }
        }

        // Clean up multiple spaces and newlines
        result = result.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var contactCTA: some View {
        VStack(spacing: MadiniaSpacing.sm) {
            Text("Intéressé par ce service ?")
                .font(MadiniaTypography.headline)
                .fontWeight(.semibold)

            NavigationLink {
                ContactView()
            } label: {
                Text("Nous contacter")
                    .font(MadiniaTypography.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(MadiniaColors.darkGray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, MadiniaSpacing.sm)
                    .background(MadiniaColors.gold)
                    .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
            }
        }
        .padding(.top, MadiniaSpacing.md)
    }
}

// MARK: - Preview

#Preview {
    ServiceDetailView(service: .sample)
}
