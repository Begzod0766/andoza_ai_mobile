import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True once a startup dialog or redirect (push prompt, interrupted-scan
/// resume, business application) was shown in this app run. The home tour
/// waits for the next app open instead of stacking on top of it.
final startupDialogShownProvider = StateProvider<bool>((ref) => false);
