import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/captured_room.dart';
import 'room_scan_converter.dart';
import 'room_scan_service.dart';

/// Survives a LiDAR scan across app restarts until the user actually
/// finishes the review screen ("Davom etish").
///
/// Without this, a completed scan lived only in the navigator's `extra`
/// payload and the capture's own temp files (system temp dir, which iOS can
/// purge at any time, even while the app stays foregrounded). Backgrounding
/// the app, a call coming in, or iOS reclaiming memory between finishing a
/// scan and tapping "Davom etish" silently threw away a scan that could take
/// several minutes to redo. [save] is called right after a successful scan;
/// [clear] once the room is actually persisted to the backend.
class PendingScanStore {
  const PendingScanStore._();

  static const _kRawJson = 'pending_scan_raw_json';
  static const _kVersion = 'pending_scan_version';
  static const _kSavedAt = 'pending_scan_saved_at_ms';
  static const _kUsdzFileName = 'pending_scan.usdz';

  /// Where the scan files are kept; replaced in tests.
  @visibleForTesting
  static Future<Directory> Function() documentsDir = getApplicationDocumentsDirectory;

  static Future<File> _usdzFile() async {
    final dir = await documentsDir();
    return File('${dir.path}/$_kUsdzFileName');
  }

  /// Copies the scan's `.usdz` out of the (ephemeral) temp dir into the app's
  /// Documents dir and records the rest alongside it. Best-effort: a failure
  /// here must never block the user from continuing on to the review screen,
  /// so callers should not await-and-rethrow this into their own error UI.
  static Future<void> save(ScanResult scan) async {
    final dest = await _usdzFile();
    await File(scan.usdzPath).copy(dest.path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRawJson, scan.rawJson);
    await prefs.setString(_kVersion, scan.version);
    await prefs.setInt(_kSavedAt, DateTime.now().millisecondsSinceEpoch);
  }

  /// Whether a not-yet-finished scan is sitting in storage.
  static Future<bool> hasPending() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kRawJson) != null;
  }

  /// Re-derives the review screen's payload from storage, or null when
  /// there's nothing pending, or what's there can no longer be parsed (a
  /// format change, a missing file) — in which case it also clears the dead
  /// entry so [hasPending] does not keep reporting it.
  static Future<({RoomScanDraft draft, ScanResult scan})?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_kRawJson);
    if (rawJson == null) return null;
    final usdzFile = await _usdzFile();
    try {
      if (!await usdzFile.exists()) throw StateError('usdz missing');
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      final room = parseCapturedRoom(decoded);
      final draft = RoomScanConverter.toRoomDraft(room);
      if (!draft.plan.isValid) throw StateError('invalid plan');
      final scan = ScanResult(
        room: room,
        rawJson: rawJson,
        usdzPath: usdzFile.path,
        version: prefs.getString(_kVersion) ?? 'roomplan-1',
      );
      return (draft: draft, scan: scan);
    } catch (_) {
      await clear();
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRawJson);
    await prefs.remove(_kVersion);
    await prefs.remove(_kSavedAt);
    try {
      final f = await _usdzFile();
      if (await f.exists()) await f.delete();
    } catch (_) {
      // Best-effort cleanup — a leftover temp file costs disk space, not
      // correctness (the SharedPreferences keys above are the source of
      // truth for `hasPending`).
    }
  }

  // ── A multi-room scan (several rooms of a flat in one session) ──────────

  static const _kFlatJson = 'pending_flat_json';
  static const _kFlatPrefix = 'pending_flat_';

  static Future<File> _flatUsdz(int i) async =>
      File('${(await documentsDir()).path}/$_kFlatPrefix$i.usdz');

  /// Keeps a multi-room scan until its review is finished, like [save] does
  /// for one room: the `.usdz` files go to Documents, the room JSONs to prefs.
  static Future<void> saveFlat(MultiScanResult flat) async {
    await clearFlat(); // no files left over from a bigger earlier set
    for (var i = 0; i < flat.rooms.length; i++) {
      await File(flat.rooms[i].usdzPath).copy((await _flatUsdz(i)).path);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kFlatJson, jsonEncode([for (final r in flat.rooms) r.rawJson]));
  }

  static Future<bool> hasPendingFlat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kFlatJson) != null;
  }

  /// The kept multi-room scan, or null. Rooms that no longer convert to a
  /// valid plan (or lost their file) are left out; with none left, the entry
  /// is cleared.
  static Future<({List<RoomScanDraft> drafts, List<ScanResult> scans})?>
      loadFlat() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kFlatJson);
    if (raw == null) return null;
    final drafts = <RoomScanDraft>[];
    final scans = <ScanResult>[];
    try {
      final list = (jsonDecode(raw) as List).cast<String>();
      for (var i = 0; i < list.length; i++) {
        try {
          final file = await _flatUsdz(i);
          if (!await file.exists()) continue;
          final decoded = jsonDecode(list[i]);
          if (decoded is! Map<String, dynamic>) continue;
          final room = parseCapturedRoom(decoded);
          final draft = RoomScanConverter.toRoomDraft(room);
          if (!draft.plan.isValid) continue;
          drafts.add(draft);
          scans.add(ScanResult(
              room: room, rawJson: list[i], usdzPath: file.path, version: 'roomplan-1'));
        } catch (_) {
          // One unreadable room does not lose the others.
        }
      }
    } catch (_) {
      // The entry itself is unreadable.
    }
    if (drafts.isEmpty) {
      await clearFlat();
      return null;
    }
    return (drafts: drafts, scans: scans);
  }

  static Future<void> clearFlat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kFlatJson);
    try {
      final dir = await documentsDir();
      for (final f in dir.listSync().whereType<File>()) {
        final name = f.uri.pathSegments.last;
        if (name.startsWith(_kFlatPrefix) && name.endsWith('.usdz')) await f.delete();
      }
    } catch (_) {
      // Best-effort, as in [clear].
    }
  }
}
