# Story 2.6: Formation Detail View

Status: done

## Story

As a **user**,
I want **to see complete details about a formation**,
So that **I can make an informed decision** (FR7).

## Acceptance Criteria

1. **Given** I tap on a formation card
   **When** the detail view opens
   **Then** I see the formation title prominently displayed

2. **Given** I'm viewing a formation detail
   **When** I look at the header section
   **Then** I see InfoBadges for: Durée, Niveau, Certification (si applicable)

3. **Given** I'm viewing a formation detail
   **When** I scroll through the content
   **Then** I see sections for: Description, Objectifs, Prérequis, Programme (when available)

4. **Given** I'm viewing a formation detail
   **When** I look at the bottom of the screen
   **Then** I see a prominent "Pré-inscription" CTA button (sticky)

5. **Given** I'm viewing a formation detail
   **When** I tap the share button
   **Then** the iOS share sheet appears with formation title and URL

6. **Given** I'm viewing a formation detail
   **When** I tap the back button
   **Then** I return to the formations list

7. **Given** I'm using VoiceOver
   **When** I navigate the formation detail
   **Then** all sections and buttons are properly labeled

## Tasks / Subtasks

- [x] **Task 1: Create FormationDetailViewModel** (AC: #1, #3) - SKIPPED
  - [x] Not needed for V1 - formation data passed from list is sufficient
  - [x] No API call needed, instant display

- [x] **Task 2: Redesign FormationDetailView Header** (AC: #1, #2)
  - [x] Update `Views/Formations/FormationDetailView.swift`
  - [x] Add hero section with formation title
  - [x] Add category badge if available
  - [x] Add InfoBadges row: duration, level, certification
  - [x] Add short description below badges

- [x] **Task 3: Implement Content Sections** (AC: #3)
  - [x] Created DetailSection reusable component
  - [x] Sections for: Description, Objectifs, Prérequis, Programme, Public cible, Méthodes pédagogiques
  - [x] Only show sections that have content
  - [x] HTML stripping for API content
  - [x] PDF download section with external Link

- [x] **Task 4: Add Sticky CTA Button** (AC: #4)
  - [x] Add sticky bottom bar with "Pré-inscription" button
  - [x] Style button prominently (accent color, full width)
  - [x] Using safeAreaInset for sticky positioning
  - [x] Placeholder alert until Epic 3

- [x] **Task 5: Add Share Functionality** (AC: #5)
  - [x] Add share button in navigation bar
  - [x] Use ShareLink with formation title and web URL
  - [x] Safe URL fallback handling

- [x] **Task 6: Add Navigation and Accessibility** (AC: #6, #7)
  - [x] NavigationStack back button works
  - [x] Accessibility labels on all sections
  - [x] accessibilityAddTraits(.isHeader) for headings
  - [x] Combined accessibility elements

- [x] **Task 7: Update project.pbxproj** (AC: all)
  - [x] No new files needed (FormationDetailView already in project)
  - [x] Build succeeded

## Dev Notes

### Architecture Compliance

**CRITICAL - Follow these patterns exactly:**

| Pattern | Requirement | Source |
|---------|-------------|--------|
| ViewModel | @Observable class (optional for static view) | [architecture.md] |
| Sections | VStack with proper spacing | [UX spec] |
| CTA | Sticky bottom with safeAreaInset | [iOS patterns] |
| Share | ShareLink SwiftUI component | [iOS 16+] |

### Formation Model Detail Fields

```swift
struct Formation {
    // ... basic fields from list

    // Detail-only fields (from /formations/{slug} endpoint)
    let description: String?        // Full description (HTML)
    let objectives: String?         // Learning objectives (HTML)
    let prerequisites: String?      // Prerequisites (HTML)
    let program: String?            // Program content (HTML)
    let targetAudience: String?     // Target audience
    let trainingMethods: String?    // Training methods
    let pdfFileUrl: String?         // URL to PDF file
    let viewsCount: Int?            // Number of views
    let publishedAt: String?        // Publication date
}
```

### FormationDetailView Structure

```swift
import SwiftUI

struct FormationDetailView: View {
    let formation: Formation
    @State private var showPreRegistration = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Section
                headerSection

                // Info Badges
                infoBadgesSection

                // Content Sections
                contentSections
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            ctaButton
        }
        .navigationTitle("Détail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                shareButton
            }
        }
        .alert("Pré-inscription", isPresented: $showPreRegistration) {
            Button("OK") { }
        } message: {
            Text("La pré-inscription sera disponible dans l'Epic 3")
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category badge
            if let category = formation.category {
                let color = category.color.flatMap { Color(hex: $0) }
                InfoBadge(style: .category(category.name, color))
            }

            // Title
            Text(formation.title)
                .font(.title)
                .fontWeight(.bold)

            // Short description
            if let shortDesc = formation.shortDescription {
                Text(shortDesc)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Info Badges Section

    private var infoBadgesSection: some View {
        HStack(spacing: 12) {
            InfoBadge(style: .duration(formation.duration))
            InfoBadge(style: .level(formation.levelLabel, levelColor))
            if formation.certification == true {
                InfoBadge(style: .certification)
            }
        }
    }

    // MARK: - Content Sections

    @ViewBuilder
    private var contentSections: some View {
        // Description
        if let description = formation.description, !description.isEmpty {
            DetailSection(title: "Description", content: description)
        }

        // Objectives
        if let objectives = formation.objectives, !objectives.isEmpty {
            DetailSection(title: "Objectifs", content: objectives)
        }

        // Prerequisites
        if let prerequisites = formation.prerequisites, !prerequisites.isEmpty {
            DetailSection(title: "Prérequis", content: prerequisites)
        }

        // Program
        if let program = formation.program, !program.isEmpty {
            DetailSection(title: "Programme", content: program)
        }

        // Target Audience
        if let audience = formation.targetAudience, !audience.isEmpty {
            DetailSection(title: "Public cible", content: audience)
        }

        // Training Methods
        if let methods = formation.trainingMethods, !methods.isEmpty {
            DetailSection(title: "Méthodes pédagogiques", content: methods)
        }
    }

    // MARK: - CTA Button

    private var ctaButton: some View {
        Button {
            showPreRegistration = true
        } label: {
            Text("Pré-inscription")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    // MARK: - Share Button

    private var shareButton: some View {
        ShareLink(
            item: URL(string: "https://madinia.fr/formations/\(formation.slug)")!,
            subject: Text(formation.title),
            message: Text("Découvrez cette formation: \(formation.title)")
        ) {
            Image(systemName: "square.and.arrow.up")
        }
    }

    // MARK: - Computed Properties

    private var levelColor: Color {
        switch formation.level.lowercased() {
        case "debutant": return .green
        case "intermediaire": return .orange
        case "avance", "expert": return .red
        default: return .blue
        }
    }
}
```

### DetailSection Component

```swift
/// Reusable section component for formation detail content
struct DetailSection: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(content)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}
```

### Design Specifications

| Element | Specification |
|---------|---------------|
| Title | .title, bold |
| Section Title | .headline |
| Body Text | .body, secondary color |
| Section Spacing | 24pt between sections |
| CTA Button | Full width, 12pt radius, accent color |
| CTA Bar | .ultraThinMaterial background |
| Share Icon | square.and.arrow.up |

### File Locations

| File | Location |
|------|----------|
| FormationDetailView.swift | MadiniaApp/Views/Formations/FormationDetailView.swift |
| FormationDetailViewModel.swift | MadiniaApp/Views/Formations/FormationDetailViewModel.swift (optional) |

### Previous Story Learnings (from 2.4 & 2.5)

**CRITICAL - Apply these lessons:**

1. **InfoBadge**: Reuse the InfoBadge component created in Story 2.5
2. **Level colors**: Use same color mapping (debutant=green, intermediaire=orange, avance=red)
3. **Category colors**: Use Color(hex:) for category colors
4. **Accessibility**: Combine elements for VoiceOver, add proper labels
5. **Navigation**: Already using NavigationStack from FormationsView

### API Note

The formation passed from the list may not have all detail fields. Options:
1. Use existing data if sufficient (recommended for V1)
2. Fetch full details via APIService.fetchFormation(slug:) if needed

For V1, we'll use the passed formation data since the API already returns detail fields.

### NFR Compliance

| NFR | Implementation |
|-----|----------------|
| NFR3: < 1s open | No API call needed, instant display |
| NFR5: 60 FPS | Simple ScrollView, no heavy operations |
| NFR10: VoiceOver | All sections labeled |
| NFR11: Dynamic Type | Semantic fonts used |
| NFR13: Touch targets | CTA button full width, 44pt+ height |

### References

- [Source: architecture.md#Project Structure - Views/Formations/]
- [Source: ux-design-specification.md#Screen Map - Formation Detail]
- [Source: epics.md#Story 2.6]
- [Source: prd.md#FR7 détail formation]
- [Source: Story 2.5 - InfoBadge component]
- [Source: Formation.swift - detail fields]

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- Build succeeded with xcodebuild (iPhone 17 simulator)

### Completion Notes List

- FormationDetailView fully implemented with header, badges, content sections, CTA, share
- DetailSection reusable component created for content display with HTML stripping
- InfoBadge reused from Story 2.5 for consistent badge display
- Sticky CTA button using safeAreaInset
- ShareLink for native iOS sharing with formation URL
- PDF download section with external Link
- Full accessibility support with labels and combined elements
- Level color mapping consistent with other components

### Change Log

| Date | Change | By |
|------|--------|-----|
| 2026-01-23 | Story created with comprehensive detail view spec | SM Agent (Claude Opus 4.5) |
| 2026-01-23 | Implemented all tasks, build succeeded | Dev Agent (Claude Opus 4.5) |

### File List

Files modified during implementation:

- [x] MadiniaApp/Views/Formations/FormationDetailView.swift (updated with full implementation)

