//
//  CalendlyView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-02.
//

import SwiftUI
import WebKit

/// View that embeds Calendly for booking appointments.
struct CalendlyView: View {
    /// Whether this view is embedded in another NavigationStack
    var embedded: Bool = false

    /// Calendly URL
    private let calendlyURL = "https://calendly.com/d-brault-madin-ia"

    var body: some View {
        Group {
            if embedded {
                content
            } else {
                NavigationStack {
                    content
                }
            }
        }
    }

    private var content: some View {
        CalendlyWebView(url: calendlyURL)
            .navigationTitle("Prendre RDV")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 100)
            }
    }
}

/// WebView wrapper for Calendly
struct CalendlyWebView: UIViewRepresentable {
    let url: String

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        webView.scrollView.backgroundColor = .systemBackground

        // Load Calendly URL
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed
    }
}

// MARK: - Previews

#Preview {
    CalendlyView()
}
