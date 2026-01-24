# Story 2.3: Progress Path Component

Status: done

## Story

As a **user**,
I want **to see a visual progression path Starter→Performer→Master**,
So that **I understand the learning journey** (FR4, FR8).

## Acceptance Criteria

1. **Given** I'm viewing the home screen
   **When** the ProgressPath component is displayed
   **Then** I see 3 connected steps: Starter, Performer, Master

2. **Given** I'm viewing the ProgressPath
   **When** I look at each step
   **Then** I see the pack name and brief description

3. **Given** I'm viewing the ProgressPath
   **When** I tap on a step (Starter, Performer, or Master)
   **Then** I navigate to that formation's detail view

4. **Given** I'm viewing the ProgressPath
   **When** the component renders
   **Then** the visual design follows UX specification (horizontal, connected visually)

5. **Given** I'm using VoiceOver
   **When** navigating the ProgressPath
   **Then** each step is accessible with proper labels and hints

## Tasks / Subtasks

- [x] **Task 1: Create ProgressPath Component** (AC: #1, #2, #4)
  - [x] Create `Views/Home/Components/ProgressPath.swift`
  - [x] Display 3 steps horizontally: Starter, Performer, Master
  - [x] Each step shows: icon, pack name, brief description
  - [x] Connect steps visually with lines/arrows
  - [x] Use design tokens (spacing, colors, corner radius)

- [x] **Task 2: Create ProgressStep Subcomponent** (AC: #2, #4)
  - [x] Create individual step view within ProgressPath
  - [x] Display SF Symbol icon per level (star for Starter, flame for Performer, crown for Master)
  - [x] Display pack name prominently
  - [x] Display 1-line description
  - [x] Apply level-specific color coding (green, orange, red/gold)

- [x] **Task 3: Implement Step Navigation** (AC: #3)
  - [x] Make each step tappable with Button
  - [x] Pass formation data or identifier for navigation
  - [x] Add onStepTap closure with Formation or step identifier
  - [x] Integrate with HomeView to navigate to Formations tab (for now, detail comes in Story 2.6)

- [x] **Task 4: Add Accessibility Support** (AC: #5)
  - [x] Add accessibilityLabel to each step with full context
  - [x] Add accessibilityHint explaining tap action
  - [x] Combine step elements for VoiceOver
  - [x] Ensure touch targets are 44x44pt minimum

- [x] **Task 5: Integrate into HomeView** (AC: #1, #4)
  - [x] Add ProgressPath section to HomeView after WelcomeSection
  - [x] Add "Votre parcours" section header
  - [x] Pass selectedTab binding for navigation
  - [x] Handle loading state (show ProgressPath even when formations loading)

- [x] **Task 6: Update project.pbxproj** (AC: all)
  - [x] Add ProgressPath.swift to Xcode project
  - [x] Verify compilation succeeds

- [x] **Task 7: Write Unit Tests** (AC: #1, #2)
  - [x] Create `MadiniaAppTests/ProgressPathTests.swift`
  - [x] Test that 3 steps are displayed
  - [x] Test step data (names, descriptions)
  - [x] Test tap callback is invoked

## Dev Notes

### Architecture Compliance

**CRITICAL - Follow these patterns exactly:**

| Pattern | Requirement | Source |
|---------|-------------|--------|
| Component | SwiftUI View struct | [architecture.md#Frontend Architecture] |
| Naming | PascalCase types | [architecture.md#Naming Conventions] |
| Callbacks | Closures for actions | [Story 2.2 HighlightCard pattern] |
| Accessibility | Combined elements, labels, hints | [NFR10, NFR13] |
| Design Tokens | 12pt radius, 16pt padding, 24pt spacing | [ux-design-specification.md] |

### ProgressPath Data Model

```swift
/// Represents a step in the progress path
struct ProgressStep: Identifiable {
    let id: String  // "starter", "performer", "master"
    let name: String
    let description: String
    let icon: String  // SF Symbol name
    let color: Color

    static let steps: [ProgressStep] = [
        ProgressStep(
            id: "starter",
            name: "Starter",
            description: "Fondations IA",
            icon: "star.fill",
            color: .green
        ),
        ProgressStep(
            id: "performer",
            name: "Performer",
            description: "Maîtrise avancée",
            icon: "flame.fill",
            color: .orange
        ),
        ProgressStep(
            id: "master",
            name: "Master",
            description: "Expertise complète",
            icon: "crown.fill",
            color: .red
        )
    ]
}
```

### ProgressPath Component Structure

```swift
import SwiftUI

/// Visual progression path showing Starter→Performer→Master journey
/// Displays on home screen to help users understand the learning path
struct ProgressPath: View {
    /// Action when a step is tapped
    var onStepTap: ((ProgressStep) -> Void)?

    private let steps = ProgressStep.steps

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Votre parcours")
                .font(.title2)
                .fontWeight(.bold)

            HStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    stepView(step)

                    if index < steps.count - 1 {
                        connectorLine
                    }
                }
            }
        }
    }

    private func stepView(_ step: ProgressStep) -> some View {
        Button {
            onStepTap?(step)
        } label: {
            VStack(spacing: 8) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(step.color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Image(systemName: step.icon)
                        .font(.title2)
                        .foregroundStyle(step.color)
                }

                // Name
                Text(step.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                // Description
                Text(step.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(step.name), \(step.description)")
        .accessibilityHint("Appuyez pour voir les formations \(step.name)")
    }

    private var connectorLine: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.3))
            .frame(height: 2)
            .frame(maxWidth: 24)
            .padding(.bottom, 40) // Align with circles
    }
}
```

### Design Specifications (from UX Spec)

| Element | Specification |
|---------|---------------|
| Layout | Horizontal, 3 steps with connectors |
| Step Circle | 56pt diameter, colored fill at 15% opacity |
| Icon | SF Symbol, title2 size, colored |
| Pack Name | Subheadline, semibold |
| Description | Caption, secondary color |
| Connector | 2pt height, 24pt width, secondary at 30% |
| Touch Target | Full step area, minimum 44pt |

### Color Mapping

| Level | Color | Rationale |
|-------|-------|-----------|
| Starter | .green | Beginner-friendly, go |
| Performer | .orange | Intermediate, progress |
| Master | .red (or .indigo) | Expert, achievement |

### Integration in HomeView

```swift
// In HomeView.swift, after WelcomeSection:
VStack(spacing: 24) {
    WelcomeSection()

    // Progress Path section
    ProgressPath { step in
        // Navigate to formations tab for now
        // Later: navigate to specific formation
        selectedTab = 1
    }

    // ... rest of content
}
```

### File Locations

| File | Location |
|------|----------|
| ProgressPath.swift | MadiniaApp/Views/Home/Components/ProgressPath.swift |
| ProgressPathTests.swift | MadiniaApp/MadiniaAppTests/ProgressPathTests.swift |

### Previous Story Learnings (from 2.2)

**CRITICAL - Apply these lessons:**

1. **Static formatters**: Not applicable for this component (no date/currency formatting)
2. **Accessibility hints**: Match actual behavior - "voir les formations" not "voir les détails"
3. **Corner radius**: Use 12pt for any rounded elements (design token md)
4. **Preview helpers**: Mark as fileprivate if needed
5. **Test target**: Ensure test file added to MadiniaAppTests target in project.pbxproj

### Existing Code to Leverage

| Existing | Usage in this story |
|----------|---------------------|
| HighlightCard | Pattern for tappable cards with closures |
| WelcomeSection | Pattern for section headers |
| Color coding by level | Same approach as HighlightCard levelColor |
| Accessibility patterns | Same combine/label/hint approach |

### NFR Compliance

| NFR | Implementation |
|-----|----------------|
| NFR5: 60 FPS | Native SwiftUI, no heavy computations |
| NFR10: VoiceOver | accessibilityLabel and hint on each step |
| NFR11: Dynamic Type | Use .font() semantic styles |
| NFR13: Touch targets | Full step area tappable (> 44x44pt) |

### References

- [Source: architecture.md#Frontend Architecture]
- [Source: architecture.md#Feature to Directory Mapping - ProgressPathView]
- [Source: ux-design-specification.md#Custom Components - ProgressPath]
- [Source: ux-design-specification.md#Defining Experience - Visual Starter→Master]
- [Source: epics.md#Story 2.3]
- [Source: prd.md#FR4 parcours visuel, FR8 progression packs]

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- Build succeeded with xcodebuild
- All files added to project.pbxproj
- Unit tests compile successfully

### Completion Notes List

- ProgressPath component created with 3 steps: Starter, Performer, Master
- ProgressStep model with Identifiable and Equatable conformance
- Each step displays: SF Symbol icon in colored circle (56pt), pack name, brief description
- Horizontal layout with connector lines (2pt height, 24pt width)
- Color coding: green (Starter), orange (Performer), red (Master)
- onStepTap closure for navigation callback
- Integrated into HomeView after WelcomeSection, shown regardless of loading state
- Full accessibility support: combined elements, labels, hints in French
- Touch targets exceed 44x44pt minimum (full step width)
- 11 unit tests covering: step count, order, names, descriptions, icons, colors, callbacks, accessibility

### Change Log

| Date | Change | By |
|------|--------|-----|
| 2026-01-23 | Story created with comprehensive context | SM Agent (Claude Opus 4.5) |
| 2026-01-23 | Implemented all 7 tasks, ready for review | Dev Agent (Claude Opus 4.5) |
| 2026-01-23 | Code review (Sonnet): 5 valid issues found, fixed by Opus 4.5 | Review: Sonnet, Fix: Opus 4.5 |

### File List

Files created/modified during implementation:

- [x] MadiniaApp/Views/Home/Components/ProgressPath.swift (created)
- [x] MadiniaApp/Views/Home/HomeView.swift (updated - added ProgressPath integration)
- [x] MadiniaApp/MadiniaAppTests/ProgressPathTests.swift (created)
- [x] MadiniaApp/MadiniaApp.xcodeproj/project.pbxproj (updated)
