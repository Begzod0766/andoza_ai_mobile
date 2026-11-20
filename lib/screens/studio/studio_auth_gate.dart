import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../../providers/auth_provider.dart';
import '../../services/secure_storage.dart';
import '../../widgets/registration_required_sheet.dart';
import 'studio_session.dart';

/// The JS channel the web Studio (and mebel workshop) posts to when a guest
/// taps something that needs an account (`frontend/src/lib/guestGate.ts`,
/// `requestRegistration`). Message: `{"feature": "<feature>"}`.
const studioAuthGateChannel = 'AndozaAuthGate';

/// The `feature` of an [studioAuthGateChannel] message; null for anything
/// else.
String? authGateFeatureFromMessage(String message) {
  try {
    final data = jsonDecode(message);
    if (data is Map && data['feature'] is String) {
      return data['feature'] as String;
    }
  } catch (_) {}
  return null;
}

bool _authGateOpen = false;

/// Handles one [studioAuthGateChannel] [message]: the sign-up sheet, and
/// once the guest has signed up or in, the WebView's session is handed over
/// again (new cookies and auth flag) and the page opened afresh with
/// [reopen] — the server rejects the guest's tokens after an upgrade or
/// merge, and the page may meanwhile be on the web's own /login.
///
/// Ignored when the person is no longer a guest (a page still holding the
/// guest flag) and while a sheet from an earlier message is open (a double
/// tap).
Future<void> onStudioAuthGate(
  BuildContext context,
  String message, {
  required AuthState Function() readAuth,
  required SecureStorageService storage,
  required Future<void> Function(String js) runJavaScript,
  required Future<void> Function() reopen,
  Future<bool> Function(BuildContext context, {required String feature})
      showSheet = showRegistrationRequiredSheet,
  Future<void> Function(AuthAuthenticated auth, SecureStorageService storage)
      seedCookies = seedStudioCookies,
}) async {
  final feature = authGateFeatureFromMessage(message);
  if (feature == null || _authGateOpen || !readAuth().isGuest) return;
  _authGateOpen = true;
  final bool signedUp;
  try {
    signedUp = await showSheet(context, feature: feature);
  } finally {
    _authGateOpen = false;
  }
  if (!signedUp) return;
  final auth = readAuth();
  if (auth is! AuthAuthenticated || auth.user.isGuest) return;
  await seedCookies(auth, storage);
  await runJavaScript(studioAuthSeedJs(auth.user));
  await reopen();
}
