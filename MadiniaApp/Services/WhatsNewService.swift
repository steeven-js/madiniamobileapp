//
//  WhatsNewService.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-30.
//

import Foundation

/// Service managing the "What's New" screen display logic.
/// Shows the screen once after app update, then allows manual access via settings.
@Observable
final class WhatsNewService {
    /// Shared singleton instance
    static let shared = WhatsNewService()

    /// UserDefaults key for storing the last seen version
    private let lastSeenVersionKey = "whatsNew_lastSeenVersion"

    /// Current app version
    var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    /// Last version the user has seen the What's New screen for
    var lastSeenVersion: String? {
        get { UserDefaults.standard.string(forKey: lastSeenVersionKey) }
        set { UserDefaults.standard.set(newValue, forKey: lastSeenVersionKey) }
    }

    /// Whether to show the What's New screen (app was updated)
    var shouldShowWhatsNew: Bool {
        guard let lastSeen = lastSeenVersion else {
            // First launch ever - show it
            return true
        }
        // Show if current version is different from last seen
        return currentVersion != lastSeen
    }

    private init() {}

    /// Mark the current version as seen (called when user closes What's New)
    func markAsSeen() {
        lastSeenVersion = currentVersion
    }

    /// Reset for testing purposes
    func reset() {
        lastSeenVersion = nil
    }
}
