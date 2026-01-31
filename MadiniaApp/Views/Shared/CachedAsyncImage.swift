//
//  CachedAsyncImage.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-30.
//

import SwiftUI

/// A cached version of AsyncImage that stores images in memory and on disk.
/// Shows a shimmer placeholder while loading for better UX.
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    // MARK: - Properties

    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    @State private var loadedImage: UIImage?
    @State private var isLoading = true

    // MARK: - Initialization

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let image = loadedImage {
                content(Image(uiImage: image))
                    .transition(.opacity.animation(.easeIn(duration: 0.2)))
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            await loadImage()
        }
    }

    // MARK: - Image Loading

    private func loadImage() async {
        guard let url = url else {
            isLoading = false
            return
        }

        // Check memory cache first
        if let cached = ImageCache.shared.image(for: url) {
            loadedImage = cached
            isLoading = false
            return
        }

        // Check disk cache
        if let diskCached = ImageCache.shared.loadFromDisk(url: url) {
            ImageCache.shared.setImage(diskCached, for: url)
            loadedImage = diskCached
            isLoading = false
            return
        }

        // Download from network
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                // Cache in memory and disk
                ImageCache.shared.setImage(image, for: url)
                ImageCache.shared.saveToDisk(image, url: url)

                await MainActor.run {
                    loadedImage = image
                    isLoading = false
                }
            }
        } catch {
            #if DEBUG
            print("CachedAsyncImage: Failed to load \(url) - \(error)")
            #endif
            isLoading = false
        }
    }
}

// MARK: - Convenience Initializer with Default Placeholder

extension CachedAsyncImage where Placeholder == ShimmerPlaceholder {
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.init(url: url, content: content) {
            ShimmerPlaceholder()
        }
    }
}

// MARK: - Image Cache

/// Thread-safe image cache with memory and disk storage.
final class ImageCache: @unchecked Sendable {
    static let shared = ImageCache()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let lock = NSLock()

    private init() {
        // Set up cache directory
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache", isDirectory: true)

        // Create directory if needed
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

        // Configure memory cache
        memoryCache.countLimit = 100 // Max 100 images in memory
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }

    // MARK: - Memory Cache

    func image(for url: URL) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }
        return memoryCache.object(forKey: cacheKey(for: url))
    }

    func setImage(_ image: UIImage, for url: URL) {
        lock.lock()
        defer { lock.unlock() }
        let cost = image.jpegData(compressionQuality: 1.0)?.count ?? 0
        memoryCache.setObject(image, forKey: cacheKey(for: url), cost: cost)
    }

    // MARK: - Disk Cache

    func loadFromDisk(url: URL) -> UIImage? {
        let filePath = diskPath(for: url)
        guard fileManager.fileExists(atPath: filePath.path) else { return nil }

        // Check if cache is still valid (7 days)
        if let attributes = try? fileManager.attributesOfItem(atPath: filePath.path),
           let modDate = attributes[.modificationDate] as? Date,
           Date().timeIntervalSince(modDate) > 7 * 24 * 60 * 60 {
            try? fileManager.removeItem(at: filePath)
            return nil
        }

        return UIImage(contentsOfFile: filePath.path)
    }

    func saveToDisk(_ image: UIImage, url: URL) {
        let filePath = diskPath(for: url)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: filePath)
        }
    }

    // MARK: - Helpers

    private func cacheKey(for url: URL) -> NSString {
        url.absoluteString as NSString
    }

    private func diskPath(for url: URL) -> URL {
        let fileName = url.absoluteString.data(using: .utf8)?.base64EncodedString() ?? UUID().uuidString
        return cacheDirectory.appendingPathComponent(fileName)
    }

    /// Clears all cached images (memory and disk)
    func clearAll() {
        lock.lock()
        memoryCache.removeAllObjects()
        lock.unlock()

        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}

// MARK: - Shimmer Placeholder

/// Animated shimmer placeholder shown while images load.
struct ShimmerPlaceholder: View {
    @State private var isAnimating = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base gradient background
                LinearGradient(
                    colors: [
                        Color(.systemGray5),
                        Color(.systemGray6),
                        Color(.systemGray5)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )

                // Shimmer effect
                LinearGradient(
                    colors: [
                        .clear,
                        Color.white.opacity(0.4),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: geometry.size.width * 0.6)
                .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
            }
        }
        .onAppear {
            withAnimation(
                .linear(duration: 1.2)
                .repeatForever(autoreverses: false)
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Color Placeholder (Alternative)

/// Simple color placeholder with icon.
struct ColorPlaceholder: View {
    var color: Color = Color(.systemGray5)
    var icon: String = "photo"

    var body: some View {
        ZStack {
            color
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color(.systemGray3))
        }
    }
}

// MARK: - Previews

#Preview("Shimmer") {
    ShimmerPlaceholder()
        .frame(width: 200, height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 12))
}

#Preview("Color Placeholder") {
    ColorPlaceholder()
        .frame(width: 200, height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 12))
}

#Preview("Cached Image") {
    CachedAsyncImage(
        url: URL(string: "https://picsum.photos/400/300")
    ) { image in
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
    .frame(width: 200, height: 150)
    .clipShape(RoundedRectangle(cornerRadius: 12))
}
