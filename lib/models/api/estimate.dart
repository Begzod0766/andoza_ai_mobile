import 'package:freezed_annotation/freezed_annotation.dart';

part 'estimate.freezed.dart';
part 'estimate.g.dart';

/// One line item in a computed smeta.
///
/// Mirrors `app/schemas/estimate.py::EstimateLine`. All money is in whole UZS
/// (the backend does its internal math in tiyin and exposes UZS here).
@freezed
abstract class EstimateLine with _$EstimateLine {
  const factory EstimateLine({
    required String label,
    required String formula,
    required double quantity,
    required String unit,
    @JsonKey(name: 'unit_price') required int unitPrice,
    @JsonKey(name: 'total_uzs') required int totalUzs,
    @JsonKey(name: 'is_approximate') @Default(false) bool isApproximate,
    @JsonKey(name: 'store_id') String? storeId,
    @Default('') String category,

    /// Free-text caveat the backend attaches to a line it could not price
    /// exactly (e.g. an assumed socket count). Shown verbatim to the user.
    String? warning,
  }) = _EstimateLine;

  factory EstimateLine.fromJson(Map<String, dynamic> json) =>
      _$EstimateLineFromJson(json);
}

/// A full computed/persisted estimate (`POST /rooms/{id}/estimate[/preview]`).
///
/// Mirrors `app/schemas/estimate.py::EstimateResponse`.
@freezed
abstract class Estimate with _$Estimate {
  const factory Estimate({
    required String id,
    @JsonKey(name: 'room_id') required String roomId,
    @Default(<EstimateLine>[]) List<EstimateLine> lines,
    @JsonKey(name: 'total_uzs') required int totalUzs,
    @JsonKey(name: 'total_min') required int totalMin,
    @JsonKey(name: 'total_max') required int totalMax,
    @Default('UZS') String currency,
    @Default('final') String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'has_electrical') @Default(false) bool hasElectrical,

    /// [totalUzs] split by line precision. Both default to 0 so an estimate
    /// persisted before the backend added the split still deserialises.
    @JsonKey(name: 'total_exact_uzs') @Default(0) int totalExactUzs,
    @JsonKey(name: 'total_approx_uzs') @Default(0) int totalApproxUzs,

    /// Whether [hasElectrical] is backed by real placed devices rather than
    /// the backend's default-point-count guess.
    @JsonKey(name: 'electrical_confirmed') @Default(false)
    bool electricalConfirmed,
    @JsonKey(name: 'usd_rate') @Default(0.0) double usdRate,
    @JsonKey(name: 'total_usd') @Default(0) int totalUsd,

    /// The caller is a guest: AI gap-fill and market prices were skipped, so
    /// the prices are catalogue/approximate until they sign up.
    @JsonKey(name: 'prices_approximate_for_guest') @Default(false)
    bool pricesApproximateForGuest,
  }) = _Estimate;

  factory Estimate.fromJson(Map<String, dynamic> json) =>
      _$EstimateFromJson(json);
}

/// Lightweight row for the estimate-history list (`GET /rooms/{id}/estimates`).
///
/// Mirrors `app/schemas/estimate.py::EstimateSummary`.
@freezed
abstract class EstimateSummary with _$EstimateSummary {
  const factory EstimateSummary({
    required String id,
    @JsonKey(name: 'room_id') required String roomId,
    @JsonKey(name: 'total_uzs') required int totalUzs,
    required String currency,
    required String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _EstimateSummary;

  factory EstimateSummary.fromJson(Map<String, dynamic> json) =>
      _$EstimateSummaryFromJson(json);
}

/// Paginated envelope for `GET /rooms/{id}/estimates`.
@freezed
abstract class PaginatedEstimates with _$PaginatedEstimates {
  const factory PaginatedEstimates({
    @Default(<EstimateSummary>[]) List<EstimateSummary> items,
    @Default(0) int total,
    @Default(20) int limit,
    @Default(0) int offset,
  }) = _PaginatedEstimates;

  factory PaginatedEstimates.fromJson(Map<String, dynamic> json) =>
      _$PaginatedEstimatesFromJson(json);
}
