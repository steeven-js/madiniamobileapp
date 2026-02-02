//
//  ArticleDetailView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

/// Detail view for reading a full blog article.
struct ArticleDetailView: View {
    /// The article to display (from list, may not have full content)
    let article: Article

    /// ViewModel for loading full article and managing like state
    @State private var viewModel: ArticleDetailViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.navigationContext) private var navigationContext

    init(article: Article) {
        self.article = article
        self._viewModel = State(initialValue: ArticleDetailViewModel(article: article))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero Section
                    heroSection

                    // Content Section
                    VStack(alignment: .leading, spacing: MadiniaSpacing.md) {
                        // Title
                        Text(viewModel.displayArticle.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.primary)

                        // Meta info row
                        metaInfoRow

                        // Author section
                        if let author = viewModel.displayArticle.author {
                            authorSection(author: author)
                        }

                        // Tags
                        if let tags = viewModel.displayArticle.tags, !tags.isEmpty {
                            tagsSection(tags: tags)
                        }

                        Divider()
                            .padding(.vertical, MadiniaSpacing.sm)

                        // Article content
                        articleContent
                    }
                    .padding(MadiniaSpacing.md)
                    .padding(.bottom, 120)
                }
            }
            .ignoresSafeArea(edges: .top)

            // Bottom action bar
            bottomActionBar
        }
        .navigationBarHidden(true)
        .background(Color(.systemBackground))
        .task {
            await viewModel.loadFullArticle()
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(red: 0.15, green: 0.15, blue: 0.2)

                // Image
                if let imageUrl = viewModel.displayArticle.heroUrl ?? viewModel.displayArticle.coverUrl,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: 300)
                                .clipped()
                        case .failure, .empty:
                            placeholderImage
                        @unknown default:
                            placeholderImage
                        }
                    }
                } else {
                    placeholderImage
                }

                // Gradient overlay
                LinearGradient(
                    colors: [.clear, Color(red: 0.15, green: 0.15, blue: 0.2).opacity(0.8)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                // Back button
                VStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        Spacer()

                        // Share button
                        ShareLink(item: shareURL) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, MadiniaSpacing.md)
                    .padding(.top, 50)
                    Spacer()
                }

                // Category badge at bottom
                VStack {
                    Spacer()
                    HStack {
                        if let category = viewModel.displayArticle.category {
                            Text(category)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(MadiniaColors.accent)
                                .clipShape(Capsule())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, MadiniaSpacing.md)
                    .padding(.bottom, MadiniaSpacing.md)
                }
            }
        }
        .frame(height: 300)
    }

    private var placeholderImage: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.5, blue: 0.9),
                    Color(red: 0.6, green: 0.7, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: "newspaper.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    // MARK: - Meta Info Row

    private var metaInfoRow: some View {
        HStack(spacing: MadiniaSpacing.md) {
            // Reading time
            if let readingTime = viewModel.displayArticle.readingTime {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text(readingTime)
                        .font(.system(size: 13))
                }
                .foregroundStyle(.secondary)
            }

            // Views count
            if let views = viewModel.displayArticle.viewsCount, views > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "eye")
                        .font(.system(size: 12))
                    Text("\(views)")
                        .font(.system(size: 13))
                }
                .foregroundStyle(.secondary)
            }

            // Likes count
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 12))
                Text("\(viewModel.likesCount)")
                    .font(.system(size: 13))
            }
            .foregroundStyle(MadiniaColors.accent)

            Spacer()

            // Published date
            if let publishedAt = viewModel.displayArticle.publishedAt {
                Text(formattedDate(publishedAt))
                    .font(.system(size: 13))
                    .foregroundStyle(.tertiary)
            }
        }
    }

    // MARK: - Author Section

    private func authorSection(author: ArticleAuthor) -> some View {
        HStack(spacing: MadiniaSpacing.sm) {
            // Avatar
            if let avatarUrl = author.avatarUrl, let url = URL(string: avatarUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                    default:
                        authorPlaceholder
                    }
                }
            } else {
                authorPlaceholder
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(author.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)

                if let role = author.role {
                    Text(role)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(MadiniaSpacing.sm)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
    }

    private var authorPlaceholder: some View {
        Circle()
            .fill(MadiniaColors.accent.opacity(0.2))
            .frame(width: 44, height: 44)
            .overlay {
                Image(systemName: "person.fill")
                    .foregroundStyle(MadiniaColors.accent)
            }
    }

    // MARK: - Tags Section

    private func tagsSection(tags: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MadiniaSpacing.xs) {
                ForEach(tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(MadiniaColors.violet)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(MadiniaColors.violet.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Article Content

    @ViewBuilder
    private var articleContent: some View {
        switch viewModel.loadingState {
        case .loading:
            HStack {
                Spacer()
                ProgressView()
                    .padding()
                Spacer()
            }

        case .error:
            // Show description as fallback when content fails to load
            if let description = viewModel.displayArticle.description {
                VStack(alignment: .leading, spacing: MadiniaSpacing.md) {
                    Text(description)
                        .font(.system(size: 16))
                        .foregroundStyle(.primary)
                        .lineSpacing(6)

                    // Subtle error indicator with retry
                    HStack(spacing: MadiniaSpacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Text("Contenu complet non disponible")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Réessayer") {
                            Task { await viewModel.loadFullArticle() }
                        }
                        .font(.caption)
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding(MadiniaSpacing.sm)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.sm))
                }
            } else {
                // No description available - show error
                VStack(spacing: MadiniaSpacing.md) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("Impossible de charger l'article")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Réessayer") {
                        Task { await viewModel.loadFullArticle() }
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }

        case .loaded, .idle:
            if let content = viewModel.displayArticle.content {
                HTMLTextView(html: content)
            } else if let description = viewModel.displayArticle.description {
                Text(description)
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)
                    .lineSpacing(6)
            }
        }
    }

    // MARK: - Bottom Action Bar

    private var bottomActionBar: some View {
        HStack(spacing: MadiniaSpacing.md) {
            // Like button
            Button {
                Task { await viewModel.toggleLike() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 18))
                    Text(viewModel.isLiked ? "Aimé" : "J'aime")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(viewModel.isLiked ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(viewModel.isLiked ? MadiniaColors.accent : Color(.secondarySystemBackground))
                .clipShape(Capsule())
            }
            .disabled(viewModel.isLiking)

            Spacer()

            // Contact button
            Button {
                navigationContext.triggerContactNavigation()
            } label: {
                Text("Nous contacter")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(MadiniaColors.darkGrayFixed)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(MadiniaColors.accent)
                    .clipShape(Capsule())
            }
        }
        .padding(.leading, MadiniaSpacing.md)
        .padding(.trailing, 88) // Leave space for Madi FAB
        .padding(.vertical, MadiniaSpacing.sm)
        .padding(.bottom, 80)
        .background(
            LinearGradient(
                colors: [Color(.systemBackground).opacity(0), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        )
    }

    // MARK: - Helpers

    private var shareURL: URL {
        URL(string: "https://madinia.fr/blog/posts/\(article.slug)") ??
        URL(string: "https://madinia.fr")!
    }

    private func formattedDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: isoString) else {
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: isoString) else {
                return ""
            }
            return formatRelativeDate(date)
        }

        return formatRelativeDate(date)
    }

    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Article Detail ViewModel

@Observable
final class ArticleDetailViewModel {
    private(set) var loadingState: LoadingState<Article> = .idle
    private(set) var isLiked: Bool = false
    private(set) var isLiking: Bool = false
    private(set) var likesCount: Int = 0

    private let initialArticle: Article
    private var fullArticle: Article?
    private let apiService: APIServiceProtocol

    /// Returns full article if loaded, otherwise initial article
    var displayArticle: Article {
        fullArticle ?? initialArticle
    }

    init(article: Article, apiService: APIServiceProtocol = APIService.shared) {
        self.initialArticle = article
        self.apiService = apiService
        self.likesCount = article.likesCount ?? 0
        self.isLiked = LikedArticlesService.shared.isLiked(articleId: article.id)
    }

    @MainActor
    func loadFullArticle() async {
        guard loadingState != .loading else { return }

        // If we already have content, no need to reload
        if initialArticle.content != nil {
            fullArticle = initialArticle
            loadingState = .loaded(initialArticle)
            return
        }

        loadingState = .loading

        do {
            let article = try await apiService.fetchArticle(slug: initialArticle.slug)
            fullArticle = article
            likesCount = article.likesCount ?? likesCount
            loadingState = .loaded(article)
        } catch let error as APIError {
            loadingState = .error(error.errorDescription ?? "Erreur de chargement")
        } catch {
            loadingState = .error("Erreur de chargement de l'article")
        }
    }

    @MainActor
    func toggleLike() async {
        guard !isLiking else { return }

        isLiking = true
        let wasLiked = isLiked

        // Optimistic update
        isLiked.toggle()
        likesCount += isLiked ? 1 : -1

        do {
            if isLiked {
                try await apiService.likeArticle(slug: initialArticle.slug)
                LikedArticlesService.shared.markAsLiked(articleId: initialArticle.id)
            } else {
                try await apiService.unlikeArticle(slug: initialArticle.slug)
                LikedArticlesService.shared.markAsUnliked(articleId: initialArticle.id)
            }
        } catch {
            // Rollback on error
            isLiked = wasLiked
            likesCount += wasLiked ? 1 : -1
        }

        isLiking = false
    }
}

// MARK: - Liked Articles Service

/// Service to track which articles the user has liked locally
final class LikedArticlesService {
    static let shared = LikedArticlesService()

    private let userDefaults = UserDefaults.standard
    private let key = "likedArticleIds"

    private init() {}

    func isLiked(articleId: Int) -> Bool {
        let likedIds = userDefaults.array(forKey: key) as? [Int] ?? []
        return likedIds.contains(articleId)
    }

    func markAsLiked(articleId: Int) {
        var likedIds = userDefaults.array(forKey: key) as? [Int] ?? []
        if !likedIds.contains(articleId) {
            likedIds.append(articleId)
            userDefaults.set(likedIds, forKey: key)
        }
    }

    func markAsUnliked(articleId: Int) {
        var likedIds = userDefaults.array(forKey: key) as? [Int] ?? []
        likedIds.removeAll { $0 == articleId }
        userDefaults.set(likedIds, forKey: key)
    }
}

// MARK: - Rich HTML Content View

/// Renders HTML content with proper formatting and inline images
struct HTMLTextView: View {
    let html: String

    var body: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.md) {
            ForEach(Array(parseHTMLElements().enumerated()), id: \.offset) { _, element in
                renderElement(element)
            }
        }
    }

    // MARK: - HTML Element Types

    private enum HTMLElement {
        case paragraph(AttributedString)
        case heading(level: Int, text: String)
        case image(url: String)
    }

    // MARK: - Parsing

    private func parseHTMLElements() -> [HTMLElement] {
        var elements: [HTMLElement] = []
        let content = html

        // Split by major block elements
        let blockPattern = "(<h[1-6][^>]*>.*?</h[1-6]>|<p[^>]*>.*?</p>|<img[^>]*>)"

        guard let regex = try? NSRegularExpression(pattern: blockPattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) else {
            // Fallback: return as single paragraph
            return [.paragraph(AttributedString(stripAllHTML(from: content)))]
        }

        let nsRange = NSRange(content.startIndex..., in: content)
        let matches = regex.matches(in: content, options: [], range: nsRange)

        for match in matches {
            guard let range = Range(match.range, in: content) else { continue }
            let block = String(content[range])

            if let element = parseBlock(block) {
                elements.append(element)
            }
        }

        return elements
    }

    private func parseBlock(_ block: String) -> HTMLElement? {
        let trimmed = block.trimmingCharacters(in: .whitespacesAndNewlines)

        // Check for image
        if trimmed.lowercased().contains("<img") {
            if let url = extractImageURL(from: trimmed) {
                return .image(url: url)
            }
            return nil
        }

        // Check for headings
        for level in 1...6 {
            let openTag = "<h\(level)"
            let closeTag = "</h\(level)>"
            if trimmed.lowercased().contains(openTag) && trimmed.lowercased().contains(closeTag) {
                let text = stripAllHTML(from: trimmed)
                if !text.isEmpty {
                    return .heading(level: level, text: text)
                }
                return nil
            }
        }

        // Default to paragraph - check for links
        if trimmed.lowercased().contains("<a ") {
            let attributed = parseTextWithLinks(from: trimmed)
            if !attributed.characters.isEmpty {
                return .paragraph(attributed)
            }
            return nil
        }

        // Plain paragraph
        let text = stripAllHTML(from: trimmed)
        if !text.isEmpty {
            return .paragraph(AttributedString(text))
        }
        return nil
    }

    private func parseTextWithLinks(from html: String) -> AttributedString {
        var result = AttributedString()

        // Pattern to find links
        let linkPattern = #"<a[^>]+href\s*=\s*["']([^"']+)["'][^>]*>(.*?)</a>"#
        guard let regex = try? NSRegularExpression(pattern: linkPattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) else {
            return AttributedString(stripAllHTML(from: html))
        }

        var lastIndex = html.startIndex
        let nsRange = NSRange(html.startIndex..., in: html)
        let matches = regex.matches(in: html, options: [], range: nsRange)

        for match in matches {
            guard let fullRange = Range(match.range, in: html),
                  let urlRange = Range(match.range(at: 1), in: html),
                  let textRange = Range(match.range(at: 2), in: html) else {
                continue
            }

            // Add text before the link
            if lastIndex < fullRange.lowerBound {
                let beforeText = String(html[lastIndex..<fullRange.lowerBound])
                let cleanedBefore = stripAllHTML(from: beforeText)
                if !cleanedBefore.isEmpty {
                    result.append(AttributedString(cleanedBefore))
                }
            }

            // Add the link
            let urlString = String(html[urlRange])
            let linkText = stripAllHTML(from: String(html[textRange]))

            if let url = URL(string: urlString), !linkText.isEmpty {
                var linkAttr = AttributedString(linkText)
                linkAttr.link = url
                linkAttr.foregroundColor = UIColor(MadiniaColors.accent)
                linkAttr.underlineStyle = .single
                result.append(linkAttr)
            }

            lastIndex = fullRange.upperBound
        }

        // Add remaining text after the last link
        if lastIndex < html.endIndex {
            let afterText = String(html[lastIndex...])
            let cleanedAfter = stripAllHTML(from: afterText)
            if !cleanedAfter.isEmpty {
                result.append(AttributedString(cleanedAfter))
            }
        }

        return result
    }

    private func extractImageURL(from html: String) -> String? {
        // Pattern to match src attribute in img tag
        let pattern = #"<img[^>]+src\s*=\s*["']([^"']+)["']"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }

        let nsRange = NSRange(html.startIndex..., in: html)
        guard let match = regex.firstMatch(in: html, options: [], range: nsRange),
              let urlRange = Range(match.range(at: 1), in: html) else {
            return nil
        }

        return String(html[urlRange])
    }

    private func stripAllHTML(from content: String) -> String {
        var result = content

        // Decode HTML entities first
        let entities: [(String, String)] = [
            ("&nbsp;", " "),
            ("&amp;", "&"),
            ("&lt;", "<"),
            ("&gt;", ">"),
            ("&quot;", "\""),
            ("&#039;", "'"),
            ("&apos;", "'"),
            ("&ndash;", "–"),
            ("&mdash;", "—"),
            ("&rsquo;", "\u{2019}"),
            ("&lsquo;", "\u{2018}"),
            ("&rdquo;", "\u{201D}"),
            ("&ldquo;", "\u{201C}"),
            ("&hellip;", "\u{2026}")
        ]

        for (entity, replacement) in entities {
            result = result.replacingOccurrences(of: entity, with: replacement)
        }

        // Remove all HTML tags
        if let regex = try? NSRegularExpression(pattern: "<[^>]+>", options: .caseInsensitive) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "")
        }

        // Clean up whitespace
        result = result.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Rendering

    @ViewBuilder
    private func renderElement(_ element: HTMLElement) -> some View {
        switch element {
        case .paragraph(let attributedText):
            Text(attributedText)
                .font(.system(size: 16))
                .foregroundStyle(.primary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
                .environment(\.openURL, OpenURLAction { url in
                    UIApplication.shared.open(url)
                    return .handled
                })

        case .heading(let level, let text):
            Text(text)
                .font(.system(size: headingSize(for: level), weight: .bold))
                .foregroundStyle(.primary)
                .padding(.top, MadiniaSpacing.sm)

        case .image(let url):
            if let imageURL = URL(string: url) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: MadiniaRadius.md))
                    case .failure:
                        imagePlaceholder
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                    @unknown default:
                        imagePlaceholder
                    }
                }
                .padding(.vertical, MadiniaSpacing.sm)
            }
        }
    }

    private func headingSize(for level: Int) -> CGFloat {
        switch level {
        case 1: return 24
        case 2: return 22
        case 3: return 20
        case 4: return 18
        case 5: return 16
        default: return 16
        }
    }

    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: MadiniaRadius.md)
            .fill(Color(.secondarySystemBackground))
            .frame(height: 150)
            .overlay {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
    }
}

// MARK: - Previews

#Preview("Article Detail") {
    NavigationStack {
        ArticleDetailView(article: Article.sample)
    }
}
