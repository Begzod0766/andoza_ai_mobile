import UIKit
import os.log

#if canImport(RoomPlan)
import RoomPlan
#endif

/// Result of a room scan, handed back to `RoomScanPlugin` (which maps it onto the
/// FlutterResult). Not availability-gated so the plugin can hold it on any iOS.
enum RoomScanOutcome {
  /// `{json: String, usdzPath: String, version: "roomplan-1"}`
  case success([String: Any])
  case cancelled
  case failed(String)
}

@available(iOS 16.0, *)
final class RoomScanViewController: UIViewController {
  private static let log = OSLog(subsystem: "uz.andoza.roomscan", category: "viewcontroller")

  private let completion: (RoomScanOutcome) -> Void
  private let labels: RoomScanLabels
  private var roomCaptureView: RoomCaptureView!
  private let captureConfig = RoomCaptureSession.Configuration()
  private var didFinish = false
  private var didStop = false

  private let hintLabel = UILabel()

  init(labels: RoomScanLabels, completion: @escaping (RoomScanOutcome) -> Void) {
    self.labels = labels
    self.completion = completion
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    setUpCaptureView()
    setUpChrome()
    NotificationCenter.default.addObserver(
      self, selector: #selector(appDidEnterBackground),
      name: UIApplication.didEnterBackgroundNotification, object: nil)
    os_log("viewDidLoad", log: Self.log, type: .info)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    startSession()
  }

  private func setUpCaptureView() {
    roomCaptureView = RoomCaptureView(frame: view.bounds)
    roomCaptureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    roomCaptureView.delegate = self
    roomCaptureView.captureSession.delegate = self
    view.addSubview(roomCaptureView)
  }

  private func setUpChrome() {
    // Top bar: cancel (left) / done (right).
    let topBar = UIView()
    topBar.translatesAutoresizingMaskIntoConstraints = false
    topBar.backgroundColor = UIColor.black.withAlphaComponent(0.35)
    view.addSubview(topBar)

    let cancelButton = UIButton(type: .system)
    cancelButton.setTitle(labels.cancel, for: .normal)
    cancelButton.setTitleColor(.white, for: .normal)
    cancelButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
    cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    cancelButton.translatesAutoresizingMaskIntoConstraints = false

    let doneButton = UIButton(type: .system)
    doneButton.setTitle(labels.done, for: .normal)
    doneButton.setTitleColor(.white, for: .normal)
    doneButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
    doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
    doneButton.translatesAutoresizingMaskIntoConstraints = false

    topBar.addSubview(cancelButton)
    topBar.addSubview(doneButton)

    // Bottom hint driven by the capture session's instructions.
    hintLabel.translatesAutoresizingMaskIntoConstraints = false
    hintLabel.textColor = .white
    hintLabel.font = .systemFont(ofSize: 16, weight: .semibold)
    hintLabel.textAlignment = .center
    hintLabel.numberOfLines = 2
    hintLabel.text = labels.start
    hintLabel.backgroundColor = UIColor.black.withAlphaComponent(0.35)
    hintLabel.layer.cornerRadius = 12
    hintLabel.layer.masksToBounds = true
    view.addSubview(hintLabel)

    let guide = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      topBar.topAnchor.constraint(equalTo: view.topAnchor),
      topBar.bottomAnchor.constraint(equalTo: guide.topAnchor, constant: 52),

      cancelButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
      cancelButton.bottomAnchor.constraint(equalTo: topBar.bottomAnchor, constant: -8),
      doneButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
      doneButton.bottomAnchor.constraint(equalTo: topBar.bottomAnchor, constant: -8),

      hintLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 24),
      hintLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -24),
      hintLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -24),
      hintLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
    ])
  }

  // MARK: - Session control

  private func startSession() {
    roomCaptureView.captureSession.run(configuration: captureConfig)
    os_log("capture session started", log: Self.log, type: .info)
  }

  private func stopSession() {
    guard !didStop else { return }
    didStop = true
    roomCaptureView.captureSession.stop()
    os_log("capture session stopped", log: Self.log, type: .info)
  }

  @objc private func cancelTapped() {
    os_log("cancel tapped", log: Self.log, type: .info)
    stopSession()
    finish(.cancelled)
  }

  @objc private func doneTapped() {
    os_log("done tapped — stopping session, awaiting processing", log: Self.log, type: .info)
    // Stopping triggers RoomCaptureView processing; results arrive in
    // captureView(didPresent:error:).
    stopSession()
  }

  @objc private func appDidEnterBackground() {
    guard !didFinish else { return }
    os_log("app backgrounded mid-scan — cancelling", log: Self.log, type: .error)
    stopSession()
    finish(.cancelled)
  }

  private func finish(_ outcome: RoomScanOutcome) {
    guard !didFinish else { return }
    didFinish = true
    os_log("finishing", log: Self.log, type: .info)
    dismiss(animated: true) { [weak self] in
      self?.completion(outcome)
    }
  }

  private func exportUSDZ(_ room: CapturedRoom) throws -> URL {
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent("roomscan-\(UUID().uuidString).usdz")
    try room.export(to: url, exportOptions: .parametric)
    return url
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
    os_log("deinit", log: Self.log, type: .info)
  }
}

// MARK: - RoomCaptureViewDelegate

@available(iOS 16.0, *)
extension RoomScanViewController: RoomCaptureViewDelegate {
  /// Return true to let RoomCaptureView process the raw data into a CapturedRoom.
  func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
    if let error = error {
      os_log("shouldPresent received error: %{public}@", log: Self.log, type: .error, error.localizedDescription)
    }
    return true
  }

  /// Final processed room — export USDZ + JSON and hand back.
  func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
    if let error = error {
      os_log("didPresent error: %{public}@", log: Self.log, type: .error, error.localizedDescription)
      finish(.failed(error.localizedDescription))
      return
    }
    do {
      let usdzURL = try exportUSDZ(processedResult)
      let jsonData = try JSONEncoder().encode(processedResult)
      guard let jsonString = String(data: jsonData, encoding: .utf8) else {
        finish(.failed("CapturedRoom JSON kodlashda xato"))
        return
      }
      os_log("exported usdz + encoded json (%d bytes)", log: Self.log, type: .info, jsonData.count)
      finish(.success([
        "json": jsonString,
        "usdzPath": usdzURL.path,
        "version": "roomplan-1",
      ]))
    } catch {
      os_log("export/encode failed: %{public}@", log: Self.log, type: .error, error.localizedDescription)
      finish(.failed(error.localizedDescription))
    }
  }
}

// MARK: - RoomCaptureSessionDelegate

@available(iOS 16.0, *)
extension RoomScanViewController: RoomCaptureSessionDelegate {
  func captureSession(_ session: RoomCaptureSession, didProvide instruction: RoomCaptureSession.Instruction) {
    let text = labels.instruction(instruction)
    os_log("instruction: %{public}@", log: Self.log, type: .info, String(describing: instruction))
    DispatchQueue.main.async { [weak self] in
      self?.hintLabel.text = text
    }
  }

  func captureSession(_ session: RoomCaptureSession, didStartWith configuration: RoomCaptureSession.Configuration) {
    os_log("session didStart", log: Self.log, type: .info)
  }

  func captureSession(_ session: RoomCaptureSession, didEndWith data: CapturedRoomData, error: Error?) {
    if let error = error {
      os_log("session didEnd with error: %{public}@", log: Self.log, type: .error, error.localizedDescription)
    } else {
      os_log("session didEnd cleanly", log: Self.log, type: .info)
    }
    // Processing into a CapturedRoom is handled by RoomCaptureView's delegate
    // (captureView(didPresent:)), so nothing to do here.
  }
}
