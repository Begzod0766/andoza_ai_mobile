// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'estimate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EstimateLine _$EstimateLineFromJson(Map<String, dynamic> json) =>
    _EstimateLine(
      label: json['label'] as String,
      formula: json['formula'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      unitPrice: (json['unit_price'] as num).toInt(),
      totalUzs: (json['total_uzs'] as num).toInt(),
      isApproximate: json['is_approximate'] as bool? ?? false,
      storeId: json['store_id'] as String?,
      category: json['category'] as String? ?? '',
      warning: json['warning'] as String?,
    );

Map<String, dynamic> _$EstimateLineToJson(_EstimateLine instance) =>
    <String, dynamic>{
      'label': instance.label,
      'formula': instance.formula,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'unit_price': instance.unitPrice,
      'total_uzs': instance.totalUzs,
      'is_approximate': instance.isApproximate,
      'store_id': instance.storeId,
      'category': instance.category,
      'warning': instance.warning,
    };

_Estimate _$EstimateFromJson(Map<String, dynamic> json) => _Estimate(
  id: json['id'] as String,
  roomId: json['room_id'] as String,
  lines:
      (json['lines'] as List<dynamic>?)
          ?.map((e) => EstimateLine.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <EstimateLine>[],
  totalUzs: (json['total_uzs'] as num).toInt(),
  totalMin: (json['total_min'] as num).toInt(),
  totalMax: (json['total_max'] as num).toInt(),
  currency: json['currency'] as String? ?? 'UZS',
  status: json['status'] as String? ?? 'final',
  createdAt: DateTime.parse(json['created_at'] as String),
  hasElectrical: json['has_electrical'] as bool? ?? false,
  totalExactUzs: (json['total_exact_uzs'] as num?)?.toInt() ?? 0,
  totalApproxUzs: (json['total_approx_uzs'] as num?)?.toInt() ?? 0,
  electricalConfirmed: json['electrical_confirmed'] as bool? ?? false,
  usdRate: (json['usd_rate'] as num?)?.toDouble() ?? 0.0,
  totalUsd: (json['total_usd'] as num?)?.toInt() ?? 0,
  pricesApproximateForGuest:
      json['prices_approximate_for_guest'] as bool? ?? false,
);

Map<String, dynamic> _$EstimateToJson(_Estimate instance) => <String, dynamic>{
  'id': instance.id,
  'room_id': instance.roomId,
  'lines': instance.lines,
  'total_uzs': instance.totalUzs,
  'total_min': instance.totalMin,
  'total_max': instance.totalMax,
  'currency': instance.currency,
  'status': instance.status,
  'created_at': instance.createdAt.toIso8601String(),
  'has_electrical': instance.hasElectrical,
  'total_exact_uzs': instance.totalExactUzs,
  'total_approx_uzs': instance.totalApproxUzs,
  'electrical_confirmed': instance.electricalConfirmed,
  'usd_rate': instance.usdRate,
  'total_usd': instance.totalUsd,
  'prices_approximate_for_guest': instance.pricesApproximateForGuest,
};

_EstimateSummary _$EstimateSummaryFromJson(Map<String, dynamic> json) =>
    _EstimateSummary(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      totalUzs: (json['total_uzs'] as num).toInt(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$EstimateSummaryToJson(_EstimateSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'room_id': instance.roomId,
      'total_uzs': instance.totalUzs,
      'currency': instance.currency,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
    };

_PaginatedEstimates _$PaginatedEstimatesFromJson(Map<String, dynamic> json) =>
    _PaginatedEstimates(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => EstimateSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <EstimateSummary>[],
      total: (json['total'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PaginatedEstimatesToJson(_PaginatedEstimates instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
      'limit': instance.limit,
      'offset': instance.offset,
    };
