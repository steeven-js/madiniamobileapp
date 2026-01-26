//
//  MyPreRegistrationsView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-25.
//

import SwiftUI

/// View displaying the user's pre-registrations for formations.
/// Accessible from the UserSpaceView.
struct MyPreRegistrationsView: View {
    @State private var viewModel = MyPreRegistrationsViewModel()

    var body: some View {
        Group {
            switch viewModel.loadingState {
            case .idle, .loading:
                loadingView
            case .loaded(let registrations):
                if registrations.isEmpty {
                    emptyStateView
                } else {
                    registrationsListView(registrations: registrations)
                }
            case .error(let message):
                errorView(message: message)
            }
        }
        .navigationTitle("Mes pré-inscriptions")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadPreRegistrations()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: MadiniaSpacing.lg) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Chargement de vos pré-inscriptions...")
                .font(MadiniaTypography.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: MadiniaSpacing.xl) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundStyle(MadiniaColors.violet.opacity(0.6))

            VStack(spacing: MadiniaSpacing.sm) {
                Text("Aucune pré-inscription")
                    .font(MadiniaTypography.title2)
                    .foregroundStyle(.primary)

                Text("Vous n'avez pas encore de pré-inscription.\nParcourez nos formations et pré-inscrivez-vous !")
                    .font(MadiniaTypography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, MadiniaSpacing.xl)
            }

            // Quota info
            quotaInfoBadge
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 100)
    }

    // MARK: - Registrations List

    private func registrationsListView(registrations: [PreRegistration]) -> some View {
        ScrollView {
            VStack(spacing: MadiniaSpacing.md) {
                // Quota info at top
                quotaInfoCard
                    .padding(.horizontal, MadiniaSpacing.md)

                // Registrations list
                LazyVStack(spacing: MadiniaSpacing.md) {
                    ForEach(registrations) { registration in
                        PreRegistrationCard(registration: registration)
                    }
                }
                .padding(.horizontal, MadiniaSpacing.md)
            }
            .padding(.vertical, MadiniaSpacing.md)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Quota Info

    private var quotaInfoBadge: some View {
        HStack(spacing: MadiniaSpacing.xs) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(MadiniaColors.violet)
            Text("\(viewModel.remainingCount)/\(viewModel.maxAllowed) pré-inscriptions disponibles")
                .font(MadiniaTypography.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, MadiniaSpacing.md)
        .padding(.vertical, MadiniaSpacing.sm)
        .background(MadiniaColors.violet.opacity(0.1))
        .clipShape(Capsule())
    }

    private var quotaInfoCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Pré-inscriptions utilisées")
                    .font(MadiniaTypography.caption)
                    .foregroundStyle(.secondary)

                Text("\(viewModel.usedCount) / \(viewModel.maxAllowed)")
                    .font(MadiniaTypography.headline)
                    .foregroundStyle(.primary)
            }

            Spacer()

            // Progress indicator
            ZStack {
                Circle()
                    .stroke(MadiniaColors.violet.opacity(0.2), lineWidth: 6)
                    .frame(width: 50, height: 50)

                Circle()
                    .trim(from: 0, to: CGFloat(viewModel.usedCount) / CGFloat(viewModel.maxAllowed))
                    .stroke(MadiniaColors.violet, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))

                Text("\(viewModel.remainingCount)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(MadiniaColors.violet)
            }
        }
        .padding(MadiniaSpacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        VStack(spacing: MadiniaSpacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Erreur de chargement")
                .font(MadiniaTypography.title2)
                .foregroundStyle(.primary)

            Text(message)
                .font(MadiniaTypography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, MadiniaSpacing.xl)

            Button("Réessayer") {
                Task {
                    await viewModel.loadPreRegistrations()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(MadiniaColors.violet)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Pre-Registration Card

/// Card component for displaying a single pre-registration.
struct PreRegistrationCard: View {
    let registration: PreRegistration

    var body: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            // Header with formation info
            HStack(spacing: MadiniaSpacing.sm) {
                // Formation image
                formationImage

                // Formation title and date
                VStack(alignment: .leading, spacing: 4) {
                    Text(registration.formation?.title ?? "Formation #\(registration.formationId)")
                        .font(MadiniaTypography.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    Text("Demande du \(registration.formattedDate)")
                        .font(MadiniaTypography.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Divider()

            // Status and info
            HStack {
                // Status badge
                statusBadge

                Spacer()

                // Format and funding
                VStack(alignment: .trailing, spacing: 2) {
                    Text(registration.preferredFormatLabel)
                        .font(MadiniaTypography.caption)
                        .foregroundStyle(.secondary)

                    Text(registration.fundingMethodLabel)
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

    // MARK: - Formation Image

    private var formationImage: some View {
        Group {
            if let imageUrl = registration.formation?.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        imagePlaceholder
                    @unknown default:
                        imagePlaceholder
                    }
                }
            } else {
                imagePlaceholder
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.sm))
    }

    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: MadiniaRadius.sm)
            .fill(
                LinearGradient(
                    colors: [MadiniaColors.violet.opacity(0.3), MadiniaColors.violet.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: "graduationcap.fill")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.7))
            }
    }

    // MARK: - Status Badge

    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(registration.statusLabel)
                .font(MadiniaTypography.caption)
                .fontWeight(.medium)
                .foregroundStyle(statusColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(statusColor.opacity(0.1))
        .clipShape(Capsule())
    }

    private var statusColor: Color {
        switch registration.status {
        case "en_attente":
            return .orange
        case "groupe_en_constitution":
            return MadiniaColors.violet
        case "groupe_complet", "session_planifiee":
            return .blue
        case "inscrit":
            return .green
        case "annule":
            return .red
        default:
            return .secondary
        }
    }
}

// MARK: - Previews

#Preview("With Registrations") {
    NavigationStack {
        MyPreRegistrationsView()
    }
}

#Preview("Empty State") {
    NavigationStack {
        MyPreRegistrationsView()
    }
}

#Preview("Card") {
    PreRegistrationCard(
        registration: PreRegistration(
            id: 1,
            firstName: "Jean",
            lastName: "Dupont",
            email: "jean@example.com",
            phone: "0612345678",
            formationId: 1,
            fundingMethod: "cpf",
            preferredFormat: "presentiel",
            comments: nil,
            status: "en_attente",
            source: "mobile_app",
            deviceUUID: "test-uuid",
            createdAt: "2026-01-25T10:00:00Z",
            formation: PreRegistrationFormation(
                id: 1,
                title: "Starter Pack - IA Generative",
                slug: "starter-pack",
                duration: "14 heures",
                level: "debutant",
                imageUrl: nil
            )
        )
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
