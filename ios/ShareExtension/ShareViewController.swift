import UIKit
import UniformTypeIdentifiers

/// "Share → Andoza AI" on iOS, for a pin from the Pinterest app.
///
/// It shows nothing of its own: it reads the shared link/text and hands it to
/// the app as `andozaai-share://pin?text=…`. The app (SceneDelegate →
/// ShareChannel) passes the text to Dart, which picks the room and opens the
/// Studio's AI designer with the pin — the same path as Android's share
/// intent. The text travels in the URL, so no App Group is needed.
final class ShareViewController: UIViewController {

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    Task { @MainActor in
      let text = await sharedText()
      if !text.isEmpty, let url = Self.appURL(for: text) {
        openInApp(url)
      }
      extensionContext?.completeRequest(returningItems: nil)
    }
  }

  /// `andozaai-share://pin?text=<text>`.
  static func appURL(for text: String) -> URL? {
    var c = URLComponents()
    c.scheme = "andozaai-share"
    c.host = "pin"
    c.queryItems = [URLQueryItem(name: "text", value: text)]
    return c.url
  }

  /// Every link and every piece of text shared, joined: Dart finds the pin
  /// link in it (`findPinUrl`).
  private func sharedText() async -> String {
    var parts: [String] = []
    let items = extensionContext?.inputItems as? [NSExtensionItem] ?? []
    for item in items {
      if let body = item.attributedContentText?.string, !body.isEmpty {
        parts.append(body)
      }
      for provider in item.attachments ?? [] {
        if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier),
           let url = try? await provider.loadItem(forTypeIdentifier: UTType.url.identifier) as? URL {
          parts.append(url.absoluteString)
        } else if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier),
                  let text = try? await provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) as? String {
          parts.append(text)
        }
      }
    }
    return parts.joined(separator: " ")
  }

  /// An extension cannot call UIApplication.shared; the app object is found
  /// through the responder chain and `open(_:options:completionHandler:)` is
  /// called by selector (the older `openURL:` stopped working in iOS 18).
  private func openInApp(_ url: URL) {
    let selector = NSSelectorFromString("openURL:options:completionHandler:")
    var responder: UIResponder? = self
    while let current = responder {
      if current is UIApplication, current.responds(to: selector) {
        typealias Open = @convention(c) (NSObject, Selector, NSURL, NSDictionary, UnsafeRawPointer?) -> Void
        let open = unsafeBitCast(current.method(for: selector), to: Open.self)
        open(current, selector, url as NSURL, NSDictionary(), nil)
        return
      }
      responder = current.next
    }
  }
}
