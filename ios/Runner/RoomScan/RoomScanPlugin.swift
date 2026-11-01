import Flutter
import UIKit
import os.log
import RoomPlan

/// Native side of the `andoza/roomscan` MethodChannel.
///
/// Everything RoomPlan-specific lives behind `if #available(iOS 16, *)` and in
/// `RoomScanViewController` (which is `@available(iOS 16.0, *)`), so this file
/// compiles against the app's iOS 13.0 deployment target and the app still
/// launches on iOS 13–15 — the scan methods just report "unsupported".
///
/// Registered from `AppDelegate.didInitializeImplicitFlutterEngine` (the app uses
/// the new implicit-engine + SceneDelegate template, so there is no classic
/// `window.rootViewController` FlutterViewController to attach to at launch).
final class RoomScanPlugin: NSObject {
  static let channelName = "andoza/roomscan"
  private static let log = OSLog(subsystem: "uz.andoza.roomscan", category: "plugin")

  /// Held strongly while a scan is on screen so the VC is not deallocated
  /// mid-capture; released in the completion handler. `AnyObject` avoids naming
  /// the iOS 16-only type outside an availability check.
  private var activeController: AnyObject?
  /// Guards against a second `scanRoom` while one is already presented.
  private var isPresenting = false

  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    let instance = RoomScanPlugin()
    channel.setMethodCallHandler { call, result in
      instance.handle(call, result: result)
    }
    os_log("registered %{public}@ channel", log: log, type: .info, channelName)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isSupported":
      result(Self.isSupportedPayload())
    case "scanRoom":
      scanRoom(arguments: call.arguments, result: result)
    case "scanRooms":
      scanRooms(arguments: call.arguments, result: result)
    case "scanObject":
      scanObject(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// `{supported: Bool, reason: "no_lidar" | "ios_too_old" | null, multiRoom: Bool}`
  /// — `multiRoom`: several rooms in one session, merged by StructureBuilder
  /// (iOS 17+).
  private static func isSupportedPayload() -> [String: Any] {
    if #available(iOS 16, *) {
      if RoomCaptureSession.isSupported {
        var multiRoom = false
        if #available(iOS 17, *) { multiRoom = true }
        os_log("isSupported = true, multiRoom = %{public}@", log: log, type: .info,
               multiRoom ? "true" : "false")
        return ["supported": true, "reason": NSNull(), "multiRoom": multiRoom]
      } else {
        os_log("isSupported = false (no LiDAR)", log: log, type: .info)
        return ["supported": false, "reason": "no_lidar"]
      }
    } else {
      os_log("isSupported = false (iOS < 16)", log: log, type: .info)
      return ["supported": false, "reason": "ios_too_old"]
    }
  }

  /// Several rooms in one session (iOS 17+): `{rooms: [{json, usdzPath}],
  /// version: "roomplan-1", partial: Bool}`, `nil` on cancel.
  private func scanRooms(arguments: Any?, result: @escaping FlutterResult) {
    guard !isPresenting else {
      result(FlutterError(code: "busy", message: "Skaner allaqachon ochiq", details: nil))
      return
    }
    guard #available(iOS 17, *) else {
      result(FlutterError(code: "ios_too_old", message: "Bir nechta xona iOS 17 yoki undan yangi versiyani talab qiladi", details: nil))
      return
    }
    guard RoomCaptureSession.isSupported else {
      result(FlutterError(code: "scan_failed", message: "Qurilma RoomPlan'ni qo'llab-quvvatlamaydi", details: nil))
      return
    }
    guard let host = Self.topViewController() else {
      result(FlutterError(code: "scan_failed", message: "Ekranni topib bo'lmadi", details: nil))
      return
    }

    isPresenting = true
    let controller = MultiRoomScanViewController(labels: RoomScanLabels(arguments)) { [weak self] outcome in
      guard let self = self else { return }
      self.isPresenting = false
      self.activeController = nil
      switch outcome {
      case .success(let payload):
        os_log("scanRooms success", log: Self.log, type: .info)
        result(payload)
      case .cancelled:
        result(nil)
      case .failed(let message):
        os_log("scanRooms failed: %{public}@", log: Self.log, type: .error, message)
        result(FlutterError(code: "scan_failed", message: message, details: nil))
      }
    }
    activeController = controller
    controller.modalPresentationStyle = .fullScreen
    host.present(controller, animated: true)
  }

  private func scanRoom(arguments: Any?, result: @escaping FlutterResult) {
    guard !isPresenting else {
      os_log("scanRoom rejected — a scan is already active", log: Self.log, type: .error)
      result(FlutterError(code: "busy", message: "Skaner allaqachon ochiq", details: nil))
      return
    }

    guard #available(iOS 16, *) else {
      result(FlutterError(code: "scan_failed", message: "RoomPlan iOS 16 yoki undan yangi versiyani talab qiladi", details: nil))
      return
    }

    guard RoomCaptureSession.isSupported else {
      os_log("scanRoom rejected — device unsupported", log: Self.log, type: .error)
      result(FlutterError(code: "scan_failed", message: "Qurilma RoomPlan'ni qo'llab-quvvatlamaydi", details: nil))
      return
    }

    guard let host = Self.topViewController() else {
      os_log("scanRoom rejected — no host view controller", log: Self.log, type: .error)
      result(FlutterError(code: "scan_failed", message: "Ekranni topib bo'lmadi", details: nil))
      return
    }

    isPresenting = true
    let controller = RoomScanViewController(labels: RoomScanLabels(arguments)) { [weak self] outcome in
      guard let self = self else { return }
      self.isPresenting = false
      self.activeController = nil
      switch outcome {
      case .success(let payload):
        os_log("scanRoom success", log: Self.log, type: .info)
        result(payload)
      case .cancelled:
        os_log("scanRoom cancelled by user", log: Self.log, type: .info)
        result(nil)
      case .failed(let message):
        os_log("scanRoom failed: %{public}@", log: Self.log, type: .error, message)
        result(FlutterError(code: "scan_failed", message: message, details: nil))
      }
    }
    activeController = controller
    controller.modalPresentationStyle = .fullScreen
    host.present(controller, animated: true) {
      os_log("presented RoomScanViewController", log: Self.log, type: .info)
    }
  }

  /// Phase 6 — Object Capture (iOS 17+). Presents the guided capture, runs
  /// on-device photogrammetry and returns `{usdzPath: String}` (nil on cancel).
  private func scanObject(result: @escaping FlutterResult) {
    guard !isPresenting else {
      os_log("scanObject rejected — a scan is already active", log: Self.log, type: .error)
      result(FlutterError(code: "busy", message: "Skaner allaqachon ochiq", details: nil))
      return
    }
    guard #available(iOS 17, *) else {
      os_log("scanObject rejected — iOS < 17", log: Self.log, type: .error)
      result(FlutterError(code: "not_implemented", message: "3D buyum skaneri iOS 17 yoki undan yangi versiyani talab qiladi", details: nil))
      return
    }
    guard let host = Self.topViewController() else {
      os_log("scanObject rejected — no host view controller", log: Self.log, type: .error)
      result(FlutterError(code: "scan_failed", message: "Ekranni topib bo'lmadi", details: nil))
      return
    }

    isPresenting = true
    let controller = ObjectScanViewController { [weak self] outcome in
      guard let self = self else { return }
      self.isPresenting = false
      switch outcome {
      case .success(let usdzPath):
        os_log("scanObject success", log: Self.log, type: .info)
        result(["usdzPath": usdzPath])
      case .cancelled:
        os_log("scanObject cancelled by user", log: Self.log, type: .info)
        result(nil)
      case .failed(let message):
        os_log("scanObject failed: %{public}@", log: Self.log, type: .error, message)
        result(FlutterError(code: "scan_failed", message: message, details: nil))
      }
    }
    controller.modalPresentationStyle = .fullScreen
    host.present(controller, animated: true) {
      os_log("presented ObjectScanViewController", log: Self.log, type: .info)
    }
  }

  /// Top-most view controller of the active foreground window scene — the
  /// SceneDelegate template means we can't use `AppDelegate.window`.
  private static func topViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes
    let windowScene = (scenes.first { $0.activationState == .foregroundActive } as? UIWindowScene)
      ?? (scenes.first as? UIWindowScene)
    let window = windowScene?.windows.first { $0.isKeyWindow } ?? windowScene?.windows.first
    var top = window?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }
}
