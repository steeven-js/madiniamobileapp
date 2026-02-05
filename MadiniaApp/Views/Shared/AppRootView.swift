//
//  AppRootView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// Root view managing splash screen, onboarding, and main content transition.
/// Preloads all app data during splash before showing main content or onboarding.
struct AppRootView: View {
    /// App launch state
    @State private var appState = AppLaunchState()

    /// Whether onboarding has been completed (local state for reactivity)
    @State private var hasCompletedOnboarding = OnboardingService.shared.hasCompletedOnboarding

    /// Centralized data repository for preloading
    private let dataRepository = AppDataRepository.shared

    /// Accessibility: reduced motion preference
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            // Main content: either onboarding or main tab view
            if hasCompletedOnboarding {
                MainTabView()
                    .opacity(appState.showMainContent ? 1 : 0)
            } else {
                OnboardingFlowView(onComplete: {
                    hasCompletedOnboarding = true
                })
                .opacity(appState.showMainContent ? 1 : 0)
            }

            // Splash screen overlay
            if appState.showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.4), value: appState.showSplash)
        .animation(.easeInOut(duration: 0.3), value: hasCompletedOnboarding)
        .task {
            await performInitialLoad()
        }
    }

    // MARK: - Data Loading

    /// Performs initial data loading and manages splash screen dismissal.
    /// Waits for both minimum splash duration AND data to be ready.
    private func performInitialLoad() async {
        // Start loading data and minimum duration concurrently
        await withTaskGroup(of: Void.self) { group in
            // Preload all app data (formations, categories, services)
            group.addTask {
                await dataRepository.preloadAllData()
            }

            // Minimum splash duration for branding (1.5 seconds)
            // This ensures the logo animation completes
            group.addTask {
                try? await Task.sleep(for: .milliseconds(1500))
            }

            // Wait for BOTH tasks to complete
            // - Data must be loaded (or failed with cache fallback)
            // - Minimum time must have elapsed
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
