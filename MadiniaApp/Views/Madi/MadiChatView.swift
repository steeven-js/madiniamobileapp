//
//  MadiChatView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Chat interface for interacting with Madi AI coach.
struct MadiChatView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = MadiChatViewModel()

    /// Callback when user taps a formation recommendation
    var onFormationSelected: ((FormationRecommendation) -> Void)?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages list
                messagesView

                Divider()

                // Input area
                inputArea
            }
            .navigationTitle("Madi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            viewModel.resetConversation()
                        } label: {
                            Label("Nouvelle conversation", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .task {
            await viewModel.loadFormations()
        }
    }

    // MARK: - Messages View

    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Coming soon teaser banner
                    comingSoonBanner
                        .id("teaser")

                    ForEach(viewModel.messages) { message in
                        MessageBubble(
                            message: message,
                            onFormationTap: { recommendation in
                                dismiss()
                                onFormationSelected?(recommendation)
                            }
                        )
                        .id(message.id)
                    }

                    // Typing indicator
                    if viewModel.isTyping {
                        TypingIndicator()
                            .id("typing")
                    }
                }
                .padding()
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: viewModel.isTyping) { _, _ in
                scrollToBottom(proxy: proxy)
            }
        }
    }

    // MARK: - Coming Soon Banner

    private var comingSoonBanner: some View {
        VStack(spacing: 12) {
            // Animated sparkles icon
            Image(systemName: "wand.and.stars")
                .font(.system(size: 32))
                .foregroundStyle(
                    LinearGradient(
                        colors: [MadiniaColors.accent, MadiniaColors.violet],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.pulse.byLayer, options: .repeating)

            VStack(spacing: 6) {
                Text("Madi arrive bientôt !")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("Je suis en cours de développement pour devenir votre assistant IA personnalisé. Revenez vite pour découvrir toutes mes fonctionnalités !")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Feature pills
            HStack(spacing: 8) {
                featurePill(icon: "brain.head.profile", text: "IA avancée")
                featurePill(icon: "message.fill", text: "Chat intelligent")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [MadiniaColors.accent.opacity(0.5), MadiniaColors.violet.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .padding(.bottom, 8)
    }

    private func featurePill(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .foregroundStyle(MadiniaColors.violet)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(MadiniaColors.violet.opacity(0.15))
        .clipShape(Capsule())
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.3)) {
            if viewModel.isTyping {
                proxy.scrollTo("typing", anchor: .bottom)
            } else if let lastMessage = viewModel.messages.last {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }

    // MARK: - Input Area

    private var inputArea: some View {
        HStack(spacing: 12) {
            TextField("Posez votre question...", text: $viewModel.inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...4)
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))

            Button {
                Task {
                    await viewModel.sendMessage()
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title)
                    .foregroundStyle(viewModel.canSend ? Color.accentColor : .secondary)
            }
            .disabled(!viewModel.canSend)
            .accessibilityLabel("Envoyer")
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Message Bubble

private struct MessageBubble: View {
    let message: MadiMessage
    var onFormationTap: ((FormationRecommendation) -> Void)?

    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer(minLength: 60)
            }

            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 8) {
                // Message content
                Text(LocalizedStringKey(message.content))
                    .padding(12)
                    .background(message.isFromUser ? Color.accentColor : Color(.secondarySystemBackground))
                    .foregroundStyle(message.isFromUser ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                // Formation recommendation card
                if let recommendation = message.formationRecommendation {
                    Button {
                        onFormationTap?(recommendation)
                    } label: {
                        HStack {
                            Image(systemName: "book.fill")
                                .foregroundStyle(Color.accentColor)

                            Text(recommendation.formationTitle)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(12)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .accessibilityLabel("Voir la formation \(recommendation.formationTitle)")
                }
            }

            if !message.isFromUser {
                Spacer(minLength: 60)
            }
        }
    }
}

// MARK: - Typing Indicator

private struct TypingIndicator: View {
    @State private var animating = false

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animating ? 1.0 : 0.5)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                            value: animating
                        )
                }
            }
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer()
        }
        .onAppear {
            animating = true
        }
    }
}

// MARK: - Previews

#Preview("Madi Chat") {
    MadiChatView()
}

#Preview("With Messages") {
    struct PreviewWrapper: View {
        @State var viewModel = MadiChatViewModel()

        var body: some View {
            MadiChatView()
        }
    }
    return PreviewWrapper()
}
