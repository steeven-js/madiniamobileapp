//
//  MadiConsentView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-20.
//

import SwiftUI

/// Consent view displayed before first use of Madi AI chat.
/// Required by App Store guidelines 5.1.1(i) and 5.1.2(i) for third-party AI data sharing.
struct MadiConsentView: View {
    /// Called when user accepts the consent
    var onAccept: () -> Void

    /// Called when user declines
    var onDecline: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: MadiniaSpacing.lg) {
                // Header
                headerSection

                // Data disclosure
                dataDisclosureSection

                // Third-party disclosure
                thirdPartySection

                // Privacy policy link
                privacyPolicyLink

                // Action buttons
                actionButtons
            }
            .padding(MadiniaSpacing.lg)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: MadiniaSpacing.md) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [MadiniaColors.accent, MadiniaColors.violet],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)

                Image(systemName: "sparkles")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
            }

            Text("Madi utilise l'intelligence artificielle")
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Avant d'utiliser Madi, veuillez prendre connaissance des informations suivantes concernant le traitement de vos données.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Data Disclosure

    private var dataDisclosureSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.md) {
            Label("Données transmises", systemImage: "doc.text")
                .font(.headline)

            VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
                dataRow(
                    icon: "text.bubble",
                    title: "Vos messages",
                    description: "Les messages que vous envoyez à Madi"
                )
                dataRow(
                    icon: "heart",
                    title: "Vos favoris",
                    description: "Les titres des formations ajoutées en favoris"
                )
                dataRow(
                    icon: "eye",
                    title: "Formations consultées",
                    description: "Les titres des formations récemment consultées"
                )
                dataRow(
                    icon: "iphone",
                    title: "Identifiant appareil",
                    description: "Un identifiant anonyme pour retrouver votre historique"
                )
            }
        }
        .padding(MadiniaSpacing.md)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
    }

    // MARK: - Third Party

    private var thirdPartySection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.md) {
            Label("Service tiers", systemImage: "arrow.right.arrow.left.circle")
                .font(.headline)

            Text("Vos données sont envoyées aux serveurs de **Madinia**, puis transmises à **OpenAI** (fournisseur du service ChatGPT) pour générer les réponses de Madi.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: MadiniaSpacing.xs) {
                bulletPoint("Les données sont traitées par OpenAI conformément à leur politique de confidentialité")
                bulletPoint("Aucune donnée personnelle (nom, email, téléphone) n'est transmise")
                bulletPoint("Vous pouvez supprimer votre historique à tout moment depuis le chat")
            }
        }
        .padding(MadiniaSpacing.md)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
    }

    // MARK: - Privacy Policy Link

    private var privacyPolicyLink: some View {
        Link(destination: URL(string: "https://madinia.fr/politique-de-confidentialite")!) {
            HStack {
                Image(systemName: "hand.raised.fill")
                    .foregroundStyle(MadiniaColors.accent)
                Text("Consulter notre politique de confidentialité")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption)
            }
            .foregroundStyle(.primary)
            .padding(MadiniaSpacing.md)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
        }
    }

    // MARK: - Actions

    private var actionButtons: some View {
        VStack(spacing: MadiniaSpacing.sm) {
            Button {
                onAccept()
            } label: {
                Text("Accepter et continuer")
                    .font(.body)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(MadiniaColors.accent)

            Button {
                onDecline()
            } label: {
                Text("Refuser")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, MadiniaSpacing.sm)
    }

    // MARK: - Helpers

    private func dataRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: MadiniaSpacing.sm) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(MadiniaColors.accent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: MadiniaSpacing.xs) {
            Text("•")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    MadiConsentView(
        onAccept: { print("Accepted") },
        onDecline: { print("Declined") }
    )
}
