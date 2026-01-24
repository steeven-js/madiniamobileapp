//
//  PreRegistrationSheet.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI
import UIKit

/// Sheet view for formation pre-registration.
/// Displays a simple form to collect user email for pre-registration.
struct PreRegistrationSheet: View {
    /// The formation to pre-register for
    let formation: Formation

    /// Dismiss action from environment
    @Environment(\.dismiss) private var dismiss

    /// ViewModel for handling submission
    @State private var viewModel = PreRegistrationViewModel()

    /// User's email input
    @State private var email = ""

    /// Whether to show error alert
    @State private var showError = false

    /// Whether to show success animation
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            Group {
                if showSuccess {
                    successView
                } else {
                    formContent
                }
            }
            .navigationTitle(showSuccess ? "" : "Pré-inscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !showSuccess {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Annuler") {
                            dismiss()
                        }
                        .disabled(viewModel.isSubmitting)
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(viewModel.isSubmitting || showSuccess)
        .alert("Erreur", isPresented: $showError) {
            Button("Réessayer") {
                viewModel.reset()
            }
            Button("Annuler", role: .cancel) {
                dismiss()
            }
        } message: {
            Text(viewModel.errorMessage ?? "Une erreur est survenue")
        }
        .onChange(of: viewModel.state) { _, newState in
            switch newState {
            case .success:
                handleSuccess()
            case .error:
                showError = true
            default:
                break
            }
        }
    }

    // MARK: - Form Content

    private var formContent: some View {
        VStack(spacing: 24) {
            // Formation context
            formationContext

            // Email input
            emailField

            Spacer()

            // Submit button
            submitButton
        }
        .padding()
    }

    // MARK: - Success View

    private var successView: some View {
        VStack(spacing: 24) {
            Spacer()

            // Animated checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: showSuccess)

            // Confirmation message
            VStack(spacing: 8) {
                Text("Merci !")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Nous vous contacterons bientôt.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Pré-inscription confirmée. Merci ! Nous vous contacterons bientôt.")
    }

    // MARK: - Success Handling

    private func handleSuccess() {
        // Trigger haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Show success view with animation
        withAnimation(.easeInOut(duration: 0.3)) {
            showSuccess = true
        }

        // Auto-dismiss after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            dismiss()
        }
    }

    // MARK: - Formation Context

    private var formationContext: some View {
        VStack(spacing: 8) {
            Text("Vous souhaitez vous inscrire à :")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(formation.title)
                .font(.headline)
                .multilineTextAlignment(.center)

            // Show category if available
            if let category = formation.category {
                let color = category.color.flatMap { Color(hex: $0) }
                InfoBadge(style: .category(category.name, color))
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Formation sélectionnée: \(formation.title)")
    }

    // MARK: - Email Field

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Votre email")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                TextField("exemple@email.com", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                // Validation indicator
                validationIndicator
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Adresse email, \(emailAccessibilityStatus)")
            .accessibilityHint("Entrez votre adresse email pour la pré-inscription")

            // Error message
            if emailValidation == .invalid {
                Text("Format d'email invalide")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .accessibilityLabel("Erreur: format d'email invalide")
            }
        }
    }

    // MARK: - Validation Indicator

    @ViewBuilder
    private var validationIndicator: some View {
        switch emailValidation {
        case .empty:
            EmptyView()
        case .invalid:
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red)
                .accessibilityHidden(true)
        case .valid:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .accessibilityHidden(true)
        }
    }

    // MARK: - Submit Button

    private var submitButton: some View {
        Button {
            submitPreRegistration()
        } label: {
            Group {
                if viewModel.isSubmitting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Confirmer")
                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
        }
        .background(isButtonEnabled ? Color.accentColor : Color.accentColor.opacity(0.6))
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .disabled(!isButtonEnabled)
        .accessibilityLabel("Confirmer la pré-inscription")
        .accessibilityHint(isButtonEnabled ? "Envoie votre demande de pré-inscription" : "Entrez une adresse email valide pour continuer")
    }

    // MARK: - Computed Properties

    /// Current email validation state
    private var emailValidation: EmailValidator.Result {
        EmailValidator.validate(email)
    }

    /// Whether the email is valid
    private var isEmailValid: Bool {
        emailValidation == .valid
    }

    /// Whether the submit button should be enabled
    private var isButtonEnabled: Bool {
        isEmailValid && !viewModel.isSubmitting
    }

    /// Accessibility status for email field
    private var emailAccessibilityStatus: String {
        switch emailValidation {
        case .empty:
            return "champ vide"
        case .invalid:
            return "format invalide"
        case .valid:
            return "format valide"
        }
    }

    // MARK: - Actions

    private func submitPreRegistration() {
        // Validate email before submitting
        guard isEmailValid else { return }

        Task {
            await viewModel.submit(formationId: formation.id, email: email)
        }
    }
}

// MARK: - Previews

#Preview("Pre-registration Sheet") {
    PreRegistrationSheet(formation: .sample)
}

#Preview("With Category") {
    PreRegistrationSheet(formation: Formation(
        id: 1,
        title: "Starter Pack - IA Générative",
        slug: "starter-pack",
        shortDescription: "Formation complète",
        duration: "14 heures",
        durationHours: 14,
        level: "debutant",
        levelLabel: "Débutant",
        certification: true,
        certificationLabel: "Certifiante",
        imageUrl: nil,
        category: FormationCategory(id: 1, name: "IA Générative", slug: "ia", color: "#8B5CF6", icon: nil),
        description: nil,
        objectives: nil,
        prerequisites: nil,
        program: nil,
        targetAudience: nil,
        trainingMethods: nil,
        pdfFileUrl: nil,
        viewsCount: nil,
        publishedAt: nil
    ))
}
