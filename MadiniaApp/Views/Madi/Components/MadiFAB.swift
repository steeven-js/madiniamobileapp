//
//  MadiFAB.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Floating Action Button for accessing Madi coach.
/// Displays subtly in the bottom-right corner and opens the chat sheet when tapped.
struct MadiFAB: View {
    /// Binding to control the chat sheet presentation
    @Binding var isShowingChat: Bool

    /// Whether the keyboard is currently visible (hides FAB when true)
    @Environment(\.keyboardShowing) private var keyboardShowing

    var body: some View {
        Button {
            isShowingChat = true
        } label: {
            ZStack {
                Circle()
                    .fill(MadiniaColors.gold)
                    .frame(width: 56, height: 56)
                    .shadow(color: MadiniaColors.violet.opacity(0.3), radius: 8, x: 0, y: 4)

                Image(systemName: "sparkles")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(MadiniaColors.darkGray)
            }
        }
        .accessibilityLabel("Ouvrir Madi, votre coach IA")
        .accessibilityHint("Appuyez pour discuter avec Madi")
        .opacity(keyboardShowing ? 0 : 1)
        .animation(.easeInOut(duration: 0.2), value: keyboardShowing)
    }
}

// MARK: - Keyboard Visibility Environment Key

private struct KeyboardShowingKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var keyboardShowing: Bool {
        get { self[KeyboardShowingKey.self] }
        set { self[KeyboardShowingKey.self] = newValue }
    }
}

// MARK: - Keyboard Observer Modifier

struct KeyboardObserver: ViewModifier {
    @State private var keyboardShowing = false

    func body(content: Content) -> some View {
        content
            .environment(\.keyboardShowing, keyboardShowing)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                keyboardShowing = true
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                keyboardShowing = false
            }
    }
}

extension View {
    func observeKeyboard() -> some View {
        modifier(KeyboardObserver())
    }
}

// MARK: - Previews

#Preview {
    ZStack {
        Color(.systemBackground)
            .ignoresSafeArea()

        VStack {
            Spacer()
            HStack {
                Spacer()
                MadiFAB(isShowingChat: .constant(false))
                    .padding()
            }
        }
    }
}
