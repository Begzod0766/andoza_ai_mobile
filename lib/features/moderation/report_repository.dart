import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';

/// What can be reported: content other users published (App Store guideline
/// 1.2). Values match the backend's `target_type`.
enum ReportTarget { usta, product, seller, portfolioItem, wallpaper }

/// Why. Values match the backend's `reason`.
enum ReportReason { spam, inappropriate, fraud, other }

extension on ReportTarget {
  String get wire => switch (this) {
    ReportTarget.portfolioItem => 'portfolio_item',
    _ => name,
  };
}

/// Sends a complaint about published content (`POST /reports`); the admins
/// review it. Reporting the same thing twice is harmless — the server keeps
/// the first report.
class ReportRepository {
  ReportRepository(this._client);

  final ApiClient _client;

  Future<void> report({
    required ReportTarget target,
    required String targetId,
    required ReportReason reason,
    String? details,
  }) {
    final text = details?.trim();
    return _client.post<void>(
      '/reports',
      data: {
        'target_type': target.wire,
        'target_id': targetId,
        'reason': reason.name,
        if (text != null && text.isNotEmpty) 'details': text,
      },
      fromJson: (_) {},
    );
  }
}

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => ReportRepository(ref.watch(apiClientProvider)),
);
