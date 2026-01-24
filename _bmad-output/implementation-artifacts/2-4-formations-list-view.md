# Story 2.4: Formations List View

Status: done

## Story

As a **user**,
I want **to see a list of all available formations**,
So that **I can browse the catalog** (FR5).

## Acceptance Criteria

1. **Given** I'm on the Formations tab
   **When** the view loads
   **Then** I see a list of FormationCard components

2. **Given** I'm viewing the formations list
   **When** I look at each card
   **Then** I see: title, level, duration, price

3. **Given** the formations list is longer than the screen
   **When** I scroll
   **Then** I can navigate through all formations smoothly

4. **Given** I'm viewing the formations list
   **When** I tap on a formation card
   **Then** I navigate to that formation's detail view (placeholder for now, full detail in Story 2.6)

5. **Given** I'm on the formations list
   **When** I pull down on the list
   **Then** the list refreshes and fetches fresh data from the API

6. **Given** the API fails to load formations
   **When** the view displays
   **Then** I see an error message with a retry button

7. **Given** I'm using VoiceOver
   **When** I navigate the formations list
   **Then** each card is accessible with proper labels and hints

## Tasks / Subtasks

- [x] **Task 1: Create FormationsViewModel** (AC: #1, #5, #6)
  - [x] Create `Views/Formations/FormationsViewModel.swift`
  - [x] Add @Observable class with `loadingState: LoadingState<[Formation]>`
  - [x] Add `formations: [Formation]` computed property
  - [x] Add `loadFormations()` async method
  - [x] Add `refresh()` async method for pull-to-refresh
  - [x] Inject APIServiceProtocol for testability

- [x] **Task 2: Create FormationCard Component** (AC: #2, #7)
  - [x] Create `Views/Formations/Components/FormationCard.swift`
  - [x] Display formation title prominently
  - [x] Display level badge with color coding (green/orange/red)
  - [x] Display duration with clock icon
  - [x] Display price formatted in EUR
  - [x] Use static formatters for price (performance)
  - [x] Apply 12pt corner radius, shadow, design tokens
  - [x] Add onTap closure for navigation

- [x] **Task 3: Update FormationsView with List** (AC: #1, #3)
  - [x] Replace placeholder with actual list implementation
  - [x] Use @State private var viewModel = FormationsViewModel()
  - [x] Use ScrollView with LazyVStack for performance
  - [x] Add section header "Toutes les formations"
  - [x] Display FormationCard for each formation
  - [x] Add .task modifier to load formations

- [x] **Task 4: Implement Pull-to-Refresh** (AC: #5)
  - [x] Add .refreshable modifier to ScrollView
  - [x] Call viewModel.refresh() in refreshable
  - [x] Ensure refresh updates the list

- [x] **Task 5: Handle Loading and Error States** (AC: #6)
  - [x] Show LoadingView when loadingState is .loading
  - [x] Show ErrorView with retry button when loadingState is .error
  - [x] Use switch statement for state handling

- [x] **Task 6: Add Navigation to Formation Detail** (AC: #4)
  - [x] Add @State var selectedFormation: Formation? for navigation
  - [x] Wrap content in NavigationStack
  - [x] Add .navigationDestination for Formation
  - [x] Create placeholder FormationDetailView (full implementation in Story 2.6)
  - [x] Pass formation to detail view on tap

- [x] **Task 7: Add Accessibility Support** (AC: #7)
  - [x] Add accessibilityLabel to FormationCard with full context
  - [x] Add accessibilityHint explaining tap action
  - [x] Use .accessibilityElement(children: .combine)
  - [x] Ensure touch targets are 44x44pt minimum

- [x] **Task 8: Update project.pbxproj** (AC: all)
  - [x] Add FormationsViewModel.swift to project
  - [x] Add FormationCard.swift to project
  - [x] Add FormationDetailView.swift to project
  - [x] Verify compilation succeeds

- [x] **Task 9: Write Unit Tests** (AC: #1, #2, #6)
  - [x] Create `MadiniaAppTests/FormationsViewModelTests.swift`
  - [x] Test loadFormations populates formations
  - [x] Test loadFormations handles errors
  - [x] Test refresh calls loadFormations
  - [x] Test loading state transitions

## Dev Notes

### Architecture Compliance

**CRITICAL - Follow these patterns exactly:**

| Pattern | Requirement | Source |
|---------|-------------|--------|
| ViewModel | @Observable class with LoadingState | [Story 2.2 HomeViewModel] |
| Component | SwiftUI View struct with closures | [Story 2.2 HighlightCard] |
| Naming | PascalCase types, camelCase properties | [architecture.md#Naming Conventions] |
| Navigation | NavigationStack + .navigationDestination | [architecture.md#Frontend Architecture] |
| Accessibility | Combined elements, labels, hints | [NFR10, NFR13] |

### FormationsViewModel Structure

```swift
import Foundation

/// ViewModel for the Formations screen, managing formation list and loading state.
@Observable
final class FormationsViewModel {
    // MARK: - State

    /// Current loading state for formations data
    private(set) var loadingState: LoadingState<[Formation]> = .idle

    // MARK: - Dependencies

    private let apiService: APIServiceProtocol

    // MARK: - Computed Properties

    /// All loaded formations
    var formations: [Formation] {
        loadingState.value ?? []
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

    @MainActor
    func refresh() async {
        // Reset to idle first to allow refresh even when loaded
        if !loadingState.isLoading {
            loadingState = .idle
            await loadFormations()
        }
    }
}
```

### FormationCard Component Structure

```swift
import SwiftUI

/// Card component displaying a formation in the list.
/// Shows title, level, duration, and price at a glance.
struct FormationCard: View {
    /// The formation to display
    let formation: Formation

    /// Action when card is tapped
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 16) {
                // Left side: Icon based on level
                levelIcon
                    .frame(width: 48, height: 48)

                // Center: Title and info
                VStack(alignment: .leading, spacing: 4) {
                    Text(formation.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    HStack(spacing: 12) {
                        // Duration
                        Label(formation.duration, systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        // Level badge
                        levelBadge
                    }
                }

                Spacer()

                // Right side: Price
                Text(formattedPrice)
                    .font(.headline)
                    .foregroundStyle(.tint)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("Appuyez pour voir les détails de cette formation")
    }

    // MARK: - Subviews

    private var levelIcon: some View {
        ZStack {
            Circle()
                .fill(levelColor.opacity(0.15))

            Image(systemName: levelIconName)
                .font(.title3)
                .foregroundStyle(levelColor)
        }
    }

    private var levelBadge: some View {
        Text(formation.level)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(levelColor.opacity(0.15))
            .foregroundStyle(levelColor)
            .clipShape(Capsule())
    }

    // MARK: - Static Formatters

    private static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    // MARK: - Computed Properties

    private var formattedPrice: String {
        Self.priceFormatter.string(from: NSNumber(value: formation.price)) ?? "\(Int(formation.price)) €"
    }

    private var levelColor: Color {
        switch formation.level.lowercased() {
        case "débutant":
            return .green
        case "intermédiaire":
            return .orange
        case "expert":
            return .red
        default:
            return .blue
        }
    }

    private var levelIconName: String {
        switch formation.level.lowercased() {
        case "débutant":
            return "star.fill"
        case "intermédiaire":
            return "flame.fill"
        case "expert":
            return "crown.fill"
        default:
            return "book.fill"
        }
    }

    private var accessibilityDescription: String {
        "\(formation.title), niveau \(formation.level), durée \(formation.duration), \(formattedPrice)"
    }
}
```

### FormationsView Structure

```swift
import SwiftUI

struct FormationsView: View {
    @State private var viewModel = FormationsViewModel()
    @State private var selectedFormation: Formation?

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Formations")
                .navigationDestination(for: Formation.self) { formation in
                    FormationDetailView(formation: formation)
                }
        }
        .task {
            await viewModel.loadFormations()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.loadingState {
        case .idle, .loading:
            LoadingView(message: "Chargement des formations...")

        case .loaded:
            formationsList

        case .error(let message):
            ErrorView(message: message) {
                Task { await viewModel.loadFormations() }
            }
        }
    }

    private var formationsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.formations) { formation in
                    NavigationLink(value: formation) {
                        FormationCard(formation: formation)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}
```

### FormationDetailView Placeholder (Story 2.6)

```swift
import SwiftUI

/// Placeholder detail view for formations.
/// Full implementation comes in Story 2.6.
struct FormationDetailView: View {
    let formation: Formation

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(formation.title)
                    .font(.title)
                    .fontWeight(.bold)

                Text(formation.description)
                    .font(.body)
                    .foregroundStyle(.secondary)

                Text("Détail complet à venir (Story 2.6)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
        }
        .navigationTitle("Détail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
```

### Design Specifications (from UX Spec)

| Element | Specification |
|---------|---------------|
| Card | Full width, 12pt corner radius |
| Card Padding | 16pt all sides |
| Card Background | secondarySystemBackground |
| Level Icon | 48pt circle, 15% opacity fill |
| Title | Headline, primary color, 2 line max |
| Duration | Caption with clock icon, secondary |
| Level Badge | Caption, capsule, colored |
| Price | Headline, tint color |
| List Spacing | 12pt between cards |
| Touch Target | Full card area (> 44pt) |

### Color Mapping (from Story 2.3)

| Level | Color | Icon |
|-------|-------|------|
| Débutant | .green | star.fill |
| Intermédiaire | .orange | flame.fill |
| Expert | .red | crown.fill |
| Default | .blue | book.fill |

### File Locations

| File | Location |
|------|----------|
| FormationsViewModel.swift | MadiniaApp/Views/Formations/FormationsViewModel.swift |
| FormationCard.swift | MadiniaApp/Views/Formations/Components/FormationCard.swift |
| FormationDetailView.swift | MadiniaApp/Views/Formations/FormationDetailView.swift |
| FormationsViewModelTests.swift | MadiniaApp/MadiniaAppTests/FormationsViewModelTests.swift |

### Previous Story Learnings (from 2.2 & 2.3)

**CRITICAL - Apply these lessons:**

1. **Static formatters**: Use static let for NumberFormatter (HighlightCard pattern)
2. **Accessibility**: Include price in accessibilityLabel, use "Appuyez pour" in hint
3. **Corner radius**: Use 12pt consistently (design token md)
4. **Loading state**: Check !loadingState.isLoading before making requests
5. **Touch targets**: Ensure full card area is tappable, minimum 44pt
6. **Level colors**: Reuse same color mapping as HighlightCard

### Existing Code to Leverage

| Existing | Usage in this story |
|----------|---------------------|
| HomeViewModel | Pattern for @Observable ViewModel |
| HighlightCard | Pattern for card with formatters, accessibility |
| LoadingState enum | Already defined, use as-is |
| LoadingView | Reuse for loading state |
| ErrorView | Reuse for error state |
| Formation model | Already has all needed properties |
| APIService.fetchFormations() | Already implemented |

### Navigation Notes

The Formations tab uses NavigationStack internally. When user taps a card:
1. NavigationLink uses `value: formation`
2. .navigationDestination receives Formation
3. FormationDetailView shows the placeholder
4. Back button returns to list

### NFR Compliance

| NFR | Implementation |
|-----|----------------|
| NFR2: < 2s load | API already has retry logic |
| NFR5: 60 FPS | LazyVStack for smooth scrolling |
| NFR10: VoiceOver | accessibilityLabel and hint on each card |
| NFR11: Dynamic Type | Use .font() semantic styles |
| NFR13: Touch targets | Full card area tappable |

### References

- [Source: architecture.md#Frontend Architecture]
- [Source: architecture.md#Feature to Directory Mapping - FormationsView]
- [Source: ux-design-specification.md#Custom Components - FormationCard]
- [Source: ux-design-specification.md#Screen Map - Formations]
- [Source: epics.md#Story 2.4]
- [Source: prd.md#FR5 liste formations]
- [Source: Story 2.2 - HomeViewModel, HighlightCard patterns]
- [Source: Story 2.3 - Color/icon mapping for levels]

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- Build succeeded with xcodebuild (iPhone 17 simulator)
- All files added to project.pbxproj
- Fixed unrelated test bug: HomeViewModelTests.swift used non-existent `.invalidResponse` → changed to `.badRequest`

### Completion Notes List

- FormationsViewModel created with @Observable pattern, LoadingState, and refresh support
- FormationCard component with level icon/badge, duration, price, full accessibility
- FormationsView updated: NavigationStack, LazyVStack list, pull-to-refresh, loading/error states
- FormationDetailView placeholder created for Story 2.6
- 11 unit tests for FormationsViewModel (state transitions, error handling, refresh)
- Static formatters used for price (performance optimization)
- Color/icon mapping consistent with ProgressPath (green/star, orange/flame, red/crown)

### Change Log

| Date | Change | By |
|------|--------|-----|
| 2026-01-23 | Story created with comprehensive context | SM Agent (Claude Opus 4.5) |
| 2026-01-23 | Implemented all 9 tasks, ready for review | Dev Agent (Claude Opus 4.5) |

### File List

Files created/modified during implementation:

- [x] MadiniaApp/Views/Formations/FormationsViewModel.swift (created)
- [x] MadiniaApp/Views/Formations/Components/FormationCard.swift (created)
- [x] MadiniaApp/Views/Formations/FormationDetailView.swift (created)
- [x] MadiniaApp/Views/Formations/FormationsView.swift (updated)
- [x] MadiniaApp/MadiniaAppTests/FormationsViewModelTests.swift (created)
- [x] MadiniaApp/MadiniaApp.xcodeproj/project.pbxproj (updated)
- [x] MadiniaApp/MadiniaAppTests/HomeViewModelTests.swift (bug fix: .invalidResponse → .badRequest)
