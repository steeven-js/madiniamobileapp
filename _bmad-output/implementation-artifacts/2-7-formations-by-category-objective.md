# Story 2.7: Formations by Category/Objective

Status: done

## Story

As a **user**,
I want **to filter or view formations by category or objective**,
So that **I find relevant formations faster** (FR9).

## Acceptance Criteria

1. **Given** I'm on the Formations list
   **When** I look at the top of the screen
   **Then** I see a horizontal scrollable list of category filter chips

2. **Given** I'm viewing the formations list
   **When** I tap on a category chip
   **Then** the list filters to show only formations in that category
   **And** the selected chip is visually highlighted

3. **Given** I have a category filter active
   **When** I tap "Toutes" or the same category again
   **Then** the filter is cleared and all formations are shown

4. **Given** I have a category filter active
   **When** I navigate to a formation detail and return
   **Then** my filter selection is preserved

5. **Given** no formations match the selected category
   **When** the filter is applied
   **Then** I see an empty state message "Aucune formation dans cette catégorie"

6. **Given** I'm using VoiceOver
   **When** I navigate the filter chips
   **Then** each chip announces its category name and selection state

## Tasks / Subtasks

- [x] **Task 1: Extract Categories from Formations** (AC: #1)
  - [x] Add `categories: [FormationCategory]` computed property to FormationsViewModel
  - [x] Extract unique categories from loaded formations
  - [x] Sort categories alphabetically by name

- [x] **Task 2: Add Filter State to ViewModel** (AC: #2, #3, #4)
  - [x] Add `selectedCategory: FormationCategory?` state property
  - [x] Add `filteredFormations: [Formation]` computed property
  - [x] Add `selectCategory(_:)` method for filter toggle

- [x] **Task 3: Create CategoryChip Component** (AC: #1, #6)
  - [x] Create `Views/Shared/CategoryChip.swift`
  - [x] Display category name with optional color
  - [x] Show selected state with accent color background
  - [x] Add accessibility label with selection state

- [x] **Task 4: Add Category Filter Row to FormationsView** (AC: #1, #2)
  - [x] Add horizontal ScrollView with category chips
  - [x] Add "Toutes" chip at the beginning
  - [x] Display all available categories as chips
  - [x] Handle chip tap to update filter

- [x] **Task 5: Update Formations List to Use Filtered Data** (AC: #2, #3, #5)
  - [x] Change ForEach to use `viewModel.filteredFormations`
  - [x] Update section header to show category name or "Toutes les formations"
  - [x] Add empty state for no matching formations

- [x] **Task 6: Update project.pbxproj** (AC: all)
  - [x] Add CategoryChip.swift to project
  - [x] Verify compilation succeeds

## Dev Notes

### Architecture Compliance

**CRITICAL - Follow these patterns exactly:**

| Pattern | Requirement | Source |
|---------|-------------|--------|
| ViewModel | Filter state in @Observable class | [FormationsViewModel] |
| Component | CategoryChip as reusable SwiftUI View | [InfoBadge pattern] |
| Accessibility | isSelected state in accessibility label | [NFR10] |

### FormationCategory Model (Already Exists)

```swift
struct FormationCategory: Codable, Hashable {
    let id: Int
    let name: String               // "IA Générative"
    let slug: String?
    let color: String?             // "#8B5CF6"
    let icon: String?
}
```

### FormationsViewModel Updates

```swift
@Observable
final class FormationsViewModel {
    // ... existing state ...

    /// Currently selected category filter (nil = show all)
    var selectedCategory: FormationCategory? = nil

    // MARK: - Computed Properties

    /// Unique categories from loaded formations
    var categories: [FormationCategory] {
        let allCategories = formations.compactMap { $0.category }
        var seen = Set<Int>()
        return allCategories.filter { category in
            guard !seen.contains(category.id) else { return false }
            seen.insert(category.id)
            return true
        }.sorted { $0.name < $1.name }
    }

    /// Formations filtered by selected category
    var filteredFormations: [Formation] {
        guard let category = selectedCategory else {
            return formations
        }
        return formations.filter { $0.category?.id == category.id }
    }

    // MARK: - Actions

    /// Selects or deselects a category filter
    func selectCategory(_ category: FormationCategory?) {
        if selectedCategory?.id == category?.id {
            selectedCategory = nil  // Toggle off
        } else {
            selectedCategory = category
        }
    }
}
```

### CategoryChip Component

```swift
import SwiftUI

/// Chip component for category filtering.
/// Shows category name with optional color and selected state.
struct CategoryChip: View {
    let name: String
    let color: Color?
    let isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            Text(name)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(chipBackground)
                .foregroundStyle(chipForeground)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(name), \(isSelected ? "sélectionné" : "non sélectionné")")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var chipBackground: Color {
        if isSelected {
            return color ?? .accentColor
        } else {
            return (color ?? .accentColor).opacity(0.15)
        }
    }

    private var chipForeground: Color {
        isSelected ? .white : (color ?? .accentColor)
    }
}
```

### FormationsView Updates

```swift
private var formationsList: some View {
    ScrollView {
        LazyVStack(alignment: .leading, spacing: 12) {
            // Category filter chips
            categoryFilterSection

            // Section header
            Text(sectionTitle)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)

            // Formation cards or empty state
            if viewModel.filteredFormations.isEmpty {
                emptyFilterState
            } else {
                ForEach(viewModel.filteredFormations) { formation in
                    // ... existing card code
                }
            }
        }
    }
}

private var categoryFilterSection: some View {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
            // "All" chip
            CategoryChip(
                name: "Toutes",
                color: nil,
                isSelected: viewModel.selectedCategory == nil
            ) {
                viewModel.selectCategory(nil)
            }

            // Category chips
            ForEach(viewModel.categories, id: \.id) { category in
                CategoryChip(
                    name: category.name,
                    color: category.color.flatMap { Color(hex: $0) },
                    isSelected: viewModel.selectedCategory?.id == category.id
                ) {
                    viewModel.selectCategory(category)
                }
            }
        }
        .padding(.horizontal)
    }
    .padding(.vertical, 8)
}

private var sectionTitle: String {
    if let category = viewModel.selectedCategory {
        return category.name
    }
    return "Toutes les formations"
}

private var emptyFilterState: some View {
    VStack(spacing: 12) {
        Image(systemName: "magnifyingglass")
            .font(.largeTitle)
            .foregroundStyle(.secondary)
        Text("Aucune formation dans cette catégorie")
            .font(.body)
            .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 60)
}
```

### Design Specifications

| Element | Specification |
|---------|---------------|
| Chip Height | ~36pt (8pt vertical padding) |
| Chip Padding | 16pt horizontal, 8pt vertical |
| Chip Shape | Capsule |
| Chip Spacing | 8pt between chips |
| Selected Background | Category color or accent color |
| Unselected Background | 15% opacity of color |
| Font | .subheadline |

### File Locations

| File | Location |
|------|----------|
| CategoryChip.swift | MadiniaApp/Views/Shared/CategoryChip.swift |
| FormationsView.swift | MadiniaApp/Views/Formations/FormationsView.swift (update) |
| FormationsViewModel.swift | MadiniaApp/Views/Formations/FormationsViewModel.swift (update) |

### Previous Story Learnings (from 2.5, 2.6)

**CRITICAL - Apply these lessons:**

1. **Color+Hex**: Use `category.color.flatMap { Color(hex: $0) }` for optional hex colors
2. **Accessibility**: Include selection state in accessibilityLabel
3. **Filter persistence**: State in ViewModel persists during navigation
4. **InfoBadge pattern**: Similar chip styling with capsule shape

### NFR Compliance

| NFR | Implementation |
|-----|----------------|
| NFR5: 60 FPS | Simple filtering, no complex operations |
| NFR10: VoiceOver | Selection state announced |
| NFR11: Dynamic Type | .font() semantic styles |
| NFR13: Touch targets | Chip minimum 44pt tap area |

### References

- [Source: architecture.md#Frontend Architecture]
- [Source: epics.md#Story 2.7]
- [Source: prd.md#FR9 formations par catégorie]
- [Source: FormationCategory model]
- [Source: Story 2.5 - InfoBadge pattern]
- [Source: Color+Hex.swift]

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- Build succeeded with xcodebuild (iPhone 17 simulator)

### Completion Notes List

- CategoryChip component created with selected/unselected states
- FormationsViewModel extended with filter state and computed properties
- FormationsView updated with horizontal category filter chips
- "Toutes" chip for clearing filter
- Section header dynamically updates with category name
- Empty state for no matching formations
- Filter preserved during navigation
- Full accessibility support with selection state

### Change Log

| Date | Change | By |
|------|--------|-----|
| 2026-01-23 | Story created with category filter spec | SM Agent (Claude Opus 4.5) |
| 2026-01-23 | Implemented all 6 tasks, build succeeded | Dev Agent (Claude Opus 4.5) |

### File List

Files created/modified during implementation:

- [x] MadiniaApp/Views/Shared/CategoryChip.swift (created)
- [x] MadiniaApp/Views/Formations/FormationsViewModel.swift (updated)
- [x] MadiniaApp/Views/Formations/FormationsView.swift (updated)
- [x] MadiniaApp/MadiniaApp.xcodeproj/project.pbxproj (updated)

