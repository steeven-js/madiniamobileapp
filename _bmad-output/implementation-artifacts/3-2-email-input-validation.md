# Story 3.2: Email Input & Validation

Status: done

## Story

As a **user**,
I want **to enter my email with real-time validation**,
So that **I know my email is correct before submitting** (FR11).

## Acceptance Criteria

1. **Given** the pre-registration sheet is open
   **When** I type in the email field
   **Then** the field validates email format in real-time

2. **Given** I'm typing an email
   **When** the email format is invalid
   **Then** I see an inline error message below the field

3. **Given** I'm typing an email
   **When** the email format is valid
   **Then** I see a green checkmark indicator

4. **Given** the email field is empty or invalid
   **When** I look at the "Confirmer" button
   **Then** the button is disabled (grayed out)

5. **Given** the email field has a valid email
   **When** I look at the "Confirmer" button
   **Then** the button is enabled and tappable

6. **Given** I'm using VoiceOver
   **When** the validation state changes
   **Then** the new state is announced

## Tasks / Subtasks

- [ ] **Task 1: Create EmailValidator Utility** (AC: #1)
  - [ ] Create `Utils/EmailValidator.swift`
  - [ ] Add static validation function using regex
  - [ ] Return validation result enum

- [ ] **Task 2: Update PreRegistrationSheet with Validation** (AC: #1, #2, #3, #4, #5)
  - [ ] Add email validation state
  - [ ] Show error message when invalid
  - [ ] Show checkmark when valid
  - [ ] Disable button when invalid

- [ ] **Task 3: Add Accessibility Announcements** (AC: #6)
  - [ ] Announce validation state changes
  - [ ] Update button accessibility hint

- [ ] **Task 4: Update project.pbxproj** (AC: all)
  - [ ] Add EmailValidator.swift to project
  - [ ] Verify compilation succeeds

## Dev Notes

### EmailValidator Utility

```swift
import Foundation

/// Email validation utility
enum EmailValidator {
    /// Validation result
    enum Result {
        case empty
        case invalid
        case valid
    }

    /// Validates an email address format
    static func validate(_ email: String) -> Result {
        guard !email.isEmpty else { return .empty }

        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(email.startIndex..., in: email)

        if regex?.firstMatch(in: email, range: range) != nil {
            return .valid
        }
        return .invalid
    }
}
```

### PreRegistrationSheet Updates

```swift
// Add computed validation state
private var emailValidation: EmailValidator.Result {
    EmailValidator.validate(email)
}

private var isEmailValid: Bool {
    emailValidation == .valid
}

// Update email field with validation indicator
private var emailField: some View {
    VStack(alignment: .leading, spacing: 8) {
        Text("Votre email")
            .font(.subheadline)
            .foregroundStyle(.secondary)

        HStack {
            TextField("exemple@email.com", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            // Validation indicator
            validationIndicator
        }

        // Error message
        if emailValidation == .invalid {
            Text("Format d'email invalide")
                .font(.caption)
                .foregroundStyle(.red)
        }
    }
}

private var validationIndicator: some View {
    Group {
        switch emailValidation {
        case .empty:
            EmptyView()
        case .invalid:
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red)
        case .valid:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
    }
    .accessibilityHidden(true)
}
```

### File Locations

| File | Location |
|------|----------|
| EmailValidator.swift | MadiniaApp/Utils/EmailValidator.swift |
| PreRegistrationSheet.swift | MadiniaApp/Views/Formations/PreRegistrationSheet.swift (update) |

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### Change Log

| Date | Change | By |
|------|--------|-----|
| 2026-01-23 | Story created with email validation spec | SM Agent (Claude Opus 4.5) |

### File List

