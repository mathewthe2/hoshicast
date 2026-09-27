import SwiftUI
import WebKit

struct ExtensionHTMLView: NSViewRepresentable {
    let html: String
    let css: String?
    let baseURL: URL?

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView(
            frame: .zero,
            configuration: WKWebViewConfiguration()
        )

        webView.navigationDelegate = context.coordinator

        // Transparent WebKit background so the dictionary integrates
        // with Tinycast's appearance.
        webView.setValue(
            false,
            forKey: "drawsBackground"
        )

        // WKWebView owns scrolling for HTML content.
        webView.enclosingScrollView?.hasVerticalScroller = true
        webView.enclosingScrollView?.hasHorizontalScroller = false

        context.coordinator.lastSignature =
            html + "\n---CSS---\n" + (css ?? "")

        load(
            html: html,
            css: css,
            into: webView
        )

        return webView
    }

    func updateNSView(
        _ webView: WKWebView,
        context: Context
    ) {
        let signature =
            html + "\n---CSS---\n" + (css ?? "")

        guard context.coordinator.lastSignature != signature else {
            return
        }

        context.coordinator.lastSignature = signature

        load(
            html: html,
            css: css,
            into: webView
        )
    }

    private func load(
        html: String,
        css: String?,
        into webView: WKWebView
    ) {
        let document = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">

            <meta
                name="viewport"
                content="width=device-width, initial-scale=1.0"
            >

            <meta
                name="color-scheme"
                content="light dark"
            >

            <style>
                :root {
                    color-scheme: light dark;
                }

                html,
                body {
                    margin: 0;
                    padding: 0;
                    background: transparent;
                }

                body {
                    color: CanvasText;
                    background: Canvas;
                    font-family:
                        -apple-system,
                        BlinkMacSystemFont,
                        sans-serif;
                    font-size: 16px;
                    line-height: 1.6;
                    overflow-x: hidden;
                }

                \(css ?? "")
            </style>
        </head>

        <body>
            \(html)
        </body>
        </html>
        """

        webView.loadHTMLString(
            document,
            baseURL: baseURL
        )
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var lastSignature: String?
    }
}
