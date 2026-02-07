//
//  NotificationService.swift
//  MadiniaAppNotificationService
//
//  Notification Service Extension for rich push notifications.
//  Downloads and attaches images to notifications before display.
//

import UserNotifications

/// Notification Service Extension that processes incoming notifications
/// to add rich media attachments (images).
class NotificationService: UNNotificationServiceExtension {

    /// The current notification content handler
    var contentHandler: ((UNNotificationContent) -> Void)?

    /// The modified notification content
    var bestAttemptContent: UNMutableNotificationContent?

    /// Called when a notification is received that needs processing
    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let bestAttemptContent = bestAttemptContent else {
            contentHandler(request.content)
            return
        }

        // Check for image URL in the payload
        if let imageURLString = request.content.userInfo["image_url"] as? String,
           let imageURL = URL(string: imageURLString) {
            downloadImage(from: imageURL) { [weak self] attachment in
                if let attachment = attachment {
                    bestAttemptContent.attachments = [attachment]
                }
                contentHandler(bestAttemptContent)
                self?.cleanup()
            }
        } else {
            // No image URL, deliver notification as-is
            contentHandler(bestAttemptContent)
        }
    }

    /// Called when the system is about to terminate the extension
    override func serviceExtensionTimeWillExpire() {
        // Deliver whatever we have so far
        if let contentHandler = contentHandler,
           let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
        cleanup()
    }

    // MARK: - Image Download

    /// Downloads an image from URL and creates a notification attachment
    private func downloadImage(
        from url: URL,
        completion: @escaping (UNNotificationAttachment?) -> Void
    ) {
        let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            guard error == nil,
                  let localURL = localURL,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                completion(nil)
                return
            }

            // Determine file extension from response or URL
            let fileExtension = self.fileExtension(for: response, url: url)

            // Create a unique filename in temp directory
            let tempDirectory = FileManager.default.temporaryDirectory
            let uniqueFilename = "\(UUID().uuidString).\(fileExtension)"
            let destinationURL = tempDirectory.appendingPathComponent(uniqueFilename)

            do {
                // Remove existing file if any
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }

                // Copy downloaded file to destination
                try FileManager.default.copyItem(at: localURL, to: destinationURL)

                // Create attachment
                let attachment = try UNNotificationAttachment(
                    identifier: "image",
                    url: destinationURL,
                    options: nil
                )
                completion(attachment)
            } catch {
                print("NotificationService: Failed to create attachment: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }

    /// Determines the file extension from response or URL
    private func fileExtension(for response: HTTPURLResponse, url: URL) -> String {
        // Try to get from Content-Type header
        if let mimeType = response.mimeType {
            switch mimeType.lowercased() {
            case "image/jpeg", "image/jpg":
                return "jpg"
            case "image/png":
                return "png"
            case "image/gif":
                return "gif"
            case "image/webp":
                return "webp"
            default:
                break
            }
        }

        // Fallback to URL extension
        let pathExtension = url.pathExtension.lowercased()
        if !pathExtension.isEmpty {
            return pathExtension
        }

        // Default to jpg
        return "jpg"
    }

    /// Cleans up resources
    private func cleanup() {
        contentHandler = nil
        bestAttemptContent = nil
    }
}
