import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService();

  static const _authTokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _userIsGuestKey = 'user_is_guest';

  /// This installation's random id, sent with `POST /auth/guest` so the
  /// server's per-install limit counts installs, not launches. Survives
  /// [clear] (sign-out, a dead session): a new id per attempt would hit the
  /// limit.
  static const _installIdKey = 'install_id';

  // Explicit platform options harden at-rest storage of auth/refresh tokens:
  // - Android: use the EncryptedSharedPreferences implementation rather than
  //   the legacy plaintext-keystore-wrapped SharedPreferences.
  // - iOS: keychain items are only readable after the first unlock and never
  //   leave this device (not synced to iCloud / restored to another device).
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<void> saveToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _authTokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _authTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return _storage.read(key: _userIdKey);
  }

  /// Whether the stored session belongs to a guest account, so a cold start
  /// that cannot reach `/auth/me` still knows it is a guest.
  Future<void> saveUserIsGuest(bool isGuest) async {
    await _storage.write(key: _userIsGuestKey, value: isGuest ? '1' : '0');
  }

  Future<bool> getUserIsGuest() async {
    return await _storage.read(key: _userIsGuestKey) == '1';
  }

  Future<String> getOrCreateInstallId() async {
    final existing = await _storage.read(key: _installIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = _uuidV4();
    await _storage.write(key: _installIdKey, value: id);
    return id;
  }

  /// Drops the session (tokens, user id). Keeps the install id.
  Future<void> clear() async {
    await _storage.delete(key: _authTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userIsGuestKey);
  }
}

String _uuidV4() {
  final random = Random.secure();
  final b = List<int>.generate(16, (_) => random.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
      '${h.substring(16, 20)}-${h.substring(20)}';
}
