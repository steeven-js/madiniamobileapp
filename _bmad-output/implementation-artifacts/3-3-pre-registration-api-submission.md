# Story 3.3: Pre-registration API Submission

Status: done

## Story

As a **system**,
I want **to send pre-registration data to the Laravel API**,
So that **Madinia receives the lead** (FR13, FR38).

## Acceptance Criteria

1. **Given** a valid email is entered
   **When** user taps "Confirmer"
   **Then** the system sends POST to `/api/v1/pre-registrations`

2. **Given** the form is being submitted
   **When** I look at the button
   **Then** I see a loading indicator

3. **Given** the API returns success
   **When** submission completes
   **Then** the success state is triggered (Story 3.4)

4. **Given** the API returns an error
   **When** submission fails
   **Then** I see an error message with retry option

5. **Given** network is unavailable
   **When** submission fails
   **Then** I see an appropriate error message

## Tasks / Subtasks

- [ ] **Task 1: Add Pre-registration API Endpoint** (AC: #1)
  - [ ] Add `submitPreRegistration(formationId:email:)` to APIServiceProtocol
  - [ ] Implement in APIService with POST request
  - [ ] Create PreRegistrationRequest model

- [ ] **Task 2: Create PreRegistrationViewModel** (AC: #1, #2, #3, #4, #5)
  - [ ] Create ViewModel with @Observable
  - [ ] Handle loading, success, error states
  - [ ] Expose submission method

- [ ] **Task 3: Update PreRegistrationSheet** (AC: #2, #3, #4, #5)
  - [ ] Use ViewModel for submission
  - [ ] Show loading state on button
  - [ ] Handle error with alert
  - [ ] Trigger success state on completion

- [ ] **Task 4: Verify compilation** (AC: all)
  - [ ] Verify compilation succeeds

## Dev Notes

### API Endpoint

```
POST /api/v1/pre-registrations
Content-Type: application/json

{
    "email": "user@example.com",
    "formation_id": 1
}

Response 201:
{
    "success": true,
    "message": "Pré-inscription enregistrée"
}
```

### PreRegistrationRequest Model

```swift
struct PreRegistrationRequest: Encodable {
    let email: String
    let formationId: Int

    enum CodingKeys: String, CodingKey {
        case email
        case formationId = "formation_id"
    }
}

struct PreRegistrationResponse: Decodable {
    let success: Bool
    let message: String?
}
```

### APIService Extension

```swift
protocol APIServiceProtocol {
    // ... existing methods
    func submitPreRegistration(formationId: Int, email: String) async throws
}

extension APIService {
    func submitPreRegistration(formationId: Int, email: String) async throws {
        let request = PreRegistrationRequest(email: email, formationId: formationId)
        let _: PreRegistrationResponse = try await postRequest(
            endpoint: "/pre-registrations",
            body: request
        )
    }
}
```

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### Change Log

| Date | Change | By |
|------|--------|-----|
| 2026-01-23 | Story created with API submission spec | SM Agent (Claude Opus 4.5) |

### File List

