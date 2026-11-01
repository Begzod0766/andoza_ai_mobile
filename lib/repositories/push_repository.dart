import '../services/api_client.dart';

/// Tells the backend which phone (FCM token) belongs to the signed-in account.
class PushRepository {
  PushRepository(this._client);

  final ApiClient _client;

  Future<void> register(String token, String platform, String locale) =>
      _client.post<void>(
        '/devices',
        data: {'token': token, 'platform': platform, 'locale': locale},
        fromJson: (_) {},
      );

  Future<void> unregister(String token) =>
      _client.delete('/devices', data: {'token': token});
}
