//
//  DeviceRegistrationService.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-06.
//

import Foundation
import UIKit

// MARK: - Device Info

/// Device information collected for registration
struct DeviceInfo: Codable {
    let deviceUuid: String
    let deviceModel: String
    let deviceName: String
    let osName: String
    let osVersion: String
    let appVersion: String
    let appBuild: String
    let locale: String
    let timezone: String
    let pushEnabled: Bool
    let pushToken: String?
    let environment: String // "sandbox" or "production"

    enum CodingKeys: String, CodingKey {
        case deviceUuid = "device_uuid"
        case deviceModel = "device_model"
        case deviceName = "device_name"
        case osName = "os_name"
        case osVersion = "os_version"
        case appVersion = "app_version"
        case appBuild = "app_build"
        case locale
        case timezone
        case pushEnabled = "push_enabled"
        case pushToken = "push_token"
        case environment
    }
}

/// Response from device registration endpoint
struct DeviceRegistrationResponse: Codable {
    let success: Bool
    let message: String?
    let data: DeviceRegistrationData?
}

struct DeviceRegistrationData: Codable {
    let registered: Bool
    let isNew: Bool
    let launchCount: Int
    let installedAt: String

    enum CodingKeys: String, CodingKey {
        case registered
        case isNew = "is_new"
        case launchCount = "launch_count"
        case installedAt = "installed_at"
    }
}

// MARK: - Device Registration Service

/// Service for registering and tracking devices with the backend.
/// Automatically registers on app launch and tracks sessions.
@Observable
final class DeviceRegistrationService {
    /// Shared singleton instance
    static let shared = DeviceRegistrationService()

    // MARK: - State

    /// Whether the device is registered
    private(set) var isRegistered = false

    /// Whether this is a new device (first launch)
    private(set) var isNewDevice = false

    /// Number of app launches
    private(set) var launchCount = 0

    /// Installation date
    private(set) var installedAt: Date?

    /// Last registration error
    private(set) var lastError: String?

    // MARK: - Private

    private var baseURL: String { AppEnvironment.apiBaseURL }
    private var apiKey: String { SecretsManager.apiKey }
    private let session: URLSession
    private let userDefaults = UserDefaults.standard

    private let deviceUUIDKey = "device_uuid"
    private let registeredKey = "device_registered"
    private let pushTokenKey = "device_push_token"

    private init() {
        self.session = .shared
        loadLocalState()
    }

    // MARK: - Public Methods

    /// Register device on app launch
    /// Should be called from AppDelegate/SceneDelegate on app launch
    @MainActor
    func registerOnLaunch() async {
        let deviceInfo = collectDeviceInfo()

        do {
            let response = try await registerDevice(deviceInfo)

            isRegistered = response.data?.registered ?? false
            isNewDevice = response.data?.isNew ?? false
            launchCount = response.data?.launchCount ?? 1

            if let installedAtString = response.data?.installedAt {
                installedAt = ISO8601DateFormatter().date(from: installedAtString)
            }

            userDefaults.set(true, forKey: registeredKey)
            lastError = nil

            #if DEBUG
            print("Device registered: isNew=\(isNewDevice), launchCount=\(launchCount)")
            #endif
        } catch {
            #if DEBUG
            print("Device registration failed: \(error)")
            #endif
            lastError = error.localizedDescription
        }
    }

    /// Update push notification token
    @MainActor
    func updatePushToken(_ token: String, enabled: Bool) async {
        userDefaults.set(token, forKey: pushTokenKey)

        do {
            try await sendPushTokenUpdate(token: token, enabled: enabled)
            #if DEBUG
            print("Push token updated successfully")
            #endif
        } catch {
            #if DEBUG
            print("Push token update failed: \(error)")
            #endif
        }
    }

    /// Get the device UUID
    var deviceUUID: String {
        if let uuid = userDefaults.string(forKey: deviceUUIDKey) {
            return uuid
        }
        let newUUID = UUID().uuidString
        userDefaults.set(newUUID, forKey: deviceUUIDKey)
        return newUUID
    }

    // MARK: - Private Methods

    private func loadLocalState() {
        isRegistered = userDefaults.bool(forKey: registeredKey)
    }

    private func collectDeviceInfo() -> DeviceInfo {
        let device = UIDevice.current

        // Get app version info
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

        // Get device model identifier (e.g., "iPhone14,2")
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0) ?? "Unknown"
            }
        }

        // Map model code to friendly name
        let deviceModel = mapModelCodeToName(modelCode)

        // Get push token if available
        let pushToken = userDefaults.string(forKey: pushTokenKey)

        // Determine environment (sandbox for DEBUG builds, production for RELEASE)
        #if DEBUG
        let environment = "sandbox"
        #else
        let environment = "production"
        #endif

        return DeviceInfo(
            deviceUuid: deviceUUID,
            deviceModel: deviceModel,
            deviceName: device.name,
            osName: device.systemName,
            osVersion: device.systemVersion,
            appVersion: appVersion,
            appBuild: appBuild,
            locale: Locale.current.identifier,
            timezone: TimeZone.current.identifier,
            pushEnabled: pushToken != nil,
            pushToken: pushToken,
            environment: environment
        )
    }

    private func mapModelCodeToName(_ code: String) -> String {
        // Common iPhone models
        let models: [String: String] = [
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,4": "iPhone 13 mini",
            "iPhone14,5": "iPhone 13",
            "iPhone14,6": "iPhone SE (3rd gen)",
            "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            "iPhone17,1": "iPhone 16 Pro",
            "iPhone17,2": "iPhone 16 Pro Max",
            "iPhone17,3": "iPhone 16",
            "iPhone17,4": "iPhone 16 Plus",
            "iPhone12,1": "iPhone 11",
            "iPhone12,3": "iPhone 11 Pro",
            "iPhone12,5": "iPhone 11 Pro Max",
            "iPhone12,8": "iPhone SE (2nd gen)",
            "x86_64": "Simulator",
            "arm64": "Simulator",
        ]
        return models[code] ?? code
    }

    private func registerDevice(_ info: DeviceInfo) async throws -> DeviceRegistrationResponse {
        let url = URL(string: "\(baseURL)/devices/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.timeoutInterval = 30

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(info)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noData
        }

        if httpResponse.statusCode >= 400 {
            if let error = APIError.from(statusCode: httpResponse.statusCode) {
                throw error
            }
        }

        let decoder = JSONDecoder()
        return try decoder.decode(DeviceRegistrationResponse.self, from: data)
    }

    private func sendPushTokenUpdate(token: String, enabled: Bool) async throws {
        let url = URL(string: "\(baseURL)/devices/push-token")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.timeoutInterval = 30

        let body: [String: Any] = [
            "device_uuid": deviceUUID,
            "push_token": token,
            "push_enabled": enabled
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noData
        }

        if httpResponse.statusCode >= 400 {
            if let error = APIError.from(statusCode: httpResponse.statusCode) {
                throw error
            }
        }
    }
}
