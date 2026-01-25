//
//  PushNotificationService.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import Foundation
import SwiftUI
import UserNotifications
import UIKit

/// Service for managing push notifications.
/// Handles permission requests, token registration, and notification preferences.
@Observable
final class PushNotificationService: NSObject {
    /// Shared singleton instance
    static let shared = PushNotificationService()

    // MARK: - State

    /// Current authorization status
    private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    /// Whether push notifications are enabled
    var isEnabled: Bool {
        authorizationStatus == .authorized
    }

    /// Whether we should show the permission prompt
    private(set) var shouldPromptForPermission: Bool = false

    /// The current device token (if registered)
    private(set) var deviceToken: String?

    // MARK: - Preferences

    /// User preferences for notification types
    @ObservationIgnored
    @AppStorage("notif_new_formations") var notifyNewFormations: Bool = true

    @ObservationIgnored
    @AppStorage("notif_new_articles") var notifyNewArticles: Bool = true

    @ObservationIgnored
    @AppStorage("notif_reminders") var notifyReminders: Bool = true

    @ObservationIgnored
    @AppStorage("notif_engagement") var notifyEngagement: Bool = true

    @ObservationIgnored
    @AppStorage("permission_requested") private var permissionRequested: Bool = false

    // MARK: - Dependencies

    private let apiService: APIServiceProtocol

    // MARK: - Initialization

    private override init() {
        self.apiService = APIService.shared
        super.init()
    }

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
        super.init()
    }

    // MARK: - Permission

    /// Checks current authorization status
    @MainActor
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus

        // Determine if we should prompt
        shouldPromptForPermission = !permissionRequested && authorizationStatus == .notDetermined
    }

    /// Requests push notification permission
    /// - Returns: Whether permission was granted
    @MainActor
    func requestPermission() async -> Bool {
        permissionRequested = true

        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )

            if granted {
                authorizationStatus = .authorized
                await registerForRemoteNotifications()
            } else {
                authorizationStatus = .denied
            }

            shouldPromptForPermission = false
            return granted
        } catch {
            print("Push notification permission error: \(error)")
            authorizationStatus = .denied
            shouldPromptForPermission = false
            return false
        }
    }

    /// Registers for remote notifications with APNs
    @MainActor
    func registerForRemoteNotifications() async {
        UIApplication.shared.registerForRemoteNotifications()
    }

    // MARK: - Token Management

    /// Called when device token is received from APNs
    func didRegisterForRemoteNotifications(deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        self.deviceToken = token

        // Register token with backend
        Task {
            await registerTokenWithBackend(token)
        }
    }

    /// Called when registration fails
    func didFailToRegisterForRemoteNotifications(error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }

    /// Registers the device token with the backend
    private func registerTokenWithBackend(_ token: String) async {
        do {
            try await apiService.registerDeviceToken(
                token: token,
                preferences: NotificationPreferences(
                    newFormations: notifyNewFormations,
                    newArticles: notifyNewArticles,
                    reminders: notifyReminders,
                    engagement: notifyEngagement
                )
            )
        } catch {
            // Handle silently - non-blocking
            print("Failed to register device token: \(error)")
        }
    }

    // MARK: - Preferences

    /// Updates notification preferences on the backend
    func updatePreferences() async {
        guard let token = deviceToken else { return }

        do {
            try await apiService.registerDeviceToken(
                token: token,
                preferences: NotificationPreferences(
                    newFormations: notifyNewFormations,
                    newArticles: notifyNewArticles,
                    reminders: notifyReminders,
                    engagement: notifyEngagement
                )
            )
        } catch {
            print("Failed to update preferences: \(error)")
        }
    }

    /// Opens system settings for the app
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Notification Preferences Model

struct NotificationPreferences: Encodable {
    let newFormations: Bool
    let newArticles: Bool
    let reminders: Bool
    let engagement: Bool

    enum CodingKeys: String, CodingKey {
        case newFormations = "new_formations"
        case newArticles = "new_articles"
        case reminders
        case engagement
    }
}

// MARK: - Deep Link Handling

extension PushNotificationService {
    /// Notification payload structure
    struct NotificationPayload {
        enum ContentType: String {
            case formation
            case article
            case home
        }

        let type: ContentType
        let slug: String?
    }

    /// Parses a notification's userInfo into a payload
    func parseNotification(userInfo: [AnyHashable: Any]) -> NotificationPayload? {
        guard let typeString = userInfo["type"] as? String,
              let type = NotificationPayload.ContentType(rawValue: typeString) else {
            return nil
        }

        // slug is optional for home type
        let slug = userInfo["slug"] as? String

        return NotificationPayload(type: type, slug: slug)
    }
}
