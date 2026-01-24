//
//  LoadingState.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import Foundation

/// Generic loading state enum for managing async operations in views.
/// Enables views to handle all states uniformly with a single switch statement.
enum LoadingState<T> {
    /// Initial state before any operation
    case idle

    /// Operation in progress
    case loading

    /// Operation completed successfully with result
    case loaded(T)

    /// Operation failed with error message
    case error(String)

    // MARK: - Convenience Properties

    /// Returns true if currently loading
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    /// Returns the loaded value if available, nil otherwise
    var value: T? {
        if case .loaded(let value) = self { return value }
        return nil
    }

    /// Returns the error message if in error state, nil otherwise
    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }

    /// Returns true if in idle state
    var isIdle: Bool {
        if case .idle = self { return true }
        return false
    }

    /// Returns true if operation completed (loaded or error)
    var isCompleted: Bool {
        switch self {
        case .loaded, .error:
            return true
        case .idle, .loading:
            return false
        }
    }
}

// MARK: - Equatable Conformance (when T is Equatable)

extension LoadingState: Equatable where T: Equatable {
    static func == (lhs: LoadingState<T>, rhs: LoadingState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.loaded(let lhsValue), .loaded(let rhsValue)):
            return lhsValue == rhsValue
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
