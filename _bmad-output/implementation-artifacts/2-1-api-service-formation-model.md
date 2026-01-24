# Story 2.1: API Service & Formation Model

Status: done

## Story

As a **developer**,
I want **an API service that fetches formations from the Laravel backend**,
So that **the app can display real formation data**.

## Acceptance Criteria

1. **Given** the APIService is implemented
   **When** `fetchFormations()` is called
   **Then** it returns a list of Formation objects

2. **Given** a Formation object is returned
   **When** I examine its properties
   **Then** Formation model includes: id, title, description, duration, level, price, nextSession, category

3. **Given** an API call fails
   **When** the error is caught
   **Then** errors are handled with APIError enum

4. **Given** any API method is implemented
   **When** I examine the code
   **Then** the service uses async/await pattern exclusively

5. **Given** the API returns JSON
   **When** the response is parsed
   **Then** snake_case keys are mapped to camelCase properties via CodingKeys

## Tasks / Subtasks

- [x] **Task 1: Create Formation Model** (AC: #2, #5)
  - [x] Create `Models/Formation.swift`
  - [x] Define Formation struct with Codable conformance
  - [x] Add properties: id (Int), title, description, duration, level, price, nextSession, category
  - [x] Implement CodingKeys for snake_case → camelCase mapping
  - [x] Add Identifiable conformance for SwiftUI lists
  - [x] Add Hashable conformance for comparison

- [x] **Task 2: Create APIError Enum** (AC: #3)
  - [x] Create `Services/APIError.swift`
  - [x] Define APIError enum with cases: networkError, decodingError, serverError(Int), invalidURL, noData, timeout, unauthorized, notFound
  - [x] Implement LocalizedError for user-friendly messages in French
  - [x] Add error descriptions for debugging
  - [x] Add factory methods for URLError and HTTP status code mapping

- [x] **Task 3: Create APIService** (AC: #1, #4)
  - [x] Create `Services/APIService.swift`
  - [x] Define APIService class with protocol for testability (APIServiceProtocol)
  - [x] Configure base URL: `https://api.madinia.fr/api/v1`
  - [x] Implement `fetchFormations() async throws -> [Formation]`
  - [x] Use URLSession with async/await
  - [x] Handle HTTP status codes appropriately
  - [x] Create MockAPIService for previews and testing

- [x] **Task 4: Configure API Headers** (AC: #4)
  - [x] Add Content-Type: application/json header
  - [x] Add Accept: application/json header
  - [x] Configure 30s timeout

- [x] **Task 5: Create LoadingState Enum** (AC: #3)
  - [x] Create `Models/LoadingState.swift`
  - [x] Define LoadingState<T> enum: idle, loading, loaded(T), error(String)
  - [x] Enable views to handle all states uniformly
  - [x] Add Equatable conformance for testing

- [x] **Task 6: Write Unit Tests** (AC: #1, #2, #3)
  - [x] Create `MadiniaAppTests/FormationTests.swift`
  - [x] Test Formation decoding from JSON
  - [x] Test CodingKeys mapping
  - [x] Test null nextSession handling
  - [x] Test protocol conformance (Identifiable, Hashable, Equatable)
  - [x] Create `MadiniaAppTests/APIServiceTests.swift`
  - [x] Test APIError messages in French
  - [x] Test APIError factory methods
  - [x] Test LoadingState properties
  - [x] Test MockAPIService with sample data and failure simulation

## Dev Notes

### Architecture Compliance

**CRITICAL - Follow these patterns exactly:**

| Pattern | Requirement | Source |
|---------|-------------|--------|
| Networking | URLSession async/await | [architecture.md#Architectural Decisions] |
| Error Handling | APIError enum | [architecture.md#Code Patterns] |
| Data Models | Codable structs | [architecture.md#Data Architecture] |
| Protocol | REST JSON | [architecture.md#API & Communication] |
| Naming | PascalCase types, camelCase properties | [architecture.md#Naming Conventions] |

### Formation Model Structure

```swift
import Foundation

struct Formation: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let description: String
    let duration: String        // e.g., "2 jours", "40 heures"
    let level: String           // e.g., "Débutant", "Intermédiaire", "Expert"
    let price: Double           // Price in EUR
    let nextSession: Date?      // Optional - may not have scheduled session
    let category: String        // e.g., "IA Générative", "Machine Learning"

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case duration
        case level
        case price
        case nextSession = "next_session"
        case category
    }
}
```

### APIError Enum Structure

```swift
import Foundation

enum APIError: LocalizedError {
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    case invalidURL
    case noData

    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Erreur de connexion. Vérifiez votre connexion internet."
        case .decodingError:
            return "Erreur lors du traitement des données."
        case .serverError(let code):
            return "Erreur serveur (code: \(code)). Réessayez plus tard."
        case .invalidURL:
            return "URL invalide."
        case .noData:
            return "Aucune donnée reçue du serveur."
        }
    }
}
```

### APIService Structure

```swift
import Foundation

protocol APIServiceProtocol {
    func fetchFormations() async throws -> [Formation]
}

class APIService: APIServiceProtocol {
    static let shared = APIService()

    private let baseURL = "https://api.madinia.fr/api/v1"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchFormations() async throws -> [Formation] {
        guard let url = URL(string: "\(baseURL)/formations") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.noData
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            return try decoder.decode([Formation].self, from: data)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
}
```

### LoadingState Enum Structure

```swift
import Foundation

enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case error(String)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var value: T? {
        if case .loaded(let value) = self { return value }
        return nil
    }

    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
}
```

### API Endpoint Reference

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/formations` | GET | List all formations |
| `/formations/{id}` | GET | Get formation details |

### Expected JSON Response Format

```json
[
  {
    "id": 1,
    "title": "Starter Pack - IA Générative",
    "description": "Découvrez les fondamentaux de l'IA générative...",
    "duration": "2 jours",
    "level": "Débutant",
    "price": 990.00,
    "next_session": "2026-02-15T09:00:00Z",
    "category": "IA Générative"
  }
]
```

### File Locations

| File | Location |
|------|----------|
| Formation.swift | MadiniaApp/Models/Formation.swift |
| APIError.swift | MadiniaApp/Services/APIError.swift |
| APIService.swift | MadiniaApp/Services/APIService.swift |
| LoadingState.swift | MadiniaApp/Models/LoadingState.swift |

### Technical Requirements

| Requirement | Value |
|-------------|-------|
| Base URL | https://api.madinia.fr/api/v1 |
| Protocol | HTTPS (TLS 1.3) |
| Timeout | 30 seconds (default) |
| Retry | 3 attempts with exponential backoff (later) |
| Date Format | ISO 8601 |

### Previous Story Learnings

From Epic 1 implementation:
- Project structure ready with Models/, Services/ folders
- SwiftData configured (not needed for API yet)
- All feature Views folders in place

### References

- [Source: architecture.md#API & Communication]
- [Source: architecture.md#Data Architecture]
- [Source: architecture.md#Code Patterns]
- [Source: epics.md#Story 2.1]
- [Source: prd.md#FR36 API formations]

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- All files created successfully
- project.pbxproj updated with 4 new source files
- Removed .gitkeep files from Models/ and Services/ directories

### Completion Notes List

- Formation model includes sample data for previews (Formation.sample, Formation.samples)
- APIError enum extended with additional cases: timeout, unauthorized, notFound
- APIError includes factory methods for URLError and HTTP status code mapping
- MockAPIService created for SwiftUI previews and testing (simulatedDelay, shouldFail flags)
- LoadingState includes convenience properties: isLoading, value, errorMessage, isIdle, isCompleted
- All error messages are in French for user-facing display
- Unit tests cover JSON decoding, protocol conformance, error handling

### Change Log

| Date | Change | By |
|------|--------|-----|
| 2026-01-23 | Story created with comprehensive API context | SM Agent (Claude Opus 4.5) |
| 2026-01-23 | Implemented all tasks, ready for review | Dev Agent (Claude Opus 4.5) |
| 2026-01-23 | Code review: Fixed 7 issues (1 Critical, 1 High, 3 Medium, 2 Low) | Code Review (Claude Opus 4.5) |

### Code Review Fixes Applied

| Issue | Severity | Fix |
|-------|----------|-----|
| Test target missing | CRITICAL | Created MadiniaAppTests target in project.pbxproj with all test files |
| Missing retry logic | HIGH | Added exponential backoff retry (3 attempts, 1s→2s→4s) to APIService |
| APIError status codes | MEDIUM | Added badRequest (400), forbidden (403) cases, improved 4xx handling |
| Test files not in project | MEDIUM | Linked FormationTests, APIServiceTests, MainTabViewTests to test target |
| Documentation missing | MEDIUM | Added comprehensive doc comments to request<T> method |
| Task.sleep legacy API | LOW | Updated to Task.sleep(for: .seconds()) |
| Dynamic sample dates | LOW | Fixed Formation.samples to use fixed preview date (2026-02-15) |

### File List

Files created/modified during implementation:

- [x] MadiniaApp/Models/Formation.swift
- [x] MadiniaApp/Models/LoadingState.swift
- [x] MadiniaApp/Services/APIError.swift
- [x] MadiniaApp/Services/APIService.swift
- [x] MadiniaApp/MadiniaAppTests/FormationTests.swift
- [x] MadiniaApp/MadiniaAppTests/APIServiceTests.swift
- [x] MadiniaApp/MadiniaApp.xcodeproj/project.pbxproj
- [x] MadiniaApp/Models/.gitkeep (deleted)
- [x] MadiniaApp/Services/.gitkeep (deleted)
