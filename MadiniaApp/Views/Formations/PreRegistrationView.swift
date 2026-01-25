//
//  PreRegistrationView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-25.
//

import SwiftUI

/// Full-page pre-registration form view.
/// Collects user information for formation enrollment.
struct PreRegistrationView: View {
    /// The formation to pre-register for
    let formation: Formation

    /// Environment dismiss for navigation
    @Environment(\.dismiss) private var dismiss

    /// ViewModel for handling form state and submission
    @State private var viewModel = PreRegistrationViewModel()

    /// Focus state for form fields
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case firstName, lastName, email, phone, comments
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .success:
                successView
            default:
                formView
            }
        }
        .navigationTitle("Pré-inscription")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.state) { _, newState in
            if newState == .success {
                triggerSuccessHaptic()
            }
        }
    }

    // MARK: - Form View

    private var formView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Info section
                infoSection

                // Formation context banner
                formationBanner

                // Form fields
                formFields

                // Submit button
                submitButton

                // Consent text
                consentText

                // Error message
                if case .error(let message) = viewModel.state {
                    errorMessage(message)
                }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(Color.accentColor)
                Text("Comment ça marche ?")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 12) {
                infoStep(number: 1, text: "Remplissez le formulaire ci-dessous")
                infoStep(number: 2, text: "Notre équipe vous contactera sous 48h")
                infoStep(number: 3, text: "Nous définirons ensemble votre parcours")
                infoStep(number: 4, text: "Vous serez accompagné jusqu'à l'inscription")
            }
        }
        .padding()
        .background(Color.accentColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func infoStep(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(Color.accentColor)
                .clipShape(Circle())

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Formation Banner

    private var formationBanner: some View {
        VStack(spacing: 8) {
            Text("Formation sélectionnée")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(formation.title)
                .font(.headline)
                .multilineTextAlignment(.center)

            if let category = formation.category {
                let color = category.color.flatMap { Color(hex: $0) }
                InfoBadge(style: .category(category.name, color))
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Form Fields

    private var formFields: some View {
        VStack(spacing: 16) {
            // Name row
            HStack(spacing: 12) {
                FormTextField(
                    label: "Nom",
                    text: $viewModel.lastName,
                    isValid: viewModel.isLastNameValid,
                    placeholder: "Votre nom"
                )
                .focused($focusedField, equals: .lastName)
                .textContentType(.familyName)
                .submitLabel(.next)

                FormTextField(
                    label: "Prénom",
                    text: $viewModel.firstName,
                    isValid: viewModel.isFirstNameValid,
                    placeholder: "Votre prénom"
                )
                .focused($focusedField, equals: .firstName)
                .textContentType(.givenName)
                .submitLabel(.next)
            }

            // Email
            FormTextField(
                label: "Email",
                text: $viewModel.email,
                isValid: viewModel.isEmailValid,
                placeholder: "votre@email.com",
                showValidation: !viewModel.email.isEmpty
            )
            .focused($focusedField, equals: .email)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .submitLabel(.next)

            // Phone
            FormTextField(
                label: "Téléphone",
                text: $viewModel.phone,
                isValid: viewModel.isPhoneValid,
                placeholder: "06 12 34 56 78",
                showValidation: !viewModel.phone.isEmpty
            )
            .focused($focusedField, equals: .phone)
            .textContentType(.telephoneNumber)
            .keyboardType(.phonePad)

            // Formation (pre-filled, disabled)
            formationField

            // Funding method picker
            pickerField(
                label: "Moyen de financement",
                selection: $viewModel.fundingMethod,
                options: FundingMethod.allCases
            )

            // Preferred format picker
            pickerField(
                label: "Format préféré",
                selection: $viewModel.preferredFormat,
                options: PreferredFormat.allCases
            )

            // Comments (optional)
            commentsField
        }
        .onSubmit {
            advanceField()
        }
    }

    // MARK: - Formation Field (Pre-filled, Disabled)

    private var formationField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Formation souhaitée")
                .font(.subheadline)
                .fontWeight(.medium)

            HStack {
                Text(formation.title)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.green.opacity(0.5), lineWidth: 1)
            )
        }
    }

    // MARK: - Picker Field

    private func pickerField<T: Identifiable & Hashable>(
        label: String,
        selection: Binding<T?>,
        options: [T]
    ) -> some View where T: RawRepresentable, T.RawValue == String {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)

            Menu {
                ForEach(options) { option in
                    Button {
                        selection.wrappedValue = option
                    } label: {
                        if let fundingOption = option as? FundingMethod {
                            Text(fundingOption.displayName)
                        } else if let formatOption = option as? PreferredFormat {
                            Text(formatOption.displayName)
                        } else {
                            Text(option.rawValue)
                        }
                    }
                }
            } label: {
                HStack {
                    if let selected = selection.wrappedValue {
                        if let fundingOption = selected as? FundingMethod {
                            Text(fundingOption.displayName)
                                .foregroundStyle(.primary)
                        } else if let formatOption = selected as? PreferredFormat {
                            Text(formatOption.displayName)
                                .foregroundStyle(.primary)
                        } else {
                            Text(selected.rawValue)
                                .foregroundStyle(.primary)
                        }
                    } else {
                        Text("Sélectionnez une option")
                            .foregroundStyle(Color.accentColor.opacity(0.9))
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            selection.wrappedValue == nil ? Color.clear : Color.green.opacity(0.5),
                            lineWidth: 1
                        )
                )
            }
        }
    }

    // MARK: - Comments Field

    private var commentsField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Commentaires (optionnel)")
                .font(.subheadline)
                .fontWeight(.medium)

            TextEditor(text: $viewModel.comments)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .focused($focusedField, equals: .comments)
        }
    }

    // MARK: - Submit Button

    private var submitButton: some View {
        Button {
            focusedField = nil
            Task {
                await viewModel.submit(formationId: formation.id)
            }
        } label: {
            Group {
                if viewModel.state == .submitting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Envoyer ma demande")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .buttonStyle(.borderedProminent)
        .disabled(!viewModel.isFormValid || viewModel.state == .submitting)
    }

    // MARK: - Consent Text

    private var consentText: some View {
        Text("En soumettant ce formulaire, vous acceptez d'être contacté par Madinia concernant votre demande de formation.")
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }

    // MARK: - Error Message

    private func errorMessage(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.red)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Success View

    private var successView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: viewModel.state == .success)

            VStack(spacing: 8) {
                Text("Demande envoyée !")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Merci pour votre intérêt.\nNous vous contacterons sous 48h.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Retour aux formations")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: - Helpers

    private func advanceField() {
        switch focusedField {
        case .lastName:
            focusedField = .firstName
        case .firstName:
            focusedField = .email
        case .email:
            focusedField = .phone
        case .phone:
            focusedField = .comments
        case .comments, .none:
            focusedField = nil
        }
    }

    private func triggerSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Form Text Field Component

private struct FormTextField: View {
    let label: String
    @Binding var text: String
    let isValid: Bool
    var placeholder: String = ""
    var showValidation: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)

            HStack {
                TextField(placeholder, text: $text)
                    .padding(12)

                if showValidation && !text.isEmpty {
                    Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(isValid ? .green : .red)
                        .padding(.trailing, 12)
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        text.isEmpty ? Color.clear :
                            (isValid ? Color.green.opacity(0.5) : Color.red.opacity(0.5)),
                        lineWidth: showValidation ? 1 : 0
                    )
            )
        }
    }
}

// MARK: - Previews

#Preview("Pre-registration Form") {
    NavigationStack {
        PreRegistrationView(formation: .sample)
    }
}

#Preview("With Category") {
    NavigationStack {
        PreRegistrationView(formation: Formation(
            id: 1,
            title: "Starter Pack - IA Generative",
            slug: "starter-pack",
            shortDescription: "Formation complete",
            duration: "14 heures",
            durationHours: 14,
            level: "debutant",
            levelLabel: "Debutant",
            certification: true,
            certificationLabel: "Certifiante",
            imageUrl: nil,
            category: FormationCategory(id: 1, name: "IA Generative", slug: "ia", color: "#8B5CF6", icon: nil),
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
}
