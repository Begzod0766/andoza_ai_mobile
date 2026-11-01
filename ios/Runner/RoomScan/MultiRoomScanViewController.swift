import ARKit
import UIKit
import os.log

#if canImport(RoomPlan)
import RoomPlan
#endif

/// The RoomPlan scanners' texts (buttons, the starting hint and the coaching
/// lines), passed in from Dart as `labels` so they follow the app's language.
/// The Uzbek defaults cover an older Dart side that sends none. `roomN` holds
/// `{n}` for the room number.
struct RoomScanLabels {
  var nextRoom = "Keyingi xona"
  var finish = "Tugatish"
  var cancel = "Bekor qilish"
  var done = "Tayyor"
  var roomN = "{n}-xona"
  var start = "Xonani sekin aylanib skanerlang"
  var moveCloser = "Telefonni devorga yaqinroq tuting"
  var moveAway = "Telefonni devordan birozroq uzoqlashtiring"
  var slowDown = "Juda tez harakatlanyapsiz — sekinroq aylaning"
  var turnOnLight = "Xona qorong'i — yorug'likni yoqing"
  var lowTexture = "Bu yuza silliq/bir xil — kamerani boshqa tomonga burang"
  var good = "Zo'r ketyapti — xonani shu tezlikda aylanib chiqing"
  var keepGoing = "Skanerlashda davom eting"

  init(_ args: Any?) {
    guard let map = (args as? [String: Any])?["labels"] as? [String: Any] else { return }
    func take(_ key: String, _ value: inout String) {
      if let v = map[key] as? String, !v.isEmpty { value = v }
    }
    take("nextRoom", &nextRoom)
    take("finish", &finish)
    take("cancel", &cancel)
    take("done", &done)
    take("roomN", &roomN)
    take("start", &start)
    take("moveCloser", &moveCloser)
    take("moveAway", &moveAway)
    take("slowDown", &slowDown)
    take("turnOnLight", &turnOnLight)
    take("lowTexture", &lowTexture)
    take("good", &good)
    take("keepGoing", &keepGoing)
  }

  #if canImport(RoomPlan)
  /// The coaching line for RoomPlan's current instruction.
  @available(iOS 16.0, *)
  func instruction(_ instruction: RoomCaptureSession.Instruction) -> String {
    switch instruction {
    case .moveCloseToWall: return moveCloser
    case .moveAwayFromWall: return moveAway
    case .slowDown: return slowDown
    case .turnOnLight: return turnOnLight
    case .lowTexture: return lowTexture
    case .normal: return good
    @unknown default: return keepGoing
    }
  }
  #endif
}

/// Several rooms of a flat in one session. One ARSession stays alive across
/// the rooms, so every CapturedRoom is in the same world frame; each room is
/// its own RoomCaptureSession run inside the same RoomCaptureView. At the end
/// StructureBuilder refines them together (iOS 17).
///
/// Outcome: `{rooms: [{json, usdzPath}], version: "roomplan-1", partial: Bool}`;
/// `partial` when the app went to the background mid-session (the rooms done
/// so far are kept). Cancel discards everything.
@available(iOS 17.0, *)
final class MultiRoomScanViewController: UIViewController {
  private static let log = OSLog(subsystem: "uz.andoza.roomscan", category: "multiroom")

  private let completion: (RoomScanOutcome) -> Void
  private let labels: RoomScanLabels
  private let arSession = ARSession()
  private var roomCaptureView: RoomCaptureView!
  private let captureConfig = RoomCaptureSession.Configuration()

  private var rooms: [CapturedRoom] = []
  /// A room is being captured (between run and "Keyingi xona"/"Tugatish").
  private var capturing = false
  /// A finished room is being processed (until captureView(didPresent:)).
  private var processing = false
  /// "Tugatish" was tapped: merge once the current room's result arrives.
  private var finishing = false
  private var didFinish = false
  private var merging = false

  private let hintLabel = UILabel()
  private let counterLabel = UILabel()
  private let nextButton = UIButton(type: .system)
  private let finishButton = UIButton(type: .system)

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
    roomCaptureView = RoomCaptureView(frame: view.bounds, arSession: arSession)
    roomCaptureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    roomCaptureView.delegate = self
    roomCaptureView.captureSession.delegate = self
    view.addSubview(roomCaptureView)
    setUpChrome()
    NotificationCenter.default.addObserver(
      self, selector: #selector(appDidEnterBackground),
      name: UIApplication.didEnterBackgroundNotification, object: nil)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    startRoom()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  private func setUpChrome() {
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
    topBar.addSubview(cancelButton)

    finishButton.setTitle(labels.finish, for: .normal)
    finishButton.setTitleColor(.white, for: .normal)
    finishButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
    finishButton.addTarget(self, action: #selector(finishTapped), for: .touchUpInside)
    finishButton.translatesAutoresizingMaskIntoConstraints = false
    topBar.addSubview(finishButton)

    counterLabel.translatesAutoresizingMaskIntoConstraints = false
    counterLabel.textColor = .white
    counterLabel.font = .systemFont(ofSize: 17, weight: .semibold)
    topBar.addSubview(counterLabel)

    nextButton.setTitle(labels.nextRoom, for: .normal)
    nextButton.setTitleColor(.white, for: .normal)
    nextButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
    nextButton.backgroundColor = UIColor.systemBlue
    nextButton.layer.cornerRadius = 22
    nextButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
    nextButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(nextButton)

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
      finishButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
      finishButton.bottomAnchor.constraint(equalTo: topBar.bottomAnchor, constant: -8),
      counterLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
      counterLabel.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor),

      hintLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 24),
      hintLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -24),
      hintLabel.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -12),
      hintLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
      nextButton.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
      nextButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -20),
      nextButton.heightAnchor.constraint(equalToConstant: 44),
    ])
  }

  private func updateCounter() {
    counterLabel.text = labels.roomN.replacingOccurrences(of: "{n}", with: "\(rooms.count + 1)")
    nextButton.isEnabled = capturing && !finishing
    nextButton.alpha = nextButton.isEnabled ? 1 : 0.5
  }

  // MARK: - Rooms

  private func startRoom() {
    guard !didFinish, !finishing else { return }
    capturing = true
    roomCaptureView.captureSession.run(configuration: captureConfig)
    updateCounter()
    os_log("room %d started", log: Self.log, type: .info, rooms.count + 1)
  }

  /// "Keyingi xona": end this room but keep the AR session (and its world
  /// frame) running for the next one.
  @objc private func nextTapped() {
    guard capturing, !finishing else { return }
    capturing = false
    processing = true
    updateCounter()
    roomCaptureView.captureSession.stop(pauseARSession: false)
  }

  @objc private func finishTapped() {
    guard !finishing, !didFinish else { return }
    finishing = true
    updateCounter()
    if capturing {
      capturing = false
      processing = true
      // The last room's result arrives in captureView(didPresent:), then merge.
      roomCaptureView.captureSession.stop()
    } else if processing {
      // "Tugatish" right after "Keyingi xona": the previous room is still
      // being processed — merge once it arrives, so it is not lost. (The AR
      // session is paused in finish().)
    } else {
      merge(partial: false)
    }
  }

  @objc private func cancelTapped() {
    roomCaptureView.captureSession.stop()
    finish(.cancelled)
  }

  /// Going to the background ends the AR session; keep what is done.
  @objc private func appDidEnterBackground() {
    guard !didFinish else { return }
    finishing = true
    roomCaptureView.captureSession.stop()
    if rooms.isEmpty {
      finish(.cancelled)
    } else {
      merge(partial: true)
    }
  }

  private func roomFinished(_ room: CapturedRoom?) {
    processing = false
    if let room = room { rooms.append(room) }
    if finishing {
      if rooms.isEmpty { finish(.cancelled) } else { merge(partial: false) }
    } else {
      startRoom()
    }
  }

  /// StructureBuilder refines the rooms together; if it fails, the rooms as
  /// captured are already in one world frame (one ARSession), so use them.
  private func merge(partial: Bool) {
    guard !didFinish, !merging else { return }
    // Never report success without a room.
    guard !rooms.isEmpty else {
      finish(.cancelled)
      return
    }
    merging = true
    let captured = rooms
    Task { @MainActor in
      var final = captured
      do {
        let structure = try await StructureBuilder(options: [.beautifyObjects])
          .capturedStructure(from: captured)
        if structure.rooms.count == captured.count {
          final = structure.rooms
        } else {
          os_log("StructureBuilder returned %d rooms for %d — using the captured ones",
                 log: Self.log, type: .error, structure.rooms.count, captured.count)
        }
      } catch {
        os_log("StructureBuilder failed: %{public}@ — using the captured rooms",
               log: Self.log, type: .error, error.localizedDescription)
      }
      do {
        let payload = try final.map { room -> [String: Any] in
          let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("roomscan-\(UUID().uuidString).usdz")
          try room.export(to: url, exportOptions: .parametric)
          let data = try JSONEncoder().encode(room)
          guard let json = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "roomscan", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "CapturedRoom JSON kodlashda xato"])
          }
          return ["json": json, "usdzPath": url.path]
        }
        finish(.success(["rooms": payload, "version": "roomplan-1", "partial": partial]))
      } catch {
        finish(.failed(error.localizedDescription))
      }
    }
  }

  private func finish(_ outcome: RoomScanOutcome) {
    guard !didFinish else { return }
    didFinish = true
    arSession.pause()
    dismiss(animated: true) { [weak self] in
      self?.completion(outcome)
    }
  }
}

// MARK: - RoomCaptureViewDelegate

@available(iOS 17.0, *)
extension MultiRoomScanViewController: RoomCaptureViewDelegate {
  func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
    if let error = error {
      os_log("shouldPresent error: %{public}@", log: Self.log, type: .error, error.localizedDescription)
    }
    return true
  }

  /// One room processed. A room that failed to process is skipped; the rest
  /// of the session goes on.
  func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
    if let error = error {
      os_log("room failed: %{public}@", log: Self.log, type: .error, error.localizedDescription)
      roomFinished(nil)
      return
    }
    roomFinished(processedResult)
  }
}

// MARK: - RoomCaptureSessionDelegate

@available(iOS 17.0, *)
extension MultiRoomScanViewController: RoomCaptureSessionDelegate {
  func captureSession(_ session: RoomCaptureSession, didProvide instruction: RoomCaptureSession.Instruction) {
    let text = labels.instruction(instruction)
    DispatchQueue.main.async { [weak self] in
      self?.hintLabel.text = text
    }
  }
}
