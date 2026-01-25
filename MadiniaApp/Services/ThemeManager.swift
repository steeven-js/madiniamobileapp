//
//  ThemeManager.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-25.
//

import SwiftUI

/// Available app theme options
enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark

    /// Localized title for display
    var title: String {
        switch self {
        case .system: return "Automatique"
        case .light: return "Clair"
        case .dark: return "Sombre"
        }
    }

    /// System icon for the theme
    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

/// Manages app-wide theme settings with persistence
@Observable
final class ThemeManager {
    /// Shared singleton instance
    static let shared = ThemeManager()

    /// Current theme selection (persisted via UserDefaults)
    var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: themeKey)
        }
    }

    /// Returns the appropriate ColorScheme for SwiftUI's preferredColorScheme modifier
    /// Returns nil for .system to use device settings
    var colorScheme: ColorScheme? {
        switch currentTheme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    private let themeKey = "app_theme"

    private init() {
        // Load saved theme or default to system
        if let savedTheme = UserDefaults.standard.string(forKey: themeKey),
           let theme = AppTheme(rawValue: savedTheme) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .system
        }
    }
}
