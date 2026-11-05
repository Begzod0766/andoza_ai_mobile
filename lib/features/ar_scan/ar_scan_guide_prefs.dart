import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether the user has seen the short guide shown before the first AR scan.
abstract class ArScanGuidePrefs {
  Future<bool> seen();
  Future<void> markSeen();
}

class SharedPrefsArScanGuidePrefs implements ArScanGuidePrefs {
  static const _key = 'ar_scan_guide_seen';

  @override
  Future<bool> seen() async => (await SharedPreferences.getInstance()).getBool(_key) ?? false;

  @override
  Future<void> markSeen() async => (await SharedPreferences.getInstance()).setBool(_key, true);
}

final arScanGuidePrefsProvider = Provider<ArScanGuidePrefs>((_) => SharedPrefsArScanGuidePrefs());
