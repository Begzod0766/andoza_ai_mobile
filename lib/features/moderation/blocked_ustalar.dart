import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ustalar this person blocked: hidden from the map and the list on this
/// device (App Store guideline 1.2 asks for a way to block abusive users).
class BlockedUstalarNotifier extends Notifier<Set<String>> {
  static const prefsKey = 'blocked_ustalar';

  @override
  Set<String> build() {
    _load();
    return const {};
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(prefsKey) ?? const [];
      if (saved.isNotEmpty) state = {...state, ...saved};
    } catch (_) {
      // No stored list (or no prefs): nobody is blocked.
    }
  }

  Future<void> block(String id) async {
    state = {...state, id};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(prefsKey, state.toList());
  }
}

final blockedUstalarProvider =
    NotifierProvider<BlockedUstalarNotifier, Set<String>>(
      BlockedUstalarNotifier.new,
    );
