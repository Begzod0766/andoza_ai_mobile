import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_tour_keys.dart';
import 'home_tour_steps.dart';
import 'home_tour_store.dart';
import 'show_home_tour.dart';
import 'startup_dialogs.dart';

/// Each increment restarts the tour from step 1, ignoring the "done" flag.
/// The "?" button on the home screen increments it.
final homeTourRequestProvider = StateProvider<int>((ref) => 0);

/// How long the first-open tour waits so the push prompt and the
/// interrupted-scan dialog can finish their own checks first.
const _kAutoStartDelay = Duration(milliseconds: 1500);

/// Starts the home tour on the first open of the home screen and whenever
/// [homeTourRequestProvider] changes.
///
/// Auto-start (and the "done" flag it writes) only happens when every check
/// passes at the moment of starting: the widget is mounted, the home route is
/// the current one (no dialog, sheet or pushed page on top), no startup
/// dialog was shown, the tour was not seen yet and at least one target is on
/// screen. If a check fails nothing is marked done, so the tour is offered
/// again on the next launch.
class HomeTourLauncher extends ConsumerStatefulWidget {
  const HomeTourLauncher({required this.hasProjects, required this.child, super.key});

  final bool hasProjects;
  final Widget child;

  @override
  ConsumerState<HomeTourLauncher> createState() => _HomeTourLauncherState();
}

class _HomeTourLauncherState extends ConsumerState<HomeTourLauncher> {
  Timer? _timer;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _timer = Timer(_kAutoStartDelay, _autoStart);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// True when nothing covers the home screen: neither its own navigator nor
  /// the root one (dialogs and full-screen routes go to the root).
  bool _homeIsCurrent() {
    if (ModalRoute.of(context)?.isCurrent != true) return false;
    return !Navigator.of(context, rootNavigator: true).canPop();
  }

  bool _targetsPresent() => presentTargets(
        homeTourSteps(hasProjects: widget.hasProjects),
        ref.read(homeTourKeysProvider),
      ).isNotEmpty;

  Future<void> _autoStart() async {
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      return;
    }
    if (!mounted || _running) return;
    if (isHomeTourDone(prefs)) return;
    if (ref.read(startupDialogShownProvider)) return;
    if (!_homeIsCurrent() || !_targetsPresent()) return;
    _start(prefs);
  }

  void _replay() {
    if (!mounted || _running) return;
    if (!_homeIsCurrent() || !_targetsPresent()) return;
    _start(null);
  }

  void _start(SharedPreferences? prefsToMark) {
    _running = true;
    showHomeTour(
      context,
      ref.read(homeTourKeysProvider),
      hasProjects: widget.hasProjects,
      onFinish: () {
        _running = false;
        // A replay must not rewrite the flag; first-open marks it.
        final prefs = prefsToMark;
        if (prefs != null) markHomeTourDone(prefs);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(homeTourRequestProvider, (prev, next) {
      if (prev != next) _replay();
    });
    return widget.child;
  }
}
