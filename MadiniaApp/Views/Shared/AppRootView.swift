//
//  AppRootView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// Root view managing splash screen and main content transition.
/// Coordinates with FormationsRepository to determine when initial data is loaded.
struct AppRootView: View {
    /// App launch state
    @State private var appState = AppLaunchState()

    /// Shared repository for initial data loading status
    private let repository = FormationsRepository.shared

    /// Accessibility: reduced motion preference
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            // Main content (always present but potentially hidden)
            MainTabView()
                .opacity(appState.showMainContent ? 1 : 0)

            // Splash screen overlay
            if appState.showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.4), value: appState.showSplash)
        .task {
            await performInitialLoad()
        }
    }

    // MARK: - Data Loading

    /// Performs initial data loading and manages splash screen dismissal
    private func performInitialLoad() async {
        // Start loading data and minimum duration concurrently
        await withTaskGroup(of: Void.self) { group in
            // Load formations
            group.addTask {
                await repository.fetchIfNeeded()
            }

            // Load categories
            group.addTask {
                await repository.fetchCategoriesIfNeeded()
            }

            // Minimum splash duration for branding (1.2 seconds)
            group.addTask {
                try? await Task.sleep(for: .milliseconds(1200))
            }

            // Wait for all tasks to complete
            await group.waitForAll()
        }

        // Transition to main content
        appState.showMainContent = true

        // Dismiss splash with slight delay for smooth transition
        try? await Task.sleep(for: .milliseconds(100))
        appState.showSplash = false
    }
}

// MARK: - App Launch State

/// Observable state for managing app launch sequence
@Observable
final class AppLaunchState {
    /// Whether to show the splash screen
    var showSplash = true

    /// Whether to show the main content
    var showMainContent = false
}

// MARK: - Preview

#Preview("App Root - Loading") {
    AppRootView()
}
