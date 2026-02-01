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

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self

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

    /// Called when user taps on a notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Clear badge when user interacts with notification
        clearBadge()

        let userInfo = response.notification.request.content.userInfo
        handleNotification(userInfo: userInfo)
        completionHandler()
    }

    // MARK: - Deep Link Handling

    private func handleNotification(userInfo: [AnyHashable: Any]) {
        guard let payload = PushNotificationService.shared.parseNotification(userInfo: userInfo) else {
            return
        }

        if let handler = onDeepLink {
            // Handler is ready, process immediately
            handler(payload)
        } else {
            // Handler not ready yet (app launching), store for later
            pendingNotificationPayload = payload
        }
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
