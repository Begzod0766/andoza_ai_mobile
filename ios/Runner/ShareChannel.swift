import Flutter
import Foundation

/// "Share → Andoza AI" on iOS (andoza/share), the counterpart of Android's
/// ShareChannel.kt: the Share Extension opens `andozaai-share://pin?text=…`
/// and the text goes to Dart (`lib/services/share_intent.dart`).
///
/// A share that starts the app is kept until Dart asks for it with `take`;
/// one that arrives while Dart is listening is sent at once as `shared`.
final class ShareChannel {
  static let shared = ShareChannel()

  private var channel: FlutterMethodChannel?
  private var pending: String?
  private var dartReady = false

  func setup(messenger: FlutterBinaryMessenger) {
    let ch = FlutterMethodChannel(name: "andoza/share", binaryMessenger: messenger)
    ch.setMethodCallHandler { [weak self] call, result in
      guard let self else { return }
      switch call.method {
      case "take":
        self.dartReady = true
        result(self.pending)
        self.pending = nil
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    channel = ch
  }

  /// True when [url] was a share URL (and is now handled).
  @discardableResult
  func receive(_ url: URL) -> Bool {
    guard url.scheme == "andozaai-share" else { return false }
    let text = URLComponents(url: url, resolvingAgainstBaseURL: false)?
      .queryItems?.first { $0.name == "text" }?.value ?? ""
    guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return true }
    if dartReady, let ch = channel {
      ch.invokeMethod("shared", arguments: text)
    } else {
      pending = text
    }
    return true
  }
}
