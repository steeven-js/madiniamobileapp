//
//  BookingSection.swift
//  MadiniaApp
//
//  Section de réservation sur l'écran d'accueil.
//  Permet de réserver une consultation via Calendly.
//

import SwiftUI

/// Section de réservation de consultation sur l'écran d'accueil
struct BookingSection: View {
    /// Action lors du tap sur le bouton de réservation
    var onBookTap: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            // Header
            Text("Consultation")
                .font(MadiniaTypography.title2)
                .fontWeight(.bold)

            // Booking card
            Button {
                HapticManager.tap()
                onBookTap?()
            } label: {
                HStack(spacing: MadiniaSpacing.md) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(MadiniaColors.accent.opacity(0.15))
                            .frame(width: 56, height: 56)

                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(MadiniaColors.accent)
                    }

                    // Content
                    VStack(alignment: .leading, spacing: MadiniaSpacing.xxs) {
                        Text("Réserver un créneau")
                            .font(MadiniaTypography.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)

                        Text("Échangez avec un expert Madin.IA")
                            .font(MadiniaTypography.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // Arrow
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(MadiniaSpacing.md)
                .background(MadiniaColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.lg))
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(.plain)
            .pressScale(0.98)
        }
    }
}

// MARK: - Previews

#Preview("Booking Section") {
    VStack {
        BookingSection {
            print("Book tapped")
        }
    }
    .padding()
}

#Preview("Dark Mode") {
    VStack {
        BookingSection {
            print("Book tapped")
        }
    }
    .padding()
    .preferredColorScheme(.dark)
}
