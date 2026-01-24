//
//  Color+Hex.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

extension Color {
    /// Creates a Color from a hex string (e.g., "#8B5CF6" or "8B5CF6")
    /// - Parameter hex: The hex color string
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        guard hexSanitized.count == 6 else {
            return nil
        }

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }

    // MARK: - Madinia Brand Colors (convenience accessors)

    /// Madinia gold accent color (#EED076)
    static let madiniaGold = Color(hex: "#EED076")!

    /// Madinia violet color (#582586)
    static let madiniaViolet = Color(hex: "#582586")!

    /// Madinia dark gray color (#0A121B)
    static let madiniaDarkGray = Color(hex: "#0A121B")!

    // MARK: - Level Colors Helper

    /// Returns the appropriate color for a formation level
    /// - Parameter level: The level string (debutant, intermediaire, avance, etc.)
    /// - Returns: The corresponding semantic color
    static func levelColor(for level: String) -> Color {
        switch level.lowercased() {
        case "debutant", "starter":
            return .green
        case "intermediaire", "performer":
            return .orange
        case "avance", "expert", "master":
            return .red
        default:
            return .madiniaGold
        }
    }
}
