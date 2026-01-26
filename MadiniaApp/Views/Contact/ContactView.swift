//
//  ContactView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Contact form view allowing users to send messages to Madinia.
struct ContactView: View {
    @Environment(\.navigationContext) private var navigationContext
    @State private var viewModel = ContactViewModel()
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case firstName, lastName, email, phone, subject, message
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Contact")
        }
        .onAppear {
            viewModel.setupWithContext(navigationContext)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .success:
            successView
        default:
            formView
        }
    }

    // MARK: - Form View

    private var formView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Context banner
                if viewModel.showContext, let context = viewModel.contextItem {
                    contextBanner(context)
                }

                // Form fields
                formFields

                // Submit button
                submitButton

                // Error message
                if case .error(let message) = viewModel.state {
                    errorMessage(message)
                }
            }
            .padding()
            .padding(.bottom, 100) // Space for tab bar
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Context Banner

    private func contextBanner(_ context: NavigationContextItem) -> some View {
        HStack {
            Image(systemName: context.type == .formation ? "book.fill" : "newspaper.fill")
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 2) {
                Text("À propos de:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(context.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                withAnimation {
                    viewModel.dismissContext()
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Retirer le contexte")
        }
        .padding()
        .background(Color.accentColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Form Fields

    private var formFields: some View {
        VStack(spacing: 16) {
            // Name row
            HStack(spacing: 12) {
                FormTextField(
                    label: "Prénom",
                    text: $viewModel.firstName,
                    isValid: viewModel.isFirstNameValid,
                    placeholder: "Votre prénom"
                )
                .focused($focusedField, equals: .firstName)
                .textContentType(.givenName)
                .submitLabel(.next)

                FormTextField(
                    label: "Nom",
                    text: $viewModel.lastName,
                    isValid: viewModel.isLastNameValid,
                    placeholder: "Votre nom"
                )
                .focused($focusedField, equals: .lastName)
                .textContentType(.familyName)
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

            // Phone (optional)
            FormTextField(
                label: "Téléphone (optionnel)",
                text: $viewModel.phone,
                isValid: true,
                placeholder: "06 12 34 56 78"
            )
            .focused($focusedField, equals: .phone)
            .textContentType(.telephoneNumber)
            .keyboardType(.phonePad)

            // Subject
            FormTextField(
                label: "Sujet",
                text: $viewModel.subject,
                isValid: viewModel.isSubjectValid,
                placeholder: "Sujet de votre message"
            )
            .focused($focusedField, equals: .subject)
            .submitLabel(.next)

            // Message
            VStack(alignment: .leading, spacing: 6) {
                Text("Message")
                    .font(.subheadline)
                    .fontWeight(.medium)

                TextEditor(text: $viewModel.message)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                viewModel.message.isEmpty ? Color.clear :
                                    (viewModel.isMessageValid ? Color.green.opacity(0.5) : Color.red.opacity(0.5)),
                                lineWidth: 1
                            )
                    )
                    .focused($focusedField, equals: .message)

                if !viewModel.message.isEmpty && !viewModel.isMessageValid {
                    Text("Minimum 10 caractères")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .onSubmit {
            advanceField()
        }
    }

    // MARK: - Submit Button

    private var submitButton: some View {
        Button {
            focusedField = nil
            Task {
                await viewModel.submit()
                if viewModel.state == .success {
                    navigationContext.clear()
                    triggerSuccessHaptic()
                }
            }
        } label: {
            Group {
                if viewModel.state == .submitting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Envoyer")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .buttonStyle(.borderedProminent)
        .disabled(!viewModel.isFormValid || viewModel.state == .submitting)
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

            Text("Message envoyé !")
                .font(.title)
                .fontWeight(.bold)

            Text("Nous vous répondrons sous 24-48h")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                withAnimation {
                    viewModel.reset()
                }
            } label: {
                Text("Nouveau message")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .padding(.bottom, 100) // Space for tab bar
    }

    // MARK: - Helpers

    private func advanceField() {
        switch focusedField {
        case .firstName:
            focusedField = .lastName
        case .lastName:
            focusedField = .email
        case .email:
            focusedField = .phone
        case .phone:
            focusedField = .subject
        case .subject:
            focusedField = .message
        case .message, .none:
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

#Preview("Contact Form") {
    ContactView()
}

#Preview("With Context") {
    let context = NavigationContext.shared
    context.setFormation(Formation.sample)
    return ContactView()
        .environment(\.navigationContext, context)
}
