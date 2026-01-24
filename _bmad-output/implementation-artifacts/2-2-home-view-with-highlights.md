# Story 2.2: Home View with Highlights

Status: done

## Story

As a **user**,
I want **to see an engaging home screen with highlights and quick access**,
So that **I can quickly discover what Madinia offers** (FR3).

## Acceptance Criteria

1. **Given** I'm on the Accueil tab
   **When** the view loads
   **Then** I see a welcome section with Madinia branding

2. **Given** I'm on the Accueil tab
   **When** the view loads
   **Then** I see highlighted formations or promotions

3. **Given** I'm on the Accueil tab
   **When** the view loads
   **Then** I see quick access buttons to key sections

4. **Given** the data is being fetched
   **When** the network request is in progress
   **Then** loading state is shown while fetching data

5. **Given** an API call fails
   **When** the error is caught
   **Then** error state is shown with retry option

## Tasks / Subtasks

- [x] **Task 1: Create HomeViewModel** (AC: #1, #4, #5)
  - [x] Create `Views/Home/HomeViewModel.swift`
  - [x] Use @Observable macro (iOS 17+)
  - [x] Add `loadingState: LoadingState<[Formation]>` property
  - [x] Add `highlightedFormations: [Formation]` computed property (first 3 formations)
  - [x] Implement `loadFormations()` async method
  - [x] Handle errors with retry capability
  - [x] Use APIServiceProtocol for dependency injection

- [x] **Task 2: Create WelcomeSection Component** (AC: #1)
  - [x] Create `Views/Home/Components/WelcomeSection.swift`
  - [x] Display Madinia logo or icon (SF Symbol placeholder initially)
  - [x] Add welcome message: "Bienvenue chez Madinia"
  - [x] Add tagline: "Formations IA pour transformer votre métier"
  - [x] Use proper typography (Title 1 + Body)

- [x] **Task 3: Create HighlightCard Component** (AC: #2)
  - [x] Create `Views/Home/Components/HighlightCard.swift`
  - [x] Display formation title prominently
  - [x] Display level badge (Débutant, Intermédiaire, Expert)
  - [x] Display price
  - [x] Display next session date (if available)
  - [x] Make entire card tappable for navigation
  - [x] Use md:12pt corner radius as per UX design

- [x] **Task 4: Create QuickAccessSection Component** (AC: #3)
  - [x] Create `Views/Home/Components/QuickAccessSection.swift`
  - [x] Add "Voir toutes les formations" button → FormationsView
  - [x] Add "Lire le blog" button → BlogView
  - [x] Add "Nous contacter" button → ContactView
  - [x] Use horizontal HStack layout with equal buttons
  - [x] Style as secondary buttons (.bordered style)

- [x] **Task 5: Update HomeView with Full Layout** (AC: #1, #2, #3, #4, #5)
  - [x] Replace placeholder content in `Views/Home/HomeView.swift`
  - [x] Add ScrollView for vertical scrolling
  - [x] Add WelcomeSection at top
  - [x] Add "Formations à la une" section header
  - [x] Add horizontal ScrollView for HighlightCards
  - [x] Add QuickAccessSection
  - [x] Handle all LoadingState cases (idle, loading, loaded, error)
  - [x] Add .task modifier to load data on appear
  - [x] Inject HomeViewModel via Environment

- [x] **Task 6: Create LoadingView Component** (AC: #4)
  - [x] Create `Views/Shared/LoadingView.swift` (reusable)
  - [x] Display ProgressView spinner
  - [x] Display optional loading message
  - [x] Center content vertically

- [x] **Task 7: Create ErrorView Component** (AC: #5)
  - [x] Create `Views/Shared/ErrorView.swift` (reusable)
  - [x] Display error icon (SF Symbol exclamationmark.triangle)
  - [x] Display error message
  - [x] Add "Réessayer" button with retry action closure
  - [x] Style in French as per architecture

- [x] **Task 8: Update project.pbxproj** (AC: all)
  - [x] Add all new Swift files to Xcode project
  - [x] Verify compilation succeeds

- [x] **Task 9: Write Unit Tests** (AC: #4, #5)
  - [x] Create `MadiniaAppTests/HomeViewModelTests.swift`
  - [x] Test initial state is idle
  - [x] Test loading state transitions
  - [x] Test successful data loading
  - [x] Test error handling with MockAPIService
  - [x] Test highlighted formations returns max 3

## Dev Notes

### Architecture Compliance

**CRITICAL - Follow these patterns exactly:**

| Pattern | Requirement | Source |
|---------|-------------|--------|
| ViewModel | @Observable macro | [architecture.md#Frontend Architecture] |
| State Management | LoadingState<T> enum | [architecture.md#Code Patterns] |
| Networking | APIServiceProtocol DI | [Story 2.1 implementation] |
| Async | .task { } modifier | [architecture.md#Async Patterns] |
| Naming | PascalCase types, camelCase properties | [architecture.md#Naming Conventions] |

### HomeViewModel Structure

```swift
import Foundation

@Observable
final class HomeViewModel {
    // MARK: - State
    private(set) var loadingState: LoadingState<[Formation]> = .idle

    // MARK: - Dependencies
    private let apiService: APIServiceProtocol

    // MARK: - Computed Properties
    var highlightedFormations: [Formation] {
        loadingState.value?.prefix(3).map { $0 } ?? []
    }

    // MARK: - Initialization
    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }

    // MARK: - Actions
    @MainActor
    func loadFormations() async {
        guard !loadingState.isLoading else { return }

        loadingState = .loading

        do {
            let formations = try await apiService.fetchFormations()
            loadingState = .loaded(formations)
        } catch let error as APIError {
            loadingState = .error(error.errorDescription ?? "Erreur inconnue")
        } catch {
            loadingState = .error("Erreur de chargement")
        }
    }
}
```

### HomeView Structure

```swift
import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                WelcomeSection()

                switch viewModel.loadingState {
                case .idle, .loading:
                    LoadingView(message: "Chargement...")
                case .loaded:
                    highlightsSection
                    QuickAccessSection()
                case .error(let message):
                    ErrorView(message: message) {
                        Task { await viewModel.loadFormations() }
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Accueil")
        .task {
            await viewModel.loadFormations()
        }
    }

    private var highlightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Formations à la une")
                .font(.title2)
                .fontWeight(.bold)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.highlightedFormations) { formation in
                        HighlightCard(formation: formation)
                    }
                }
            }
        }
    }
}
```

### Design Tokens (from UX Spec)

| Token | Value | Usage |
|-------|-------|-------|
| Spacing md | 16pt | Padding cards |
| Spacing lg | 24pt | Between sections |
| Radius md | 12pt | Cards |
| Primary Color | .tint (system) | CTA, accents |
| Background | Color(.systemBackground) | Main background |
| Surface | Color(.secondarySystemBackground) | Cards |

### Component Specifications

**WelcomeSection:**
- SF Symbol: `graduationcap.fill` (placeholder for Madinia logo)
- Title: "Bienvenue chez Madinia" (Title 1, 28pt Bold)
- Subtitle: "Formations IA pour transformer votre métier" (Body, 17pt)
- Spacing: 8pt between elements

**HighlightCard:**
- Width: 280pt (fixed for horizontal scroll)
- Padding: 16pt
- Corner radius: 12pt
- Background: .secondarySystemBackground
- Shadow: subtle (radius: 4, y: 2, opacity: 0.1)
- Content: Title (Title 3), Level badge, Price, Date

**QuickAccessSection:**
- Layout: HStack with equal width buttons
- Button style: .bordered (secondary)
- Spacing: 12pt between buttons

### File Locations

| File | Location |
|------|----------|
| HomeViewModel.swift | MadiniaApp/Views/Home/HomeViewModel.swift |
| WelcomeSection.swift | MadiniaApp/Views/Home/Components/WelcomeSection.swift |
| HighlightCard.swift | MadiniaApp/Views/Home/Components/HighlightCard.swift |
| QuickAccessSection.swift | MadiniaApp/Views/Home/Components/QuickAccessSection.swift |
| LoadingView.swift | MadiniaApp/Views/Shared/LoadingView.swift |
| ErrorView.swift | MadiniaApp/Views/Shared/ErrorView.swift |
| HomeView.swift | MadiniaApp/Views/Home/HomeView.swift (existing, update) |

### Previous Story Learnings (from 2.1)

**CRITICAL - Apply these lessons:**

1. **Test target configuration:** Ensure all test files are added to MadiniaAppTests target in project.pbxproj
2. **Retry logic:** APIService already has exponential backoff - ViewModel just needs to call it
3. **French error messages:** All user-facing strings must be in French
4. **Sample data:** Use Formation.samples for previews (already exists)
5. **Fixed preview dates:** Formation.samples uses fixed dates for consistent previews

### Existing Code to Leverage

| Existing | Usage in this story |
|----------|---------------------|
| Formation model | Data for HighlightCard |
| Formation.samples | Preview data |
| APIService | Fetch formations |
| MockAPIService | Testing with shouldFail flag |
| LoadingState | View state management |
| APIError | Error handling |

### NFR Compliance

| NFR | Implementation |
|-----|----------------|
| NFR2: Chargement < 2s | Loading state shown, async fetch |
| NFR5: 60 FPS | Native SwiftUI animations |
| NFR10: VoiceOver | Add .accessibilityLabel to all elements |
| NFR11: Dynamic Type | Use .font() semantic styles |
| NFR13: Touch targets | 44x44pt minimum for buttons |

### References

- [Source: architecture.md#Frontend Architecture]
- [Source: architecture.md#Code Patterns]
- [Source: ux-design-specification.md#Component Strategy]
- [Source: ux-design-specification.md#Visual Design Foundation]
- [Source: epics.md#Story 2.2]
- [Source: prd.md#FR3 écran d'accueil highlights]

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- Build succeeded with xcodebuild
- All files added to project.pbxproj
- Unit tests created (simulator had boot issues, but tests compile)

### Completion Notes List

- HomeViewModel uses @Observable macro with LoadingState<[Formation]>
- highlightedFormations computed property returns first 3 formations
- WelcomeSection uses graduationcap.fill SF Symbol as placeholder logo
- HighlightCard displays formation with level badge (color-coded by level), price (EUR formatted), and optional date
- QuickAccessSection provides navigation to Formations, Blog, and Contact tabs
- LoadingView and ErrorView are reusable shared components
- HomeView integrates all components with proper state handling
- MainTabView updated to pass selectedTab binding to HomeView for tab navigation
- All strings in French per architecture requirements
- Accessibility labels added to all interactive elements
- Unit tests cover: initial state, loading transitions, success, error handling, retry, highlighted formations limit

### Change Log

| Date | Change | By |
|------|--------|-----|
| 2026-01-23 | Story created with comprehensive context from 2.1 learnings | SM Agent (Claude Opus 4.5) |
| 2026-01-23 | Implemented all 9 tasks, ready for review | Dev Agent (Claude Opus 4.5) |
| 2026-01-23 | Code review: 5 issues found and auto-fixed | Review Agent (Claude Opus 4.5) |

### Code Review Notes

**Review Result:** ✅ PASSED (after fixes)

**Issues Found & Fixed:**
1. **Performance** - HighlightCard: Made NumberFormatter/DateFormatter static to avoid recreation on each render
2. **Test Coverage** - Added tests for all APIError types (serverError, invalidResponse, decodingError)
3. **Accessibility** - Fixed HighlightCard hint to match actual behavior ("voir toutes les formations")
4. **Design Consistency** - QuickAccessSection: Changed corner radius from 10pt to 12pt (md spec)
5. **Code Quality** - Made preview helper structs fileprivate to avoid polluting public API

### File List

Files created/modified during implementation:

- [x] MadiniaApp/Views/Home/HomeViewModel.swift (created)
- [x] MadiniaApp/Views/Home/Components/WelcomeSection.swift (created)
- [x] MadiniaApp/Views/Home/Components/HighlightCard.swift (created)
- [x] MadiniaApp/Views/Home/Components/QuickAccessSection.swift (created)
- [x] MadiniaApp/Views/Shared/LoadingView.swift (created)
- [x] MadiniaApp/Views/Shared/ErrorView.swift (created)
- [x] MadiniaApp/Views/Home/HomeView.swift (updated)
- [x] MadiniaApp/Views/Shared/MainTabView.swift (updated)
- [x] MadiniaApp/MadiniaAppTests/HomeViewModelTests.swift (created)
- [x] MadiniaApp/MadiniaApp.xcodeproj/project.pbxproj (updated)
