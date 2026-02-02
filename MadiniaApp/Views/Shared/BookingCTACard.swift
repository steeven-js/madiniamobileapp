//
//  BookingCTACard.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-02.
//

import SwiftUI

/// CTA card for booking an appointment via Calendly.
struct BookingCTACard: View {
    /// Action to perform when tapped
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: MadiniaSpacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [MadiniaColors.accent, MadiniaColors.accent.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)

                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 24))
                        .foregroundStyle(MadiniaColors.darkGrayFixed)
                }

                // Text content
                VStack(alignment: .leading, spacing: MadiniaSpacing.xxs) {
                    Text("Besoin d'un accompagnement ?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text("Réservez un appel découverte gratuit")
                        .font(MadiniaTypography.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Arrow
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(MadiniaColors.accent)
            }
            .padding(MadiniaSpacing.md)
            .background(
                LinearGradient(
                    colors: [
                        MadiniaColors.accent.opacity(0.1),
                        MadiniaColors.violet.opacity(0.05)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: MadiniaRadius.lg)
                    .stroke(MadiniaColors.accent.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview {
    VStack {
        BookingCTACard {
            print("Booking tapped")
        }
        .padding()
    }
}

#Preview("Dark Mode") {
    VStack {
        BookingCTACard {
            print("Booking tapped")
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
