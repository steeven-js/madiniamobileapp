//
//  AppDelegate.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import UIKit
import UserNotifications

/// App Delegate for handling push notifications and deep links.
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    /// Deep link handler callback
    var onDeepLink: ((PushNotificationService.NotificationPayload) -> Void)? {
        didSet {
            // Process pending payload when handler is set
            if let payload = pendingNotificationPayload {
                pendingNotificationPayload = nil
                onDeepLink?(payload)
            }
        }
    }

    /// Stores notification payload when app is launched from notification
    /// (before onDeepLink handler is configured)
    private var pendingNotificationPayload: PushNotificationService.NotificationPayload?

    /// Push notification service
    private let pushService = PushNotificationService.shared

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self

        // Register notification categories for quick actions
        pushService.registerNotificationCategories()

        // Clear badge on launch
        clearBadge()

        // Check for notification that launched the app
        if let notification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            handleNotification(userInfo: notification)
        }

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Clear badge when app becomes active (from background or launch)
        clearBadge()
    }

    // MARK: - Remote Notifications

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        PushNotificationService.shared.didRegisterForRemoteNotifications(deviceToken: deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        PushNotificationService.shared.didFailToRegisterForRemoteNotifications(error: error)
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// Called when notification is received while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner and play sound even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    /// Called when user taps on a notification or an action button
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Clear badge when user interacts with notification
        clearBadge()

        // Parse the notification response (includes action info)
        guard let payload = pushService.parseNotificationResponse(response) else {
            completionHandler()
            return
        }

        // Handle quick action if present
        if let action = payload.action {
            handleQuickAction(action, payload: payload)
        } else {
            // Default tap - navigate to content
            handleNotificationPayload(payload)
        }

        completionHandler()
    }

    // MARK: - Deep Link Handling

    private func handleNotification(userInfo: [AnyHashable: Any]) {
        guard let payload = pushService.parseNotification(userInfo: userInfo) else {
            return
        }
        handleNotificationPayload(payload)
    }

    private func handleNotificationPayload(_ payload: PushNotificationService.NotificationPayload) {
        if let handler = onDeepLink {
            // Handler is ready, process immediately
            handler(payload)
        } else {
            // Handler not ready yet (app launching), store for later
            pendingNotificationPayload = payload
        }
    }

    // MARK: - Quick Action Handling

    private func handleQuickAction(_ action: NotificationAction, payload: PushNotificationService.NotificationPayload) {
        switch action {
        case .addToFavorites:
            // Add to favorites without opening app
            if let id = payload.id {
                Task {
                    await FavoritesService.shared.addFavorite(formationId: id)
                    HapticManager.favoriteAdded()

                    // Show local notification to confirm
                    await showActionConfirmation(
                        title: "Ajouté aux favoris",
                        body: "La formation a été ajoutée à vos favoris."
                    )
                }
            }

        case .shareArticle:
            // Sharing requires opening the app to show share sheet
            handleNotificationPayload(payload)

        default:
            // Other actions open the app and navigate to content
            handleNotificationPayload(payload)
        }
    }

    /// Shows a brief confirmation notification for background actions
    private func showActionConfirmation(title: String, body: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = nil

        let request = UNNotificationRequest(
            identifier: "action_confirmation_\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        try? await UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Badge Management

    /// Clears the app icon badge
    private func clearBadge() {
        Task {
            do {
                try await UNUserNotificationCenter.current().setBadgeCount(0)
            } catch {
                // Fallback for older iOS versions or errors
                await MainActor.run {
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
            }
        }
    }
}
