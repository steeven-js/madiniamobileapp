//
//  SecretsManager.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-30.
//

import Foundation

/// Manages sensitive credentials with basic obfuscation.
/// This provides a layer of protection against casual inspection but is not
/// cryptographically secure against determined reverse engineering.
///
/// For production apps handling sensitive data, consider using a backend proxy
/// that adds API keys server-side.
enum SecretsManager {

    // MARK: - Obfuscated API Key

    /// Salt used for XOR obfuscation - change this to generate new obfuscated keys
    private static let salt: [UInt8] = [0x4D, 0x41, 0x44, 0x49, 0x4E, 0x49, 0x41] // "MADINIA"

    /// Obfuscated API key bytes (XOR encoded with salt)
    /// Generated using the obfuscate() function below
    private static let obfuscatedKey: [UInt8] = [
        0x2B, 0x34, 0x0A, 0x3F, 0x07, 0x19, 0x35, 0x7E, 0x27, 0x74,
        0x3C, 0x29, 0x25, 0x33, 0x1A, 0x11, 0x70, 0x1A, 0x18, 0x7F,
        0x2F, 0x7A, 0x07, 0x17, 0x33, 0x3C, 0x78, 0x17, 0x3A, 0x0D,
        0x2A, 0x08, 0x3E, 0x1A, 0x02, 0x2F, 0x75, 0x0F, 0x23, 0x34,
        0x3B, 0x14, 0x18, 0x32, 0x72, 0x78, 0x7F, 0x22, 0x79, 0x0A,
        0x14, 0x2E, 0x06, 0x08, 0x7E, 0x09, 0x03, 0x11, 0x22, 0x08,
        0x3F, 0x1E, 0x20, 0x34
    ]

    /// Returns the deobfuscated API key
    static var apiKey: String {
        deobfuscate(obfuscatedKey)
    }

    // MARK: - Obfuscation Helpers

    /// Deobfuscates bytes using XOR with the salt
    private static func deobfuscate(_ bytes: [UInt8]) -> String {
        var result = [UInt8]()
        for (index, byte) in bytes.enumerated() {
            result.append(byte ^ salt[index % salt.count])
        }
        return String(bytes: result, encoding: .utf8) ?? ""
    }

    /// Obfuscates a string using XOR with the salt
    /// Use this to generate new obfuscated keys when needed
    /// Call: print(SecretsManager.obfuscate("your-api-key"))
    static func obfuscate(_ string: String) -> [UInt8] {
        let bytes = Array(string.utf8)
        var result = [UInt8]()
        for (index, byte) in bytes.enumerated() {
            result.append(byte ^ salt[index % salt.count])
        }
        return result
    }

    /// Prints the obfuscated bytes as Swift array literal
    /// Useful for generating new keys
    static func printObfuscated(_ string: String) {
        let bytes = obfuscate(string)
        var lines = [String]()
        var currentLine = [String]()

        for (index, byte) in bytes.enumerated() {
            currentLine.append(String(format: "0x%02X", byte))
            if currentLine.count == 10 || index == bytes.count - 1 {
                lines.append(currentLine.joined(separator: ", "))
                currentLine = []
            }
        }

        print("private static let obfuscatedKey: [UInt8] = [")
        for (index, line) in lines.enumerated() {
            let comma = index < lines.count - 1 ? "," : ""
            print("    \(line)\(comma)")
        }
        print("]")
    }
}

// MARK: - Debug Extension

#if DEBUG
extension SecretsManager {
    /// Verifies the obfuscation is working correctly
    static func verify() {
        let key = apiKey
        print("API Key length: \(key.count)")
        print("First 4 chars: \(String(key.prefix(4)))...")
        print("Last 4 chars: ...\(String(key.suffix(4)))")
    }
}
#endif
