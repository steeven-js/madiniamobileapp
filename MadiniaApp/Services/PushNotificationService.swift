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

// MARK: - Notification Category

/// Notification categories for grouping and quick actions
enum NotificationCategory: String, CaseIterable {
    case formation = "FORMATION_CATEGORY"
    case article = "ARTICLE_CATEGORY"
    case event = "EVENT_CATEGORY"
    case service = "SERVICE_CATEGORY"
    case general = "GENERAL_CATEGORY"

    /// Thread identifier for grouping notifications
    var threadIdentifier: String {
        switch self {
        case .formation: return "formations"
        case .article: return "articles"
        case .event: return "events"
        case .service: return "services"
        case .general: return "general"
        }
    }

    /// Summary format for grouped notifications
    var summaryFormat: String {
        switch self {
        case .formation: return "%u nouvelles formations"
        case .article: return "%u nouveaux articles"
        case .event: return "%u nouveaux événements"
        case .service: return "%u nouveaux services"
        case .general: return "%u notifications"
        }
    }

    /// Display name for the category
    var displayName: String {
        switch self {
        case .formation: return "Formations"
        case .article: return "Articles"
        case .event: return "Événements"
        case .service: return "Services"
        case .general: return "Général"
        }
    }
}

// MARK: - Notification Action

/// Quick actions available on notifications
enum NotificationAction: String {
    // Formation actions
    case viewFormation = "VIEW_FORMATION"
    case addToFavorites = "ADD_TO_FAVORITES"

    // Article actions
    case readArticle = "READ_ARTICLE"
    case shareArticle = "SHARE_ARTICLE"

    // Event actions
    case viewEvent = "VIEW_EVENT"
    case registerEvent = "REGISTER_EVENT"

    // Service actions
    case viewService = "VIEW_SERVICE"
    case contactService = "CONTACT_SERVICE"

    /// Localized title for the action
    var title: String {
        switch self {
        case .viewFormation: return "Voir"
        case .addToFavorites: return "Ajouter aux favoris"
        case .readArticle: return "Lire"
        case .shareArticle: return "Partager"
        case .viewEvent: return "Voir"
        case .registerEvent: return "S'inscrire"
        case .viewService: return "Voir"
        case .contactService: return "Contacter"
        }
    }

    /// SF Symbol icon for the action
    var icon: String {
        switch self {
        case .viewFormation, .readArticle, .viewEvent, .viewService:
            return "eye"
        case .addToFavorites:
            return "heart"
        case .shareArticle:
            return "square.and.arrow.up"
        case .registerEvent:
            return "person.badge.plus"
        case .contactService:
            return "envelope"
        }
    }

    /// Whether this action should open the app
    var opensApp: Bool {
        switch self {
        case .shareArticle:
            return false
        default:
            return true
        }
    }
}

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
        // Register notification categories first
        registerNotificationCategories()

        UIApplication.shared.registerForRemoteNotifications()
    }

    // MARK: - Notification Categories

    /// Registers notification categories with quick actions
    func registerNotificationCategories() {
        let center = UNUserNotificationCenter.current()

        // Formation category
        let formationCategory = UNNotificationCategory(
            identifier: NotificationCategory.formation.rawValue,
            actions: [
                UNNotificationAction(
                    identifier: NotificationAction.viewFormation.rawValue,
                    title: NotificationAction.viewFormation.title,
                    options: [.foreground]
                ),
                UNNotificationAction(
                    identifier: NotificationAction.addToFavorites.rawValue,
                    title: NotificationAction.addToFavorites.title,
                    options: []
                )
            ],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "Nouvelle formation disponible",
            categorySummaryFormat: NotificationCategory.formation.summaryFormat,
            options: []
        )

        // Article category
        let articleCategory = UNNotificationCategory(
            identifier: NotificationCategory.article.rawValue,
            actions: [
                UNNotificationAction(
                    identifier: NotificationAction.readArticle.rawValue,
                    title: NotificationAction.readArticle.title,
                    options: [.foreground]
                ),
                UNNotificationAction(
                    identifier: NotificationAction.shareArticle.rawValue,
                    title: NotificationAction.shareArticle.title,
                    options: []
                )
            ],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "Nouvel article disponible",
            categorySummaryFormat: NotificationCategory.article.summaryFormat,
            options: []
        )

        // Event category
        let eventCategory = UNNotificationCategory(
            identifier: NotificationCategory.event.rawValue,
            actions: [
                UNNotificationAction(
                    identifier: NotificationAction.viewEvent.rawValue,
                    title: NotificationAction.viewEvent.title,
                    options: [.foreground]
                ),
                UNNotificationAction(
                    identifier: NotificationAction.registerEvent.rawValue,
                    title: NotificationAction.registerEvent.title,
                    options: [.foreground]
                )
            ],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "Nouvel événement",
            categorySummaryFormat: NotificationCategory.event.summaryFormat,
            options: []
        )

        // Service category
        let serviceCategory = UNNotificationCategory(
            identifier: NotificationCategory.service.rawValue,
            actions: [
                UNNotificationAction(
                    identifier: NotificationAction.viewService.rawValue,
                    title: NotificationAction.viewService.title,
                    options: [.foreground]
                ),
                UNNotificationAction(
                    identifier: NotificationAction.contactService.rawValue,
                    title: NotificationAction.contactService.title,
                    options: [.foreground]
                )
            ],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "Nouveau service",
            categorySummaryFormat: NotificationCategory.service.summaryFormat,
            options: []
        )

        // General category (no actions)
        let generalCategory = UNNotificationCategory(
            identifier: NotificationCategory.general.rawValue,
            actions: [],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "Nouvelle notification",
            categorySummaryFormat: NotificationCategory.general.summaryFormat,
            options: []
        )

        center.setNotificationCategories([
            formationCategory,
            articleCategory,
            eventCategory,
            serviceCategory,
            generalCategory
        ])

        #if DEBUG
        print("Notification categories registered")
        #endif
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

    // MARK: - Event Reminders

    /// Schedules a local notification reminder for an event
    /// - Parameters:
    ///   - event: The event to remind about
    ///   - minutesBefore: Minutes before the event to send the reminder (default: 60)
    func scheduleEventReminder(for event: Event, minutesBefore: Int = 60) async {
        let center = UNUserNotificationCenter.current()

        // Calculate reminder date
        let reminderDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: event.startDate) ?? event.startDate

        // Only schedule if in the future
        guard reminderDate > Date() else { return }

        // Create rich notification content with category
        let imageURL: URL? = event.imageUrl.flatMap { URL(string: $0) }

        let content = createRichNotificationContent(
            title: "Rappel: \(event.title)",
            body: minutesBefore >= 60
                ? "L'événement commence dans \(minutesBefore / 60) heure\(minutesBefore >= 120 ? "s" : "")"
                : "L'événement commence dans \(minutesBefore) minutes",
            category: .event,
            userInfo: [
                "type": "event",
                "id": event.id,
                "slug": event.slug
            ],
            imageURL: imageURL
        )

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(
            identifier: "event_reminder_\(event.id)",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            #if DEBUG
            print("Scheduled event reminder for \(event.title) at \(reminderDate)")
            #endif
        } catch {
            print("Failed to schedule event reminder: \(error)")
        }
    }

    /// Cancels a scheduled event reminder
    /// - Parameter eventId: The event ID to cancel the reminder for
    func cancelEventReminder(eventId: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["event_reminder_\(eventId)"])
        #if DEBUG
        print("Cancelled event reminder for event \(eventId)")
        #endif
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
            case service
            case event
            case home
        }

        let type: ContentType
        let slug: String?
        let id: Int?
        let category: NotificationCategory?
        let action: NotificationAction?
        let imageURL: URL?
    }

    /// Parses a notification's userInfo into a payload
    func parseNotification(userInfo: [AnyHashable: Any]) -> NotificationPayload? {
        guard let typeString = userInfo["type"] as? String,
              let type = NotificationPayload.ContentType(rawValue: typeString) else {
            return nil
        }

        // slug is optional for home type
        let slug = userInfo["slug"] as? String
        let id = userInfo["id"] as? Int

        // Parse category if present
        let category: NotificationCategory?
        if let categoryString = userInfo["category"] as? String {
            category = NotificationCategory(rawValue: categoryString)
        } else {
            category = nil
        }

        // Parse image URL if present
        let imageURL: URL?
        if let imageString = userInfo["image_url"] as? String {
            imageURL = URL(string: imageString)
        } else {
            imageURL = nil
        }

        return NotificationPayload(
            type: type,
            slug: slug,
            id: id,
            category: category,
            action: nil,
            imageURL: imageURL
        )
    }

    /// Parses a notification response (with action) into a payload
    func parseNotificationResponse(_ response: UNNotificationResponse) -> NotificationPayload? {
        let userInfo = response.notification.request.content.userInfo

        guard let typeString = userInfo["type"] as? String,
              let type = NotificationPayload.ContentType(rawValue: typeString) else {
            return nil
        }

        let slug = userInfo["slug"] as? String
        let id = userInfo["id"] as? Int

        // Parse category
        let category: NotificationCategory?
        if let categoryString = userInfo["category"] as? String {
            category = NotificationCategory(rawValue: categoryString)
        } else {
            category = nil
        }

        // Parse action from response
        let action: NotificationAction?
        if response.actionIdentifier != UNNotificationDefaultActionIdentifier &&
           response.actionIdentifier != UNNotificationDismissActionIdentifier {
            action = NotificationAction(rawValue: response.actionIdentifier)
        } else {
            action = nil
        }

        // Parse image URL
        let imageURL: URL?
        if let imageString = userInfo["image_url"] as? String {
            imageURL = URL(string: imageString)
        } else {
            imageURL = nil
        }

        return NotificationPayload(
            type: type,
            slug: slug,
            id: id,
            category: category,
            action: action,
            imageURL: imageURL
        )
    }
}

// MARK: - Rich Notification Content

extension PushNotificationService {
    /// Creates a rich notification content with category and grouping
    func createRichNotificationContent(
        title: String,
        body: String,
        category: NotificationCategory,
        userInfo: [String: Any],
        imageURL: URL? = nil
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = category.rawValue
        content.threadIdentifier = category.threadIdentifier

        // Merge userInfo with category info
        var enrichedUserInfo = userInfo
        enrichedUserInfo["category"] = category.rawValue
        if let imageURL = imageURL {
            enrichedUserInfo["image_url"] = imageURL.absoluteString
        }
        content.userInfo = enrichedUserInfo

        return content
    }
}
