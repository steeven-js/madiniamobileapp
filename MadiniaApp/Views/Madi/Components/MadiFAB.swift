//
//  MadiFAB.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Floating Action Button for accessing Madi coach.
/// Displays subtly in the bottom-right corner and opens the chat sheet when tapped.
/// Includes a teaser message bubble that appears periodically.
struct MadiFAB: View {
    /// Binding to control the chat sheet presentation
    @Binding var isShowingChat: Bool

    /// Whether the keyboard is currently visible (hides FAB when true)
    @Environment(\.keyboardShowing) private var keyboardShowing

    /// Controls whether the teaser bubble is visible
    @State private var showTeaser = false

    /// Tracks if teaser was dismissed by user
    @AppStorage("madiTeaserDismissedCount") private var teaserDismissedCount: Int = 0

    /// Teaser messages that rotate
    private let teaserMessages = [
        "Besoin d'aide ? 💡",
        "Une question ? Je suis là !",
        "Demandez-moi conseil 🎯",
        "Je peux vous guider ✨"
    ]

    var body: some View {
        HStack(spacing: MadiniaSpacing.sm) {
            // Teaser bubble
            if showTeaser {
                teaserBubble
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
            }

            // FAB Button
            Button {
                dismissTeaser()
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
        }
        .accessibilityLabel("Ouvrir Madi, votre coach IA")
        .accessibilityHint("Appuyez pour discuter avec Madi")
        .opacity(keyboardShowing ? 0 : 1)
        .animation(.easeInOut(duration: 0.2), value: keyboardShowing)
        .onAppear {
            scheduleTeaserAppearance()
        }
        .onChange(of: isShowingChat) { _, isShowing in
            if isShowing {
                dismissTeaser()
            }
        }
    }

    // MARK: - Teaser Bubble

    private var teaserBubble: some View {
        Button {
            dismissTeaser()
            isShowingChat = true
        } label: {
            HStack(spacing: 6) {
                Text(currentTeaserMessage)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 3)
            )
            .overlay(alignment: .trailing) {
                // Triangle pointer
                Triangle()
                    .fill(Color(.systemBackground))
                    .frame(width: 10, height: 8)
                    .rotationEffect(.degrees(-90))
                    .offset(x: 14, y: 0)
            }
        }
        .buttonStyle(.plain)
    }

    private var currentTeaserMessage: String {
        teaserMessages[teaserDismissedCount % teaserMessages.count]
    }

    // MARK: - Teaser Logic

    private func scheduleTeaserAppearance() {
        // Show teaser after 3 seconds, but not if dismissed too many times recently
        guard teaserDismissedCount < 10 else { return }

        Task {
            try? await Task.sleep(for: .seconds(3))
            guard !isShowingChat else { return }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showTeaser = true
            }

            // Auto-dismiss after 8 seconds
            try? await Task.sleep(for: .seconds(8))
            withAnimation(.easeOut(duration: 0.2)) {
                showTeaser = false
            }
        }
    }

    private func dismissTeaser() {
        withAnimation(.easeOut(duration: 0.2)) {
            showTeaser = false
        }
        teaserDismissedCount += 1
    }
}

// MARK: - Triangle Shape

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
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
