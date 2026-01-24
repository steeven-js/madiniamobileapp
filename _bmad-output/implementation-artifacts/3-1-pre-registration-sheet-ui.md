# Story 3.1: Pre-registration Sheet UI

Status: done

## Story

As a **user**,
I want **a simple pre-registration form that appears as a sheet**,
So that **I can quickly express my interest** (FR10).

## Acceptance Criteria

1. **Given** I'm on a formation detail view
   **When** I tap the "Pré-inscription" button (tap 1)
   **Then** a sheet slides up with a simple form

2. **Given** the pre-registration sheet is open
   **When** I look at the form
   **Then** I see the formation name displayed for context

3. **Given** the pre-registration sheet is open
   **When** I look at the form
   **Then** I see an email input field with proper keyboard

4. **Given** the pre-registration sheet is open
   **When** I look at the form
   **Then** I see a "Confirmer" button (tap 2)

5. **Given** the pre-registration sheet is open
   **When** I swipe down on the sheet
   **Then** the sheet dismisses and I return to the formation detail

6. **Given** I'm using VoiceOver
   **When** I navigate the pre-registration sheet
   **Then** all elements are properly labeled

## Tasks / Subtasks

- [ ] **Task 1: Create PreRegistrationSheet View** (AC: #1, #2, #3, #4)
  - [ ] Create `Views/Formations/PreRegistrationSheet.swift`
  - [ ] Add formation parameter for context display
  - [ ] Add email TextField with .emailAddress keyboard
  - [ ] Add "Confirmer" button
  - [ ] Style according to design specs

- [ ] **Task 2: Connect Sheet to FormationDetailView** (AC: #1, #5)
  - [ ] Update FormationDetailView to present sheet
  - [ ] Replace placeholder alert with actual sheet
  - [ ] Add @State for sheet presentation
  - [ ] Ensure sheet dismisses on swipe

- [ ] **Task 3: Add Accessibility Support** (AC: #6)
  - [ ] Add accessibility labels to all elements
  - [ ] Ensure proper focus management
  - [ ] Add accessibility hints where helpful

- [ ] **Task 4: Update project.pbxproj** (AC: all)
  - [ ] Add PreRegistrationSheet.swift to project
  - [ ] Verify compilation succeeds

## Dev Notes

### Architecture Compliance

**CRITICAL - Follow these patterns exactly:**

| Pattern | Requirement | Source |
|---------|-------------|--------|
| Sheet | SwiftUI .sheet modifier | [iOS patterns] |
| Form | TextField with proper keyboard | [UX spec] |
| Styling | Design tokens for spacing/colors | [architecture.md] |

### PreRegistrationSheet Structure

```swift
import SwiftUI

/// Sheet view for formation pre-registration.
/// Displays a simple form to collect user email for pre-registration.
struct PreRegistrationSheet: View {
    /// The formation to pre-register for
    let formation: Formation

    /// Dismiss action from environment
    @Environment(\.dismiss) private var dismiss

    /// User's email input
    @State private var email = ""

    /// Whether form is being submitted
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Pré-inscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Subviews

    private var formationContext: some View {
        VStack(spacing: 8) {
            Text("Vous souhaitez vous inscrire à :")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(formation.title)
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Votre email")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("exemple@email.com", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .accessibilityLabel("Adresse email")
                .accessibilityHint("Entrez votre adresse email pour la pré-inscription")
        }
    }

    private var submitButton: some View {
        Button {
            // Submit action - full implementation in Story 3.3
            isSubmitting = true
        } label: {
            if isSubmitting {
                ProgressView()
                    .tint(.white)
            } else {
                Text("Confirmer")
            }
        }
        .font(.headline)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.accentColor)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .disabled(email.isEmpty || isSubmitting)
        .opacity(email.isEmpty ? 0.6 : 1.0)
        .accessibilityLabel("Confirmer la pré-inscription")
        .accessibilityHint("Envoie votre demande de pré-inscription")
    }
}
```

### FormationDetailView Updates

```swift
// Replace showPreRegistration alert with sheet
@State private var showPreRegistration = false

// In body, replace .alert with:
.sheet(isPresented: $showPreRegistration) {
    PreRegistrationSheet(formation: formation)
}
```

### Design Specifications

| Element | Specification |
|---------|---------------|
| Sheet Height | .medium detent (~50% screen) |
| Drag Indicator | Visible |
| Title | "Pré-inscription" inline |
| Context Card | secondarySystemBackground, 12pt radius |
| Email Field | .roundedBorder style |
| Button | Full width, accent color, 12pt radius |
| Spacing | 24pt between sections |

### File Locations

| File | Location |
|------|----------|
| PreRegistrationSheet.swift | MadiniaApp/Views/Formations/PreRegistrationSheet.swift |
| FormationDetailView.swift | MadiniaApp/Views/Formations/FormationDetailView.swift (update) |

### NFR Compliance

| NFR | Implementation |
|-----|----------------|
| NFR10: VoiceOver | All form elements labeled |
| NFR11: Dynamic Type | Semantic fonts used |
| NFR13: Touch targets | Button full width, 44pt+ height |

### References

- [Source: architecture.md#Frontend Architecture]
- [Source: epics.md#Story 3.1]
- [Source: prd.md#FR10 pré-inscription 2 taps]
- [Source: ux-design-specification.md#PreRegistrationSheet]

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### Change Log

| Date | Change | By |
|------|--------|-----|
| 2026-01-23 | Story created with pre-registration sheet spec | SM Agent (Claude Opus 4.5) |

### File List

