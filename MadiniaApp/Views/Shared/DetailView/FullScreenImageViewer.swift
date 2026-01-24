//
//  FullScreenImageViewer.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// Full-screen image viewer with zoom and pan gestures.
/// Supports pinch-to-zoom, double-tap zoom, pan when zoomed, and swipe to dismiss.
struct FullScreenImageViewer: View {
    /// The image URL to display
    let imageUrl: String?

    /// Binding to control visibility
    @Binding var isPresented: Bool

    /// Current zoom scale
    @State private var scale: CGFloat = 1.0

    /// Last committed scale (for gesture tracking)
    @State private var lastScale: CGFloat = 1.0

    /// Current offset for panning
    @State private var offset: CGSize = .zero

    /// Last committed offset (for gesture tracking)
    @State private var lastOffset: CGSize = .zero

    /// Drag offset for dismiss gesture
    @State private var dragOffset: CGSize = .zero

    /// Background opacity (dims during drag)
    @State private var backgroundOpacity: Double = 1.0

    /// Minimum zoom scale
    private let minScale: CGFloat = 1.0

    /// Maximum zoom scale
    private let maxScale: CGFloat = 4.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark background
                Color.black
                    .opacity(backgroundOpacity)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismiss()
                    }

                // Image content
                imageContent(in: geometry)
                    .offset(y: dragOffset.height)

                // Close button
                closeButton
            }
        }
        #if os(iOS)
        .statusBarHidden(true)
        #endif
    }

    // MARK: - Image Content

    @ViewBuilder
    private func imageContent(in geometry: GeometryProxy) -> some View {
        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .tint(.white)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(combinedGestures(in: geometry))
                        .onTapGesture(count: 2) {
                            handleDoubleTap(in: geometry)
                        }
                case .failure:
                    placeholderView
                @unknown default:
                    placeholderView
                }
            }
        } else {
            placeholderView
                .scaleEffect(scale)
                .offset(offset)
                .gesture(combinedGestures(in: geometry))
                .onTapGesture(count: 2) {
                    handleDoubleTap(in: geometry)
                }
        }
    }

    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.4, green: 0.5, blue: 0.9),
                        Color(red: 0.6, green: 0.7, blue: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 300, height: 240)
            .overlay {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 100, height: 100)
                        .offset(x: -60, y: -40)

                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 60, height: 60)
                        .offset(x: 80, y: 60)

                    Image(systemName: "book.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
    }

    // MARK: - Close Button

    private var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
                .padding(.trailing, 20)
                .padding(.top, 60)
            }
            Spacer()
        }
    }

    // MARK: - Gestures

    private func combinedGestures(in geometry: GeometryProxy) -> some Gesture {
        SimultaneousGesture(
            magnificationGesture(),
            panGesture(in: geometry)
        )
        .simultaneously(with: dismissDragGesture())
    }

    /// Pinch to zoom gesture
    private func magnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let newScale = lastScale * value
                scale = min(max(newScale, minScale), maxScale)
            }
            .onEnded { _ in
                lastScale = scale
                if scale <= minScale {
                    resetPosition()
                }
            }
    }

    /// Pan gesture when zoomed
    private func panGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale > minScale else { return }
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
                constrainOffset(in: geometry)
            }
    }

    /// Swipe down to dismiss gesture
    private func dismissDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale <= minScale else { return }
                dragOffset = value.translation
                // Fade background as user drags
                let progress = min(abs(value.translation.height) / 300, 1.0)
                backgroundOpacity = 1.0 - (progress * 0.5)
            }
            .onEnded { value in
                guard scale <= minScale else { return }
                // Dismiss if dragged far enough
                if abs(value.translation.height) > 100 || abs(value.predictedEndTranslation.height) > 200 {
                    dismiss()
                } else {
                    withAnimation(.spring(response: 0.3)) {
                        dragOffset = .zero
                        backgroundOpacity = 1.0
                    }
                }
            }
    }

    // MARK: - Actions

    /// Handle double-tap to toggle zoom
    private func handleDoubleTap(in geometry: GeometryProxy) {
        withAnimation(.spring(response: 0.3)) {
            if scale > minScale {
                // Reset to 1x
                scale = minScale
                lastScale = minScale
                offset = .zero
                lastOffset = .zero
            } else {
                // Zoom to 2x
                scale = 2.0
                lastScale = 2.0
            }
        }
    }

    /// Reset position with animation
    private func resetPosition() {
        withAnimation(.spring(response: 0.3)) {
            offset = .zero
            lastOffset = .zero
        }
    }

    /// Constrain offset to keep image in bounds
    private func constrainOffset(in geometry: GeometryProxy) {
        let maxOffset = (scale - 1) * min(geometry.size.width, geometry.size.height) / 2
        withAnimation(.spring(response: 0.3)) {
            offset = CGSize(
                width: min(max(offset.width, -maxOffset), maxOffset),
                height: min(max(offset.height, -maxOffset), maxOffset)
            )
            lastOffset = offset
        }
    }

    /// Dismiss the viewer
    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            isPresented = false
        }
    }
}

// MARK: - Preview

#Preview("With Image URL") {
    FullScreenImageViewer(
        imageUrl: "https://picsum.photos/800/600",
        isPresented: .constant(true)
    )
}

#Preview("Placeholder") {
    FullScreenImageViewer(
        imageUrl: nil,
        isPresented: .constant(true)
    )
}
