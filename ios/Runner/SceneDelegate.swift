import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

  /// Registers the app's own platform channels once the scene's
  /// FlutterViewController exists.
  ///
  /// The LiDAR channel needs a real view controller (it presents the ARKit
  /// scanner modally), so it is wired here rather than in AppDelegate — under
  /// the scene-based lifecycle the FlutterViewController belongs to the scene,
  /// not the app delegate.
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
      LidarMethodChannel.setup(with: controller)
      ShareChannel.shared.setup(messenger: controller.binaryMessenger)
    }
    // Launched by the Share Extension: the share waits for Dart's `take`.
    for context in connectionOptions.urlContexts {
      ShareChannel.shared.receive(context.url)
    }
  }

  /// A URL while the app runs: a share goes to Dart, anything else (Google
  /// sign-in's callback) to Flutter's plugins as before.
  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    let others = URLContexts.filter { !ShareChannel.shared.receive($0.url) }
    if !others.isEmpty {
      super.scene(scene, openURLContexts: others)
    }
  }
}
