//
//  EmailValidator.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import Foundation

/// Email validation utility for form validation.
enum EmailValidator {
    /// Validation result states
    enum Result: Equatable {
        case empty
        case invalid
        case valid
    }

    /// Validates an email address format using regex pattern.
    /// - Parameter email: The email string to validate
    /// - Returns: Validation result (empty, invalid, or valid)
    static func validate(_ email: String) -> Result {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .empty }

        // RFC 5322 simplified email pattern
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return .invalid
        }

        let range = NSRange(trimmed.startIndex..., in: trimmed)
        if regex.firstMatch(in: trimmed, options: [], range: range) != nil {
            return .valid
        }

        return .invalid
    }
}
