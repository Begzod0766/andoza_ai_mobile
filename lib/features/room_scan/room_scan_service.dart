import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:riverpod/riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';
import 'models/captured_room.dart';

/// Result of the native `isSupported` probe.
class ScanSupport {
  /// Whether RoomPlan can run on this device.
  final bool supported;

  /// Why not, when [supported] is false: `"no_lidar" | "ios_too_old" |
  /// "not_implemented" | "unsupported_platform"` or a raw error code. Null when
  /// [supported].
  final String? reason;

  /// Whether several rooms can be scanned in one session and merged
  /// (RoomPlan's StructureBuilder: LiDAR and iOS 17+). False when the native
  /// side does not say, so older builds keep the single-room scan.
  final bool multiRoom;

  const ScanSupport(this.supported, this.reason, {this.multiRoom = false});
}

/// A completed RoomPlan capture handed back from the native side.
class ScanResult {
  /// The parsed room (walls/doors/windows/openings/objects).
  final CapturedRoom room;

  /// The exact JSON string the native side produced — forwarded verbatim to the
  /// backend as `room_json` so the server converter sees identical bytes.
  final String rawJson;

  /// Temp path to the exported parametric `.usdz`.
  final String usdzPath;

  /// Contract version, e.g. `"roomplan-1"`.
  final String version;

  const ScanResult({
    required this.room,
    required this.rawJson,
    required this.usdzPath,
    required this.version,
  });
}

/// Several rooms captured in one session (`scanRooms`), in one world frame.
class MultiScanResult {
  final List<ScanResult> rooms;

  /// The session ended early (the app went to the background); [rooms] are
  /// the ones finished before that.
  final bool partial;

  const MultiScanResult({required this.rooms, required this.partial});
}

/// Raised when a scan fails on the native side (busy, scan_failed, parse_failed…).
class RoomScanException implements Exception {
  final String code;
  final String message;
  const RoomScanException(this.code, this.message);

  @override
  String toString() => 'RoomScanException($code): $message';
}

/// The native RoomPlan scanners' texts in the app's language: the buttons,
/// the starting hint and the coaching lines for RoomPlan's instructions.
/// Without them the scanner shows its built-in Uzbek. `roomN` holds `{n}`.
/// RoomPlan's own animated prompts ("Point camera at…") come from iOS in the
/// phone's language and are out of the app's reach.
Map<String, String> roomScanLabels(AppLocalizations l10n) => {
      'nextRoom': l10n.scanNextRoom,
      'finish': l10n.scanFinish,
      'cancel': l10n.actionCancel,
      'done': l10n.actionDone,
      'roomN': l10n.scanRoomN(0).replaceFirst('0', '{n}'),
      'start': l10n.scanHintStart,
      'moveCloser': l10n.scanCoachMoveCloser,
      'moveAway': l10n.scanCoachMoveAway,
      'slowDown': l10n.scanCoachSlowDown,
      'turnOnLight': l10n.scanCoachTurnOnLight,
      'lowTexture': l10n.scanCoachLowTexture,
      'good': l10n.scanCoachGood,
      'keepGoing': l10n.scanCoachKeepGoing,
    };

/// Bridges the native RoomPlan module (`MethodChannel("andoza/roomscan")`) and
/// uploads the captured room to the backend. Pure-Dart-testable: the channel is
/// mocked via `TestDefaultBinaryMessengerBinding` in tests, and on non-iOS the
/// channel simply throws [MissingPluginException] → unsupported.
class RoomScanService {
  RoomScanService({required ApiClient apiClient}) : _api = apiClient;

  /// The single native channel. Public so tests can install a mock handler.
  static const MethodChannel channel = MethodChannel('andoza/roomscan');

  final ApiClient _api;
  static final Logger _logger = Logger();

  /// Probe device capability. Never throws — Android / older iOS / missing
  /// plugin all resolve to an unsupported [ScanSupport].
  Future<ScanSupport> checkSupport() async {
    try {
      final res = await channel.invokeMapMethod<String, dynamic>('isSupported');
      final supported = res?['supported'] == true;
      final reason = res?['reason'] as String?;
      _logger.i('roomscan isSupported → supported=$supported reason=$reason');
      return ScanSupport(
        supported,
        supported ? null : (reason ?? 'unsupported'),
        multiRoom: supported && res?['multiRoom'] == true,
      );
    } on MissingPluginException {
      // No native handler (Android, or iOS build without the module).
      return const ScanSupport(false, 'not_implemented');
    } on PlatformException catch (e) {
      _logger.e('roomscan isSupported failed', error: e);
      return ScanSupport(false, e.code);
    }
  }

  /// Present the native multi-room scanner (iOS 17+, see
  /// [ScanSupport.multiRoom]). [labels] are its texts in the app's language
  /// (see [roomScanLabels]). Returns null when the user cancels; throws
  /// [RoomScanException] on a native error.
  Future<MultiScanResult?> scanRooms({required Map<String, String> labels}) async {
    try {
      final res = await channel.invokeMapMethod<String, dynamic>(
          'scanRooms', {'labels': labels});
      if (res == null) return null;
      final version = res['version'] as String? ?? 'roomplan-1';
      final rooms = <ScanResult>[];
      for (final item in (res['rooms'] as List? ?? const [])) {
        final map = (item as Map).cast<String, dynamic>();
        final rawJson = map['json'] as String? ?? '';
        final decoded = jsonDecode(rawJson);
        if (decoded is! Map<String, dynamic>) {
          throw const RoomScanException('parse_failed', 'Skan natijasi noto\'g\'ri');
        }
        rooms.add(ScanResult(
          room: parseCapturedRoom(decoded),
          rawJson: rawJson,
          usdzPath: map['usdzPath'] as String? ?? '',
          version: version,
        ));
      }
      _logger.i('roomscan scanRooms → rooms=${rooms.length} partial=${res['partial']}');
      return MultiScanResult(rooms: rooms, partial: res['partial'] == true);
    } on PlatformException catch (e) {
      _logger.e('roomscan scanRooms failed', error: e);
      throw RoomScanException(e.code, e.message ?? 'Skanerlashda xatolik');
    }
  }

  /// Present the native RoomPlan scanner. [labels] are its texts in the app's
  /// language (see [roomScanLabels]). Returns null when the user cancels;
  /// throws [RoomScanException] on a native error (`busy`, `scan_failed`, …).
  Future<ScanResult?> scan({required Map<String, String> labels}) async {
    try {
      final res = await channel.invokeMapMethod<String, dynamic>(
          'scanRoom', {'labels': labels});
      if (res == null) {
        _logger.i('roomscan scanRoom → cancelled');
        return null;
      }
      final rawJson = res['json'] as String? ?? '';
      final usdzPath = res['usdzPath'] as String? ?? '';
      final version = res['version'] as String? ?? 'roomplan-1';
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) {
        throw const RoomScanException('parse_failed', 'Skan natijasi noto\'g\'ri');
      }
      final room = parseCapturedRoom(decoded);
      _logger.i('roomscan scanRoom → walls=${room.walls.length} '
          'objects=${room.objects.length} usdz=$usdzPath');
      return ScanResult(
        room: room,
        rawJson: rawJson,
        usdzPath: usdzPath,
        version: version,
      );
    } on PlatformException catch (e) {
      _logger.e('roomscan scanRoom failed', error: e);
      throw RoomScanException(e.code, e.message ?? 'Skanerlashda xatolik');
    }
  }

  /// Phase 6 — capture a single object via Apple Object Capture (iOS 17+).
  /// Returns the temp `.usdz` path, null on cancel; throws on native error.
  Future<String?> scanObject() async {
    try {
      final res = await channel.invokeMapMethod<String, dynamic>('scanObject');
      if (res == null) {
        _logger.i('roomscan scanObject → cancelled');
        return null;
      }
      final path = res['usdzPath'] as String?;
      if (path == null || path.isEmpty) {
        throw const RoomScanException('scan_failed', 'Model olinmadi');
      }
      _logger.i('roomscan scanObject → $path');
      return path;
    } on MissingPluginException {
      throw const RoomScanException('not_implemented', 'Bu qurilmada mavjud emas');
    } on PlatformException catch (e) {
      _logger.e('roomscan scanObject failed', error: e);
      throw RoomScanException(e.code, e.message ?? 'Buyum skanerlashda xatolik');
    }
  }

  /// Phase 6 — upload a captured object's `.usdz` for the scanned object at
  /// [objectIndex]; the backend converts it to GLB and attaches it so the studio
  /// can offer "use the scanned model" for that ghost.
  Future<Map<String, dynamic>> uploadObject(
      String roomId, int objectIndex, String usdzPath) async {
    final bytes = await File(usdzPath).readAsBytes();
    _logger.i('roomscan uploadObject → room=$roomId idx=$objectIndex ${bytes.length}B');
    return _api.uploadFile<Map<String, dynamic>>(
      '/rooms/$roomId/room-scan/objects',
      bytes: bytes,
      filename: 'object.usdz',
      fieldName: 'usdz',
      contentType: 'model/vnd.usdz+zip',
      fields: {'object_index': objectIndex.toString()},
      fromJson: (d) => (d as Map).cast<String, dynamic>(),
    );
  }

  /// Upload [png] as the room's project-card thumbnail. A scanned room has no
  /// preview otherwise (only the web studio ever populated one), so its card in
  /// "Loyihalarim" stays blank until someone opens it on a desktop.
  ///
  /// Multipart shape verified against the live backend: field name `file`,
  /// content type `image/png` (the router rejects any other field name with 422
  /// and any non-image content type with 415).
  Future<Map<String, dynamic>> uploadThumbnail(String roomId, Uint8List png) async {
    _logger.i('roomscan uploadThumbnail → room=$roomId ${png.length}B');
    return _api.uploadFile<Map<String, dynamic>>(
      '/rooms/$roomId/thumbnail',
      bytes: png,
      filename: 'thumbnail.png',
      fieldName: 'file',
      contentType: 'image/png',
      fromJson: (d) => (d as Map).cast<String, dynamic>(),
    );
  }

  /// Attach the scan artifacts (parametric JSON + `.usdz`) to an already-created
  /// room. The room itself is created first via the normal handoff, exactly like
  /// the manual flow; this only uploads the extras. Returns the room JSON the
  /// backend echoes back (Phase 4).
  /// [scanGroup] marks the rooms of one multi-room session, so the backend's
  /// duplicate-scan cleanup keeps them all.
  Future<Map<String, dynamic>> upload(String roomId, ScanResult scan,
      {String? scanGroup}) async {
    final bytes = await File(scan.usdzPath).readAsBytes();
    _logger.i('roomscan upload → room=$roomId usdz=${bytes.length}B');
    return _api.uploadFile<Map<String, dynamic>>(
      '/rooms/$roomId/room-scan',
      bytes: bytes,
      filename: 'scan.usdz',
      fieldName: 'usdz',
      contentType: 'model/vnd.usdz+zip',
      fields: {
        'room_json': scan.rawJson,
        'scan_group': ?scanGroup,
      },
      fromJson: (d) => (d as Map).cast<String, dynamic>(),
    );
  }
}

/// DI for [RoomScanService], wired to the shared authenticated [ApiClient].
final roomScanServiceProvider = Provider<RoomScanService>((ref) {
  return RoomScanService(apiClient: ref.watch(apiClientProvider));
});
