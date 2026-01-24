//
//  PermissionPromptView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// A contextual prompt for requesting push notification permission.
/// Shown after a meaningful action (like viewing a formation).
struct PermissionPromptView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pushService = PushNotificationService.shared

    var body: some View {
        VStack(spacing: 24) {
            // Icon
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.accentColor)
                .symbolEffect(.bounce, value: true)

            // Title
            Text("Restez informé")
                .font(.title2)
                .fontWeight(.bold)

            // Description
            Text("Recevez des notifications pour les nouvelles formations et les articles qui pourraient vous intéresser.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Buttons
            VStack(spacing: 12) {
                Button {
                    Task {
                        await pushService.requestPermission()
                        dismiss()
                    }
                } label: {
                    Text("Activer les notifications")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    dismiss()
                } label: {
                    Text("Plus tard")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .presentationDetents([.height(350)])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Previews

#Preview {
    Text("Main Content")
        .sheet(isPresented: .constant(true)) {
            PermissionPromptView()
        }
}
