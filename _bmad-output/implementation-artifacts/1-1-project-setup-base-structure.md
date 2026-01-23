# Story 1.1: Project Setup & Base Structure

Status: ready-for-dev

## Story

As a **developer**,
I want **the Xcode project initialized with SwiftUI and proper folder structure**,
So that **I have a solid foundation for building the app**.

## Acceptance Criteria

1. **Given** a new Xcode project
   **When** initialized with SwiftUI App template
   **Then** the project compiles without errors

2. **Given** the project is created
   **When** I examine the folder structure
   **Then** folder structure matches architecture:
   - `Models/`
   - `Views/` (with feature subfolders: Home/, Formations/, Blog/, Contact/, Madi/, Shared/)
   - `ViewModels/`
   - `Services/`
   - `Components/`
   - `Extensions/`
   - `Resources/`

3. **Given** the project is configured
   **When** I check deployment settings
   **Then** iOS 17+ deployment target is configured

4. **Given** the project is configured
   **When** I check data persistence
   **Then** SwiftData is enabled and ready for use

5. **Given** the project is created
   **When** I build and run on simulator
   **Then** the app launches without crashes

## Tasks / Subtasks

- [ ] **Task 1: Create Xcode Project** (AC: #1, #3)
  - [ ] Open Xcode → File → New → Project → iOS → App
  - [ ] Set Product Name: "MadiniaApp"
  - [ ] Set Team: (Developer's team)
  - [ ] Set Organization Identifier: "fr.madinia"
  - [ ] Set Interface: SwiftUI
  - [ ] Set Language: Swift
  - [ ] Enable "Use SwiftData" checkbox
  - [ ] Enable "Include Tests" checkbox
  - [ ] Set Deployment Target: iOS 17.0

- [ ] **Task 2: Create Folder Structure** (AC: #2)
  - [ ] Create `Models/` group
  - [ ] Create `Views/` group with subgroups:
    - [ ] `Views/Home/`
    - [ ] `Views/Home/Components/`
    - [ ] `Views/Formations/`
    - [ ] `Views/Formations/Components/`
    - [ ] `Views/Blog/`
    - [ ] `Views/Blog/Components/`
    - [ ] `Views/Contact/`
    - [ ] `Views/Madi/`
    - [ ] `Views/Madi/Components/`
    - [ ] `Views/Shared/`
  - [ ] Create `ViewModels/` group
  - [ ] Create `Services/` group
  - [ ] Create `Components/` group
  - [ ] Create `Extensions/` group
  - [ ] Create `Resources/` group

- [ ] **Task 3: Configure SwiftData** (AC: #4)
  - [ ] Verify `@Model` macro is available
  - [ ] Confirm ModelContainer is configured in App entry point
  - [ ] Test with empty model schema (placeholder)

- [ ] **Task 4: Verify Build & Run** (AC: #5)
  - [ ] Build project (⌘B) - must succeed with 0 errors
  - [ ] Run on iOS 17 Simulator
  - [ ] Verify app launches and shows default ContentView
  - [ ] Verify no console errors or warnings

- [ ] **Task 5: Initial Git Commit**
  - [ ] Initialize git repository (if not already)
  - [ ] Create .gitignore for Xcode projects
  - [ ] Stage all files
  - [ ] Commit: "feat: Initialize MadiniaApp with SwiftUI and folder structure"

## Dev Notes

### Architecture Compliance

**CRITICAL - Follow these patterns exactly:**

| Pattern | Requirement | Source |
|---------|-------------|--------|
| Language | Swift 5.9+ | [architecture.md#Architectural Decisions] |
| UI Framework | SwiftUI | [architecture.md#Architectural Decisions] |
| Architecture | MVVM with @Observable | [architecture.md#Architectural Decisions] |
| Local Storage | SwiftData | [architecture.md#Architectural Decisions] |
| Deployment Target | iOS 17.0+ | [architecture.md#Technical Constraints] |
| Dependencies | None (V1) | [architecture.md#Architectural Decisions] |

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Types (struct, class, enum) | PascalCase | `Formation`, `FormationsViewModel` |
| Properties, methods | camelCase | `formationTitle`, `fetchFormations()` |
| Files | PascalCase, match type | `Formation.swift` |
| Folders | PascalCase | `Models/`, `Views/` |

### Project Structure (EXACT)

```
MadiniaApp/
├── MadiniaApp.swift          # App entry point with @main
├── ContentView.swift         # Root view (will become TabView later)
├── Models/                   # Data models (Codable structs, @Model classes)
├── Views/                    # Feature-based views
│   ├── Home/
│   │   ├── Components/
│   ├── Formations/
│   │   ├── Components/
│   ├── Blog/
│   │   ├── Components/
│   ├── Contact/
│   ├── Madi/
│   │   ├── Components/
│   └── Shared/              # Shared views like LoadingView, ErrorView
├── ViewModels/              # @Observable ViewModels
├── Services/                # Business logic & API services
├── Components/              # App-wide reusable UI components
├── Extensions/              # Swift extensions (Color+Theme, etc.)
├── Resources/               # Assets, Localizable.strings
└── Tests/                   # Unit & UI tests
```

### SwiftData Configuration

The app entry point should look like:

```swift
import SwiftUI
import SwiftData

@main
struct MadiniaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [/* Models will be added later */])
    }
}
```

**Note:** Leave ModelContainer empty for now - models will be added in Epic 2.

### Technical Requirements

| Requirement | Value |
|-------------|-------|
| Xcode Version | 15.0+ (for iOS 17 SDK) |
| Swift Version | 5.9+ |
| iOS Deployment Target | 17.0 |
| Device Family | iPhone only (not iPad for V1) |
| Orientation | Portrait only |
| Language | French (Localizable.strings) |

### Bundle Identifier

Use: `fr.madinia.MadiniaApp`

### .gitignore Template

```gitignore
# Xcode
*.xcodeproj/*
!*.xcodeproj/project.pbxproj
!*.xcodeproj/xcshareddata/
!*.xcodeproj/project.xcworkspace/
*.xcworkspace/*
!*.xcworkspace/contents.xcworkspacedata
!*.xcworkspace/xcshareddata/
xcuserdata/
*.xccheckout
*.moved-aside
DerivedData/
*.hmap
*.ipa
*.dSYM.zip
*.dSYM

# Swift Package Manager
.build/
Packages/
Package.pins
Package.resolved
*.xcodeproj

# CocoaPods (not used but good to have)
Pods/
*.xcworkspace

# Fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output

# OS
.DS_Store

# Environment
.env
.env.local
```

### References

- [Source: architecture.md#Project Structure & Boundaries]
- [Source: architecture.md#Architectural Decisions from Starter]
- [Source: architecture.md#Naming Conventions]
- [Source: architecture.md#Implementation Handoff]
- [Source: epics.md#Story 1.1]

## Dev Agent Record

### Agent Model Used

_To be filled by dev agent_

### Debug Log References

_To be filled during implementation_

### Completion Notes List

_To be filled after implementation_

### Change Log

| Date | Change | By |
|------|--------|-----|
| 2026-01-23 | Story created | SM Agent |

### File List

_Files created/modified during implementation:_

- [ ] MadiniaApp/MadiniaApp.swift
- [ ] MadiniaApp/ContentView.swift
- [ ] MadiniaApp/Models/ (folder)
- [ ] MadiniaApp/Views/ (folder with subfolders)
- [ ] MadiniaApp/ViewModels/ (folder)
- [ ] MadiniaApp/Services/ (folder)
- [ ] MadiniaApp/Components/ (folder)
- [ ] MadiniaApp/Extensions/ (folder)
- [ ] MadiniaApp/Resources/ (folder)
- [ ] .gitignore
