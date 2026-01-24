# Story 2.5: Formation Card & Info Badge Components

Status: done

## Story

As a **user**,
I want **formation cards to show key info at a glance**,
So that **I understand a formation in less than 5 seconds** (FR6).

## Acceptance Criteria

1. **Given** a FormationCard is displayed
   **When** I look at it
   **Then** I see InfoBadges for: Durée, Niveau, Certification (si applicable), Catégorie

2. **Given** I'm viewing formation cards
   **When** I scan the layout
   **Then** I can understand key info in under 5 seconds

3. **Given** I'm viewing formation cards
   **When** I observe the visual hierarchy
   **Then** the most important info (title, level) is emphasized

4. **Given** a FormationCard is displayed
   **When** I look at the InfoBadges
   **Then** they follow UX design tokens (colors, spacing, icons)

5. **Given** I'm using VoiceOver
   **When** I navigate formation cards
   **Then** InfoBadges are properly announced with context

6. **Given** a formation is certifiante
   **When** the card is displayed
   **Then** I see a prominent certification badge with checkmark

7. **Given** a formation has a category with color
   **When** the card is displayed
   **Then** the category badge uses the category's hex color

## Tasks / Subtasks

- [x] **Task 1: Create InfoBadge Component** (AC: #1, #4, #5)
  - [x] Create `Views/Shared/InfoBadge.swift`
  - [x] Add enum InfoBadgeStyle: duration, level, certification, category
  - [x] Add icon, label, and optional color parameters
  - [x] Apply consistent sizing: 28pt height, 8pt horizontal padding
  - [x] Use SF Symbols for icons (clock, chart.bar, checkmark.seal, folder)
  - [x] Add VoiceOver accessibility label

- [x] **Task 2: Enhance FormationCard with InfoBadges** (AC: #1, #2, #3, #6, #7)
  - [x] Refactor `Views/Formations/Components/FormationCard.swift`
  - [x] Replace inline duration/level display with InfoBadge components
  - [x] Add certification InfoBadge (conditional: only if certification == true)
  - [x] Add category InfoBadge (conditional: only if category exists)
  - [x] Improve layout for 5-second scannability
  - [x] Keep level icon on left as primary visual anchor

- [x] **Task 3: Enhance HighlightCard with InfoBadges** (AC: #1, #4)
  - [x] Update `Views/Home/Components/HighlightCard.swift`
  - [x] Use InfoBadge for level display
  - [x] Add certification badge if applicable
  - [x] Maintain card size constraints (280x180)

- [x] **Task 4: Add Category Color Support** (AC: #7)
  - [x] Verify Color+Hex.swift extension works correctly
  - [x] Apply category.color hex to InfoBadge background
  - [x] Fallback to accentColor if no hex provided

- [x] **Task 5: Update project.pbxproj** (AC: all)
  - [x] Add InfoBadge.swift to project
  - [x] Verify compilation succeeds

- [ ] **Task 6: Write Unit Tests** (AC: #5, #6, #7) - SKIPPED per user request
  - [ ] Create `MadiniaAppTests/InfoBadgeTests.swift`
  - [ ] Test InfoBadge renders with all styles
  - [ ] Test accessibility labels are correct
  - [ ] Test category color fallback logic

## Dev Notes

### Architecture Compliance

**CRITICAL - Follow these patterns exactly:**

| Pattern | Requirement | Source |
|---------|-------------|--------|
| Component | SwiftUI View struct with enum style | [architecture.md#Components] |
| Colors | Use Color+Hex for category colors | [Color+Hex.swift] |
| Naming | PascalCase types, camelCase properties | [architecture.md#Naming Conventions] |
| Accessibility | accessibilityLabel on each badge | [NFR10] |

### InfoBadge Component Structure

```swift
import SwiftUI

/// Reusable badge component for displaying formation metadata.
/// Used in FormationCard and HighlightCard for consistent info display.
struct InfoBadge: View {
    /// Badge display style
    enum Style {
        case duration(String)           // "14 heures"
        case level(String, Color)       // "Débutant", .green
        case certification              // Shows "Certifiante" with checkmark
        case category(String, Color?)   // "IA Générative", optional hex color
    }

    let style: Style

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.caption2)

            Text(labelText)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(backgroundColor.opacity(0.15))
        .foregroundStyle(foregroundColor)
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    // MARK: - Computed Properties

    private var iconName: String {
        switch style {
        case .duration: return "clock"
        case .level: return "chart.bar.fill"
        case .certification: return "checkmark.seal.fill"
        case .category: return "folder.fill"
        }
    }

    private var labelText: String {
        switch style {
        case .duration(let text): return text
        case .level(let text, _): return text
        case .certification: return "Certifiante"
        case .category(let text, _): return text
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .duration: return .secondary
        case .level(_, let color): return color
        case .certification: return .green
        case .category(_, let color): return color ?? .accentColor
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .duration: return .secondary
        case .level(_, let color): return color
        case .certification: return .green
        case .category(_, let color): return color ?? .accentColor
        }
    }

    private var accessibilityText: String {
        switch style {
        case .duration(let text): return "Durée: \(text)"
        case .level(let text, _): return "Niveau: \(text)"
        case .certification: return "Formation certifiante"
        case .category(let text, _): return "Catégorie: \(text)"
        }
    }
}
```

### Enhanced FormationCard Structure

```swift
import SwiftUI

/// Card component displaying a formation in the list.
/// Shows title, level icon, and InfoBadges for key info at a glance.
struct FormationCard: View {
    let formation: Formation
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 16) {
                // Left: Level icon (primary visual anchor)
                levelIcon
                    .frame(width: 48, height: 48)

                // Center: Title and badges
                VStack(alignment: .leading, spacing: 8) {
                    Text(formation.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    // InfoBadges row
                    infoBadgesRow
                }

                Spacer()

                // Right: Certification or Category indicator
                rightIndicator
            }
            .padding(16)
            .frame(minHeight: 80)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
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

    @ViewBuilder
    private var infoBadgesRow: some View {
        HStack(spacing: 8) {
            InfoBadge(style: .duration(formation.duration))
            InfoBadge(style: .level(formation.levelLabel, levelColor))
        }
    }

    @ViewBuilder
    private var rightIndicator: some View {
        if formation.certification == true {
            InfoBadge(style: .certification)
        } else if let category = formation.category {
            let color = category.color.flatMap { Color(hex: $0) }
            InfoBadge(style: .category(category.name, color))
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

    private var levelIconName: String {
        switch formation.level.lowercased() {
        case "debutant": return "star.fill"
        case "intermediaire": return "flame.fill"
        case "avance", "expert": return "crown.fill"
        default: return "book.fill"
        }
    }

    private var accessibilityDescription: String {
        var desc = "\(formation.title), niveau \(formation.levelLabel), durée \(formation.duration)"
        if formation.certification == true {
            desc += ", certifiante"
        }
        if let category = formation.category {
            desc += ", catégorie \(category.name)"
        }
        return desc
    }
}
```

### Design Specifications (from UX Spec)

| Element | Specification |
|---------|---------------|
| InfoBadge Height | 28pt (8pt vertical padding) |
| InfoBadge Padding | 8pt horizontal |
| InfoBadge Shape | Capsule |
| InfoBadge Background | 15% opacity of foreground color |
| Badge Icon | SF Symbol, caption2 size |
| Badge Text | Caption, medium weight |
| Badge Spacing | 8pt between badges |
| Card Layout | Level icon left, title+badges center, indicator right |

### Color Mapping

| Level | Color | Icon |
|-------|-------|------|
| debutant | .green | star.fill |
| intermediaire | .orange | flame.fill |
| avance/expert | .red | crown.fill |
| default | .blue | book.fill |

| Badge Type | Default Color |
|------------|---------------|
| Duration | .secondary |
| Level | Depends on level |
| Certification | .green |
| Category | From hex or .accentColor |

### File Locations

| File | Location |
|------|----------|
| InfoBadge.swift | MadiniaApp/Views/Shared/InfoBadge.swift |
| FormationCard.swift | MadiniaApp/Views/Formations/Components/FormationCard.swift |
| HighlightCard.swift | MadiniaApp/Views/Home/Components/HighlightCard.swift |
| InfoBadgeTests.swift | MadiniaApp/MadiniaAppTests/InfoBadgeTests.swift |

### Previous Story Learnings (from 2.4)

**CRITICAL - Apply these lessons:**

1. **Color+Hex**: Already implemented in Color+Hex.swift, use failable initializer
2. **Level matching**: Use lowercase codes (debutant, intermediaire, avance) not labels
3. **Accessibility**: Include all badge info in combined accessibilityLabel
4. **Touch targets**: Full card area tappable, minimum 44pt
5. **Static formatters**: Not needed for InfoBadges (no number formatting)

### API Model Reference

```swift
struct Formation: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let slug: String
    let shortDescription: String?
    let duration: String           // "14 heures"
    let durationHours: Int?
    let level: String              // "debutant", "intermediaire", "avance"
    let levelLabel: String         // "Débutant", "Intermédiaire", "Avancé"
    let certification: Bool?       // true if certifiante
    let certificationLabel: String?
    let imageUrl: String?
    let category: FormationCategory?
    // ... detail fields omitted
}

struct FormationCategory: Codable, Hashable {
    let id: Int
    let name: String               // "IA Générative"
    let slug: String?
    let color: String?             // "#8B5CF6"
    let icon: String?
}
```

### NFR Compliance

| NFR | Implementation |
|-----|----------------|
| NFR5: 60 FPS | Lightweight InfoBadge, no complex calculations |
| NFR10: VoiceOver | accessibilityLabel on each InfoBadge |
| NFR11: Dynamic Type | Use .font() semantic styles |
| NFR12: Contrast | 15% opacity ensures readable contrast |
| NFR13: Touch targets | Badges part of card touch area |

### References

- [Source: architecture.md#Project Structure - Views/Shared/]
- [Source: ux-design-specification.md#Custom Components - InfoBadge]
- [Source: epics.md#Story 2.5]
- [Source: prd.md#FR6 infos < 5 secondes]
- [Source: Story 2.4 - FormationCard, level colors]
- [Source: Color+Hex.swift - hex color support]
- [Source: Formation.swift - API model with category]

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- Build succeeded with xcodebuild (iPhone 17 simulator)
- All files added to project.pbxproj

### Completion Notes List

- InfoBadge component created with 4 styles: duration, level, certification, category
- FormationCard refactored to use InfoBadge components for consistent display
- HighlightCard updated to use InfoBadge components
- Category hex colors supported via Color+Hex extension
- Accessibility labels added to all InfoBadge styles
- Tests skipped per user request to focus on implementations

### Change Log

| Date | Change | By |
|------|--------|-----|
| 2026-01-23 | Story created with API-adapted acceptance criteria | SM Agent (Claude Opus 4.5) |
| 2026-01-23 | Implemented Tasks 1-5, build succeeded | Dev Agent (Claude Opus 4.5) |

### File List

Files created/modified during implementation:

- [x] MadiniaApp/Views/Shared/InfoBadge.swift (created)
- [x] MadiniaApp/Views/Formations/Components/FormationCard.swift (updated)
- [x] MadiniaApp/Views/Home/Components/HighlightCard.swift (updated)
- [x] MadiniaApp/MadiniaApp.xcodeproj/project.pbxproj (updated)

