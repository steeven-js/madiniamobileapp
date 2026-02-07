//
//  Environment.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-06.
//

import Foundation

/// Centralized environment configuration.
/// Automatically detects DEBUG vs RELEASE builds and provides appropriate URLs.
enum AppEnvironment {
    
    // MARK: - Current Environment
    
    /// Current build environment
    static var current: BuildEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
    
    /// Whether we're in development/debug mode
    static var isDevelopment: Bool {
        current == .development
    }
    
    /// Whether we're in production/release mode
    static var isProduction: Bool {
        current == .production
    }
    
    // MARK: - API Configuration
    
    /// Base URL for the API
    static var apiBaseURL: String {
        switch current {
        case .development:
            // Use local server or staging in development
            // Change this to your local IP if testing on device with local server
            // return "http://192.168.1.XXX:8000/api/v1"
            return "https://madinia.fr/api/v1" // Use prod for now (no staging server)
        case .production:
            return "https://madinia.fr/api/v1"
        }
    }
    
    /// Website base URL
    static var websiteBaseURL: String {
        switch current {
        case .development:
            return "https://madinia.fr" // Use prod for now
        case .production:
            return "https://madinia.fr"
        }
    }
    
    // MARK: - Feature Flags
    
    /// Whether to enable verbose logging
    static var verboseLogging: Bool {
        isDevelopment
    }
    
    /// Whether to use ChatGPT backend (can be disabled for testing)
    static var useChatGPTBackend: Bool {
        true // Enable for both environments
    }
    
    /// Whether to sync data with server
    static var enableServerSync: Bool {
        true // Enable for both environments
    }
    
    // MARK: - Debug Helpers
    
    /// Print environment info (only in debug)
    static func logEnvironmentInfo() {
        #if DEBUG
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔧 Environment: \(current)")
        print("🌐 API URL: \(apiBaseURL)")
        print("📱 App Version: \(appVersion) (build \(appBuild))")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        #endif
    }
    
    /// App version string
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    /// App build number
    static var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

// MARK: - Build Environment

enum BuildEnvironment: String {
    case development = "Development"
    case production = "Production"
}
