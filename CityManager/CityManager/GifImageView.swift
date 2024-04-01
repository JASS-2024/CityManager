import SwiftUI
import WebKit

var talkingName = "talking_avatar_copy_resize"
var notTalkingName = "not_talking_avatar_copy"

struct GifImage: UIViewRepresentable {
    var talking: Bool // No longer a Binding

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        loadGIF(webView: webView)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        loadGIF(webView: webView)
    }
    
    private func loadGIF(webView: WKWebView) {
        let gifName = talking ? talkingName : notTalkingName
        guard let url = Bundle.main.url(forResource: gifName, withExtension: "gif"),
              let data = try? Data(contentsOf: url) else {
            return
        }
        
        webView.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: url.deletingLastPathComponent())
    }
}
