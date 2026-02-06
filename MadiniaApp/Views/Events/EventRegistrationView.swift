//
//  EventRegistrationView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-06.
//

import SwiftUI

/// Sheet view for event registration.
/// Collects user information and reminder preferences.
struct EventRegistrationView: View {
    /// The event to register for
    let event: Event

    /// Callback when registration is successful
    let onSuccess: (EventRegistration) -> Void

    /// Environment dismiss for sheet
    @Environment(\.dismiss) private var dismiss

    /// ViewModel for handling form state and submission
    @State private var viewModel = EventRegistrationFormViewModel()

    /// Focus state for form fields
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case firstName, lastName, email, phone, company
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .success(let registration):
                    successView(registration: registration)
                default:
                    formView
                }
            }
            .navigationTitle("Inscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
        .interactiveDismissDisabled(viewModel.state == .submitting)
    }

    // MARK: - Form View

    private var formView: some View {
        ScrollView {
            VStack(spacing: MadiniaSpacing.lg) {
                // Event summary
                eventSummary

                // Form fields
                formFields

                // Reminder options
                reminderOptions

                // Submit button
                submitButton

                // Error message
                if case .error(let message) = viewModel.state {
                    errorMessage(message)
                }

                // Privacy note
                privacyNote
            }
            .padding(MadiniaSpacing.md)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Event Summary

    private var eventSummary: some View {
        VStack(spacing: MadiniaSpacing.sm) {
            // Event type badge
            HStack(spacing: 6) {
                Image(systemName: event.eventType.icon)
                    .font(.caption)
                Text(event.eventType.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, MadiniaSpacing.sm)
            .padding(.vertical, MadiniaSpacing.xxs)
            .background(event.eventType.color)
            .foregroundStyle(.white)
            .clipShape(Capsule())

            // Event title
            Text(event.title)
                .font(.headline)
                .multilineTextAlignment(.center)

            // Date & Time
            HStack(spacing: MadiniaSpacing.xs) {
                Image(systemName: "calendar")
                    .foregroundStyle(event.eventType.color)
                Text(event.formattedDate)
                Text("•")
                    .foregroundStyle(.tertiary)
                Text(event.formattedTime)
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity)
        .padding(MadiniaSpacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
    }

    // MARK: - Form Fields

    private var formFields: some View {
        VStack(spacing: MadiniaSpacing.md) {
            // Section header
            HStack {
                Image(systemName: "person.fill")
                    .foregroundStyle(MadiniaColors.accent)
                Text("Vos informations")
                    .font(.headline)
                Spacer()
            }

            // First name
            FormTextField(
                label: "Prénom",
                text: $viewModel.firstName,
                isValid: viewModel.isFirstNameValid,
                placeholder: "Votre prénom"
            )
            .textContentType(.givenName)
            .focused($focusedField, equals: .firstName)
            .submitLabel(.next)
            .onSubmit { focusedField = .lastName }

            // Last name
            FormTextField(
                label: "Nom",
                text: $viewModel.lastName,
                isValid: viewModel.isLastNameValid,
                placeholder: "Votre nom"
            )
            .textContentType(.familyName)
            .focused($focusedField, equals: .lastName)
            .submitLabel(.next)
            .onSubmit { focusedField = .email }

            // Email
            FormTextField(
                label: "Email",
                text: $viewModel.email,
                isValid: viewModel.isEmailValid,
                placeholder: "votre@email.com"
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit { focusedField = .phone }

            // Phone (optional)
            FormTextField(
                label: "Téléphone (optionnel)",
                text: $viewModel.phone,
                isValid: true,
                placeholder: "0696 12 34 56"
            )
            .textContentType(.telephoneNumber)
            .keyboardType(.phonePad)
            .focused($focusedField, equals: .phone)

            // Company (optional)
            FormTextField(
                label: "Entreprise (optionnel)",
                text: $viewModel.company,
                isValid: true,
                placeholder: "Votre entreprise"
            )
            .textContentType(.organizationName)
            .focused($focusedField, equals: .company)
            .submitLabel(.done)
            .onSubmit { focusedField = nil }
        }
    }

    // MARK: - Reminder Options

    private var reminderOptions: some View {
        VStack(spacing: MadiniaSpacing.md) {
            // Section header
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundStyle(MadiniaColors.accent)
                Text("Rappels")
                    .font(.headline)
                Spacer()
            }

            // Push notification reminder
            Toggle(isOn: $viewModel.enablePushReminder) {
                HStack(spacing: MadiniaSpacing.sm) {
                    Image(systemName: "bell.badge.fill")
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Notification push")
                            .font(.subheadline)
                        Text("Recevez un rappel 1h avant l'événement")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .tint(MadiniaColors.accent)

            // Calendar reminder
            Toggle(isOn: $viewModel.enableCalendarReminder) {
                HStack(spacing: MadiniaSpacing.sm) {
                    Image(systemName: "calendar.badge.plus")
                        .foregroundStyle(.green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Ajouter au calendrier")
                            .font(.subheadline)
                        Text("L'événement sera ajouté à votre calendrier iOS")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .tint(MadiniaColors.accent)
        }
        .padding(MadiniaSpacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
    }

    // MARK: - Submit Button

    private var submitButton: some View {
        Button {
            focusedField = nil
            Task {
                await viewModel.submit(event: event)
            }
        } label: {
            HStack(spacing: 8) {
                if viewModel.state == .submitting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Confirmer l'inscription")
                }
            }
            .font(.headline)
            .foregroundStyle(MadiniaColors.darkGrayFixed)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.isFormValid ? MadiniaColors.accent : Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
        }
        .disabled(!viewModel.isFormValid || viewModel.state == .submitting)
    }

    // MARK: - Error Message

    private func errorMessage(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(MadiniaSpacing.sm)
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.sm))
    }

    // MARK: - Privacy Note

    private var privacyNote: some View {
        Text("En vous inscrivant, vous acceptez de recevoir des communications relatives à cet événement. Vos données sont traitées conformément à notre politique de confidentialité.")
            .font(.caption)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
    }

    // MARK: - Success View

    private func successView(registration: EventRegistration) -> some View {
        VStack(spacing: MadiniaSpacing.xl) {
            Spacer()

            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            // Success message
            VStack(spacing: MadiniaSpacing.sm) {
                Text("Inscription confirmée !")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Vous êtes inscrit à \(event.title)")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Reminder status
            VStack(spacing: MadiniaSpacing.sm) {
                if viewModel.enablePushReminder {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(.blue)
                        Text("Rappel push activé")
                            .font(.subheadline)
                    }
                }

                if viewModel.enableCalendarReminder {
                    HStack {
                        Image(systemName: "calendar.badge.checkmark")
                            .foregroundStyle(.green)
                        Text("Ajouté à votre calendrier")
                            .font(.subheadline)
                    }
                }
            }
            .padding(MadiniaSpacing.md)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))

            Spacer()

            // Done button
            Button {
                onSuccess(registration)
                dismiss()
            } label: {
                Text("Terminé")
                    .font(.headline)
                    .foregroundStyle(MadiniaColors.darkGrayFixed)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(MadiniaColors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
            }
        }
        .padding(MadiniaSpacing.md)
    }
}

// MARK: - Form ViewModel

@Observable
final class EventRegistrationFormViewModel {
    // Form fields
    var firstName = ""
    var lastName = ""
    var email = ""
    var phone = ""
    var company = ""
    var enablePushReminder = true
    var enableCalendarReminder = false

    // State
    enum State: Equatable {
        case idle
        case submitting
        case success(EventRegistration)
        case error(String)

        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.submitting, .submitting):
                return true
            case (.success(let l), .success(let r)):
                return l.id == r.id
            case (.error(let l), .error(let r)):
                return l == r
            default:
                return false
            }
        }
    }

    var state: State = .idle

    // Validation
    var isFirstNameValid: Bool { !firstName.trimmingCharacters(in: .whitespaces).isEmpty }
    var isLastNameValid: Bool { !lastName.trimmingCharacters(in: .whitespaces).isEmpty }
    var isEmailValid: Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }

    var isFormValid: Bool {
        isFirstNameValid && isLastNameValid && isEmailValid
    }

    // Submit
    @MainActor
    func submit(event: Event) async {
        guard isFormValid else { return }

        state = .submitting

        do {
            let registration = try await EventsService.shared.registerForEvent(
                event,
                firstName: firstName.trimmingCharacters(in: .whitespaces),
                lastName: lastName.trimmingCharacters(in: .whitespaces),
                email: email.trimmingCharacters(in: .whitespaces),
                phone: phone.isEmpty ? nil : phone.trimmingCharacters(in: .whitespaces),
                company: company.isEmpty ? nil : company.trimmingCharacters(in: .whitespaces),
                enablePushReminder: enablePushReminder,
                enableCalendarReminder: enableCalendarReminder
            )
            state = .success(registration)

            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

// MARK: - Form TextField Component

private struct FormTextField: View {
    let label: String
    @Binding var text: String
    let isValid: Bool
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if !isValid && !text.isEmpty {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            TextField(placeholder, text: $text)
                .padding(12)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            !isValid && !text.isEmpty ? Color.orange : Color.clear,
                            lineWidth: 1
                        )
                }
        }
    }
}

// MARK: - Previews

#Preview {
    EventRegistrationView(event: Event.sample) { _ in }
}
