// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'estimate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EstimateLine {

 String get label; String get formula; double get quantity; String get unit;@JsonKey(name: 'unit_price') int get unitPrice;@JsonKey(name: 'total_uzs') int get totalUzs;@JsonKey(name: 'is_approximate') bool get isApproximate;@JsonKey(name: 'store_id') String? get storeId; String get category;/// Free-text caveat the backend attaches to a line it could not price
/// exactly (e.g. an assumed socket count). Shown verbatim to the user.
 String? get warning;
/// Create a copy of EstimateLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EstimateLineCopyWith<EstimateLine> get copyWith => _$EstimateLineCopyWithImpl<EstimateLine>(this as EstimateLine, _$identity);

  /// Serializes this EstimateLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EstimateLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EstimateLine&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.formula, _this.formula) || other.formula == _this.formula)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice)&&(identical(other.totalUzs, _this.totalUzs) || other.totalUzs == _this.totalUzs)&&(identical(other.isApproximate, _this.isApproximate) || other.isApproximate == _this.isApproximate)&&(identical(other.storeId, _this.storeId) || other.storeId == _this.storeId)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.warning, _this.warning) || other.warning == _this.warning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EstimateLine;
  return Object.hash(runtimeType,_this.label,_this.formula,_this.quantity,_this.unit,_this.unitPrice,_this.totalUzs,_this.isApproximate,_this.storeId,_this.category,_this.warning);
}

@override
String toString() {
  final _this = this as EstimateLine;
  return 'EstimateLine(label: ${_this.label}, formula: ${_this.formula}, quantity: ${_this.quantity}, unit: ${_this.unit}, unitPrice: ${_this.unitPrice}, totalUzs: ${_this.totalUzs}, isApproximate: ${_this.isApproximate}, storeId: ${_this.storeId}, category: ${_this.category}, warning: ${_this.warning})';
}


}

/// @nodoc
abstract mixin class $EstimateLineCopyWith<$Res>  {
  factory $EstimateLineCopyWith(EstimateLine value, $Res Function(EstimateLine) _then) = _$EstimateLineCopyWithImpl;
@useResult
$Res call({
 String label, String formula, double quantity, String unit,@JsonKey(name: 'unit_price') int unitPrice,@JsonKey(name: 'total_uzs') int totalUzs,@JsonKey(name: 'is_approximate') bool isApproximate,@JsonKey(name: 'store_id') String? storeId, String category, String? warning
});




}
/// @nodoc
class _$EstimateLineCopyWithImpl<$Res>
    implements $EstimateLineCopyWith<$Res> {
  _$EstimateLineCopyWithImpl(this._self, this._then);

  final EstimateLine _self;
  final $Res Function(EstimateLine) _then;

/// Create a copy of EstimateLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? formula = null,Object? quantity = null,Object? unit = null,Object? unitPrice = null,Object? totalUzs = null,Object? isApproximate = null,Object? storeId = freezed,Object? category = null,Object? warning = freezed,}) {
  return _then(EstimateLine(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,formula: null == formula ? _self.formula : formula // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int,totalUzs: null == totalUzs ? _self.totalUzs : totalUzs // ignore: cast_nullable_to_non_nullable
as int,isApproximate: null == isApproximate ? _self.isApproximate : isApproximate // ignore: cast_nullable_to_non_nullable
as bool,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EstimateLine].
extension EstimateLinePatterns on EstimateLine {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EstimateLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EstimateLine() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EstimateLine value)  $default,){
final _that = this;
switch (_that) {
case _EstimateLine():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EstimateLine value)?  $default,){
final _that = this;
switch (_that) {
case _EstimateLine() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String formula,  double quantity,  String unit, @JsonKey(name: 'unit_price')  int unitPrice, @JsonKey(name: 'total_uzs')  int totalUzs, @JsonKey(name: 'is_approximate')  bool isApproximate, @JsonKey(name: 'store_id')  String? storeId,  String category,  String? warning)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EstimateLine() when $default != null:
return $default(_that.label,_that.formula,_that.quantity,_that.unit,_that.unitPrice,_that.totalUzs,_that.isApproximate,_that.storeId,_that.category,_that.warning);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String formula,  double quantity,  String unit, @JsonKey(name: 'unit_price')  int unitPrice, @JsonKey(name: 'total_uzs')  int totalUzs, @JsonKey(name: 'is_approximate')  bool isApproximate, @JsonKey(name: 'store_id')  String? storeId,  String category,  String? warning)  $default,) {final _that = this;
switch (_that) {
case _EstimateLine():
return $default(_that.label,_that.formula,_that.quantity,_that.unit,_that.unitPrice,_that.totalUzs,_that.isApproximate,_that.storeId,_that.category,_that.warning);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String formula,  double quantity,  String unit, @JsonKey(name: 'unit_price')  int unitPrice, @JsonKey(name: 'total_uzs')  int totalUzs, @JsonKey(name: 'is_approximate')  bool isApproximate, @JsonKey(name: 'store_id')  String? storeId,  String category,  String? warning)?  $default,) {final _that = this;
switch (_that) {
case _EstimateLine() when $default != null:
return $default(_that.label,_that.formula,_that.quantity,_that.unit,_that.unitPrice,_that.totalUzs,_that.isApproximate,_that.storeId,_that.category,_that.warning);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EstimateLine implements EstimateLine {
  const _EstimateLine({required this.label, required this.formula, required this.quantity, required this.unit, @JsonKey(name: 'unit_price') required this.unitPrice, @JsonKey(name: 'total_uzs') required this.totalUzs, @JsonKey(name: 'is_approximate') this.isApproximate = false, @JsonKey(name: 'store_id') this.storeId, this.category = '', this.warning});
  factory _EstimateLine.fromJson(Map<String, dynamic> json) => _$EstimateLineFromJson(json);

@override final  String label;
@override final  String formula;
@override final  double quantity;
@override final  String unit;
@override@JsonKey(name: 'unit_price') final  int unitPrice;
@override@JsonKey(name: 'total_uzs') final  int totalUzs;
@override@JsonKey(name: 'is_approximate') final  bool isApproximate;
@override@JsonKey(name: 'store_id') final  String? storeId;
@override@JsonKey() final  String category;
/// Free-text caveat the backend attaches to a line it could not price
/// exactly (e.g. an assumed socket count). Shown verbatim to the user.
@override final  String? warning;

/// Create a copy of EstimateLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EstimateLineCopyWith<_EstimateLine> get copyWith => __$EstimateLineCopyWithImpl<_EstimateLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EstimateLineToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EstimateLine&&(identical(other.label, label) || other.label == label)&&(identical(other.formula, formula) || other.formula == formula)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalUzs, totalUzs) || other.totalUzs == totalUzs)&&(identical(other.isApproximate, isApproximate) || other.isApproximate == isApproximate)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.category, category) || other.category == category)&&(identical(other.warning, warning) || other.warning == warning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,label,formula,quantity,unit,unitPrice,totalUzs,isApproximate,storeId,category,warning);
}

@override
String toString() {
    return 'EstimateLine(label: $label, formula: $formula, quantity: $quantity, unit: $unit, unitPrice: $unitPrice, totalUzs: $totalUzs, isApproximate: $isApproximate, storeId: $storeId, category: $category, warning: $warning)';
}


}

/// @nodoc
abstract mixin class _$EstimateLineCopyWith<$Res> implements $EstimateLineCopyWith<$Res> {
  factory _$EstimateLineCopyWith(_EstimateLine value, $Res Function(_EstimateLine) _then) = __$EstimateLineCopyWithImpl;
@override @useResult
$Res call({
 String label, String formula, double quantity, String unit,@JsonKey(name: 'unit_price') int unitPrice,@JsonKey(name: 'total_uzs') int totalUzs,@JsonKey(name: 'is_approximate') bool isApproximate,@JsonKey(name: 'store_id') String? storeId, String category, String? warning
});




}
/// @nodoc
class __$EstimateLineCopyWithImpl<$Res>
    implements _$EstimateLineCopyWith<$Res> {
  __$EstimateLineCopyWithImpl(this._self, this._then);

  final _EstimateLine _self;
  final $Res Function(_EstimateLine) _then;

/// Create a copy of EstimateLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? formula = null,Object? quantity = null,Object? unit = null,Object? unitPrice = null,Object? totalUzs = null,Object? isApproximate = null,Object? storeId = freezed,Object? category = null,Object? warning = freezed,}) {
  return _then(_EstimateLine(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,formula: null == formula ? _self.formula : formula // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int,totalUzs: null == totalUzs ? _self.totalUzs : totalUzs // ignore: cast_nullable_to_non_nullable
as int,isApproximate: null == isApproximate ? _self.isApproximate : isApproximate // ignore: cast_nullable_to_non_nullable
as bool,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Estimate {

 String get id;@JsonKey(name: 'room_id') String get roomId; List<EstimateLine> get lines;@JsonKey(name: 'total_uzs') int get totalUzs;@JsonKey(name: 'total_min') int get totalMin;@JsonKey(name: 'total_max') int get totalMax; String get currency; String get status;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'has_electrical') bool get hasElectrical;/// [totalUzs] split by line precision. Both default to 0 so an estimate
/// persisted before the backend added the split still deserialises.
@JsonKey(name: 'total_exact_uzs') int get totalExactUzs;@JsonKey(name: 'total_approx_uzs') int get totalApproxUzs;/// Whether [hasElectrical] is backed by real placed devices rather than
/// the backend's default-point-count guess.
@JsonKey(name: 'electrical_confirmed') bool get electricalConfirmed;@JsonKey(name: 'usd_rate') double get usdRate;@JsonKey(name: 'total_usd') int get totalUsd;/// The caller is a guest: AI gap-fill and market prices were skipped, so
/// the prices are catalogue/approximate until they sign up.
@JsonKey(name: 'prices_approximate_for_guest') bool get pricesApproximateForGuest;
/// Create a copy of Estimate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EstimateCopyWith<Estimate> get copyWith => _$EstimateCopyWithImpl<Estimate>(this as Estimate, _$identity);

  /// Serializes this Estimate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Estimate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Estimate&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.roomId, _this.roomId) || other.roomId == _this.roomId)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.totalUzs, _this.totalUzs) || other.totalUzs == _this.totalUzs)&&(identical(other.totalMin, _this.totalMin) || other.totalMin == _this.totalMin)&&(identical(other.totalMax, _this.totalMax) || other.totalMax == _this.totalMax)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.hasElectrical, _this.hasElectrical) || other.hasElectrical == _this.hasElectrical)&&(identical(other.totalExactUzs, _this.totalExactUzs) || other.totalExactUzs == _this.totalExactUzs)&&(identical(other.totalApproxUzs, _this.totalApproxUzs) || other.totalApproxUzs == _this.totalApproxUzs)&&(identical(other.electricalConfirmed, _this.electricalConfirmed) || other.electricalConfirmed == _this.electricalConfirmed)&&(identical(other.usdRate, _this.usdRate) || other.usdRate == _this.usdRate)&&(identical(other.totalUsd, _this.totalUsd) || other.totalUsd == _this.totalUsd)&&(identical(other.pricesApproximateForGuest, _this.pricesApproximateForGuest) || other.pricesApproximateForGuest == _this.pricesApproximateForGuest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Estimate;
  return Object.hash(runtimeType,_this.id,_this.roomId,const DeepCollectionEquality().hash(_this.lines),_this.totalUzs,_this.totalMin,_this.totalMax,_this.currency,_this.status,_this.createdAt,_this.hasElectrical,_this.totalExactUzs,_this.totalApproxUzs,_this.electricalConfirmed,_this.usdRate,_this.totalUsd,_this.pricesApproximateForGuest);
}

@override
String toString() {
  final _this = this as Estimate;
  return 'Estimate(id: ${_this.id}, roomId: ${_this.roomId}, lines: ${_this.lines}, totalUzs: ${_this.totalUzs}, totalMin: ${_this.totalMin}, totalMax: ${_this.totalMax}, currency: ${_this.currency}, status: ${_this.status}, createdAt: ${_this.createdAt}, hasElectrical: ${_this.hasElectrical}, totalExactUzs: ${_this.totalExactUzs}, totalApproxUzs: ${_this.totalApproxUzs}, electricalConfirmed: ${_this.electricalConfirmed}, usdRate: ${_this.usdRate}, totalUsd: ${_this.totalUsd}, pricesApproximateForGuest: ${_this.pricesApproximateForGuest})';
}


}

/// @nodoc
abstract mixin class $EstimateCopyWith<$Res>  {
  factory $EstimateCopyWith(Estimate value, $Res Function(Estimate) _then) = _$EstimateCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'room_id') String roomId, List<EstimateLine> lines,@JsonKey(name: 'total_uzs') int totalUzs,@JsonKey(name: 'total_min') int totalMin,@JsonKey(name: 'total_max') int totalMax, String currency, String status,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'has_electrical') bool hasElectrical,@JsonKey(name: 'total_exact_uzs') int totalExactUzs,@JsonKey(name: 'total_approx_uzs') int totalApproxUzs,@JsonKey(name: 'electrical_confirmed') bool electricalConfirmed,@JsonKey(name: 'usd_rate') double usdRate,@JsonKey(name: 'total_usd') int totalUsd,@JsonKey(name: 'prices_approximate_for_guest') bool pricesApproximateForGuest
});




}
/// @nodoc
class _$EstimateCopyWithImpl<$Res>
    implements $EstimateCopyWith<$Res> {
  _$EstimateCopyWithImpl(this._self, this._then);

  final Estimate _self;
  final $Res Function(Estimate) _then;

/// Create a copy of Estimate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? roomId = null,Object? lines = null,Object? totalUzs = null,Object? totalMin = null,Object? totalMax = null,Object? currency = null,Object? status = null,Object? createdAt = null,Object? hasElectrical = null,Object? totalExactUzs = null,Object? totalApproxUzs = null,Object? electricalConfirmed = null,Object? usdRate = null,Object? totalUsd = null,Object? pricesApproximateForGuest = null,}) {
  return _then(Estimate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<EstimateLine>,totalUzs: null == totalUzs ? _self.totalUzs : totalUzs // ignore: cast_nullable_to_non_nullable
as int,totalMin: null == totalMin ? _self.totalMin : totalMin // ignore: cast_nullable_to_non_nullable
as int,totalMax: null == totalMax ? _self.totalMax : totalMax // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,hasElectrical: null == hasElectrical ? _self.hasElectrical : hasElectrical // ignore: cast_nullable_to_non_nullable
as bool,totalExactUzs: null == totalExactUzs ? _self.totalExactUzs : totalExactUzs // ignore: cast_nullable_to_non_nullable
as int,totalApproxUzs: null == totalApproxUzs ? _self.totalApproxUzs : totalApproxUzs // ignore: cast_nullable_to_non_nullable
as int,electricalConfirmed: null == electricalConfirmed ? _self.electricalConfirmed : electricalConfirmed // ignore: cast_nullable_to_non_nullable
as bool,usdRate: null == usdRate ? _self.usdRate : usdRate // ignore: cast_nullable_to_non_nullable
as double,totalUsd: null == totalUsd ? _self.totalUsd : totalUsd // ignore: cast_nullable_to_non_nullable
as int,pricesApproximateForGuest: null == pricesApproximateForGuest ? _self.pricesApproximateForGuest : pricesApproximateForGuest // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Estimate].
extension EstimatePatterns on Estimate {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Estimate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Estimate() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Estimate value)  $default,){
final _that = this;
switch (_that) {
case _Estimate():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Estimate value)?  $default,){
final _that = this;
switch (_that) {
case _Estimate() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'room_id')  String roomId,  List<EstimateLine> lines, @JsonKey(name: 'total_uzs')  int totalUzs, @JsonKey(name: 'total_min')  int totalMin, @JsonKey(name: 'total_max')  int totalMax,  String currency,  String status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'has_electrical')  bool hasElectrical, @JsonKey(name: 'total_exact_uzs')  int totalExactUzs, @JsonKey(name: 'total_approx_uzs')  int totalApproxUzs, @JsonKey(name: 'electrical_confirmed')  bool electricalConfirmed, @JsonKey(name: 'usd_rate')  double usdRate, @JsonKey(name: 'total_usd')  int totalUsd, @JsonKey(name: 'prices_approximate_for_guest')  bool pricesApproximateForGuest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Estimate() when $default != null:
return $default(_that.id,_that.roomId,_that.lines,_that.totalUzs,_that.totalMin,_that.totalMax,_that.currency,_that.status,_that.createdAt,_that.hasElectrical,_that.totalExactUzs,_that.totalApproxUzs,_that.electricalConfirmed,_that.usdRate,_that.totalUsd,_that.pricesApproximateForGuest);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'room_id')  String roomId,  List<EstimateLine> lines, @JsonKey(name: 'total_uzs')  int totalUzs, @JsonKey(name: 'total_min')  int totalMin, @JsonKey(name: 'total_max')  int totalMax,  String currency,  String status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'has_electrical')  bool hasElectrical, @JsonKey(name: 'total_exact_uzs')  int totalExactUzs, @JsonKey(name: 'total_approx_uzs')  int totalApproxUzs, @JsonKey(name: 'electrical_confirmed')  bool electricalConfirmed, @JsonKey(name: 'usd_rate')  double usdRate, @JsonKey(name: 'total_usd')  int totalUsd, @JsonKey(name: 'prices_approximate_for_guest')  bool pricesApproximateForGuest)  $default,) {final _that = this;
switch (_that) {
case _Estimate():
return $default(_that.id,_that.roomId,_that.lines,_that.totalUzs,_that.totalMin,_that.totalMax,_that.currency,_that.status,_that.createdAt,_that.hasElectrical,_that.totalExactUzs,_that.totalApproxUzs,_that.electricalConfirmed,_that.usdRate,_that.totalUsd,_that.pricesApproximateForGuest);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'room_id')  String roomId,  List<EstimateLine> lines, @JsonKey(name: 'total_uzs')  int totalUzs, @JsonKey(name: 'total_min')  int totalMin, @JsonKey(name: 'total_max')  int totalMax,  String currency,  String status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'has_electrical')  bool hasElectrical, @JsonKey(name: 'total_exact_uzs')  int totalExactUzs, @JsonKey(name: 'total_approx_uzs')  int totalApproxUzs, @JsonKey(name: 'electrical_confirmed')  bool electricalConfirmed, @JsonKey(name: 'usd_rate')  double usdRate, @JsonKey(name: 'total_usd')  int totalUsd, @JsonKey(name: 'prices_approximate_for_guest')  bool pricesApproximateForGuest)?  $default,) {final _that = this;
switch (_that) {
case _Estimate() when $default != null:
return $default(_that.id,_that.roomId,_that.lines,_that.totalUzs,_that.totalMin,_that.totalMax,_that.currency,_that.status,_that.createdAt,_that.hasElectrical,_that.totalExactUzs,_that.totalApproxUzs,_that.electricalConfirmed,_that.usdRate,_that.totalUsd,_that.pricesApproximateForGuest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Estimate implements Estimate {
  const _Estimate({required this.id, @JsonKey(name: 'room_id') required this.roomId,  List<EstimateLine> lines = const <EstimateLine>[], @JsonKey(name: 'total_uzs') required this.totalUzs, @JsonKey(name: 'total_min') required this.totalMin, @JsonKey(name: 'total_max') required this.totalMax, this.currency = 'UZS', this.status = 'final', @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'has_electrical') this.hasElectrical = false, @JsonKey(name: 'total_exact_uzs') this.totalExactUzs = 0, @JsonKey(name: 'total_approx_uzs') this.totalApproxUzs = 0, @JsonKey(name: 'electrical_confirmed') this.electricalConfirmed = false, @JsonKey(name: 'usd_rate') this.usdRate = 0.0, @JsonKey(name: 'total_usd') this.totalUsd = 0, @JsonKey(name: 'prices_approximate_for_guest') this.pricesApproximateForGuest = false}): _lines = lines;
  factory _Estimate.fromJson(Map<String, dynamic> json) => _$EstimateFromJson(json);

@override final  String id;
@override@JsonKey(name: 'room_id') final  String roomId;
 final  List<EstimateLine> _lines;
@override@JsonKey() List<EstimateLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override@JsonKey(name: 'total_uzs') final  int totalUzs;
@override@JsonKey(name: 'total_min') final  int totalMin;
@override@JsonKey(name: 'total_max') final  int totalMax;
@override@JsonKey() final  String currency;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'has_electrical') final  bool hasElectrical;
/// [totalUzs] split by line precision. Both default to 0 so an estimate
/// persisted before the backend added the split still deserialises.
@override@JsonKey(name: 'total_exact_uzs') final  int totalExactUzs;
@override@JsonKey(name: 'total_approx_uzs') final  int totalApproxUzs;
/// Whether [hasElectrical] is backed by real placed devices rather than
/// the backend's default-point-count guess.
@override@JsonKey(name: 'electrical_confirmed') final  bool electricalConfirmed;
@override@JsonKey(name: 'usd_rate') final  double usdRate;
@override@JsonKey(name: 'total_usd') final  int totalUsd;
/// The caller is a guest: AI gap-fill and market prices were skipped, so
/// the prices are catalogue/approximate until they sign up.
@override@JsonKey(name: 'prices_approximate_for_guest') final  bool pricesApproximateForGuest;

/// Create a copy of Estimate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EstimateCopyWith<_Estimate> get copyWith => __$EstimateCopyWithImpl<_Estimate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EstimateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Estimate&&(identical(other.id, id) || other.id == id)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.totalUzs, totalUzs) || other.totalUzs == totalUzs)&&(identical(other.totalMin, totalMin) || other.totalMin == totalMin)&&(identical(other.totalMax, totalMax) || other.totalMax == totalMax)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.hasElectrical, hasElectrical) || other.hasElectrical == hasElectrical)&&(identical(other.totalExactUzs, totalExactUzs) || other.totalExactUzs == totalExactUzs)&&(identical(other.totalApproxUzs, totalApproxUzs) || other.totalApproxUzs == totalApproxUzs)&&(identical(other.electricalConfirmed, electricalConfirmed) || other.electricalConfirmed == electricalConfirmed)&&(identical(other.usdRate, usdRate) || other.usdRate == usdRate)&&(identical(other.totalUsd, totalUsd) || other.totalUsd == totalUsd)&&(identical(other.pricesApproximateForGuest, pricesApproximateForGuest) || other.pricesApproximateForGuest == pricesApproximateForGuest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,roomId,const DeepCollectionEquality().hash(_lines),totalUzs,totalMin,totalMax,currency,status,createdAt,hasElectrical,totalExactUzs,totalApproxUzs,electricalConfirmed,usdRate,totalUsd,pricesApproximateForGuest);
}

@override
String toString() {
    return 'Estimate(id: $id, roomId: $roomId, lines: $lines, totalUzs: $totalUzs, totalMin: $totalMin, totalMax: $totalMax, currency: $currency, status: $status, createdAt: $createdAt, hasElectrical: $hasElectrical, totalExactUzs: $totalExactUzs, totalApproxUzs: $totalApproxUzs, electricalConfirmed: $electricalConfirmed, usdRate: $usdRate, totalUsd: $totalUsd, pricesApproximateForGuest: $pricesApproximateForGuest)';
}


}

/// @nodoc
abstract mixin class _$EstimateCopyWith<$Res> implements $EstimateCopyWith<$Res> {
  factory _$EstimateCopyWith(_Estimate value, $Res Function(_Estimate) _then) = __$EstimateCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'room_id') String roomId, List<EstimateLine> lines,@JsonKey(name: 'total_uzs') int totalUzs,@JsonKey(name: 'total_min') int totalMin,@JsonKey(name: 'total_max') int totalMax, String currency, String status,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'has_electrical') bool hasElectrical,@JsonKey(name: 'total_exact_uzs') int totalExactUzs,@JsonKey(name: 'total_approx_uzs') int totalApproxUzs,@JsonKey(name: 'electrical_confirmed') bool electricalConfirmed,@JsonKey(name: 'usd_rate') double usdRate,@JsonKey(name: 'total_usd') int totalUsd,@JsonKey(name: 'prices_approximate_for_guest') bool pricesApproximateForGuest
});




}
/// @nodoc
class __$EstimateCopyWithImpl<$Res>
    implements _$EstimateCopyWith<$Res> {
  __$EstimateCopyWithImpl(this._self, this._then);

  final _Estimate _self;
  final $Res Function(_Estimate) _then;

/// Create a copy of Estimate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? roomId = null,Object? lines = null,Object? totalUzs = null,Object? totalMin = null,Object? totalMax = null,Object? currency = null,Object? status = null,Object? createdAt = null,Object? hasElectrical = null,Object? totalExactUzs = null,Object? totalApproxUzs = null,Object? electricalConfirmed = null,Object? usdRate = null,Object? totalUsd = null,Object? pricesApproximateForGuest = null,}) {
  return _then(_Estimate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<EstimateLine>,totalUzs: null == totalUzs ? _self.totalUzs : totalUzs // ignore: cast_nullable_to_non_nullable
as int,totalMin: null == totalMin ? _self.totalMin : totalMin // ignore: cast_nullable_to_non_nullable
as int,totalMax: null == totalMax ? _self.totalMax : totalMax // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,hasElectrical: null == hasElectrical ? _self.hasElectrical : hasElectrical // ignore: cast_nullable_to_non_nullable
as bool,totalExactUzs: null == totalExactUzs ? _self.totalExactUzs : totalExactUzs // ignore: cast_nullable_to_non_nullable
as int,totalApproxUzs: null == totalApproxUzs ? _self.totalApproxUzs : totalApproxUzs // ignore: cast_nullable_to_non_nullable
as int,electricalConfirmed: null == electricalConfirmed ? _self.electricalConfirmed : electricalConfirmed // ignore: cast_nullable_to_non_nullable
as bool,usdRate: null == usdRate ? _self.usdRate : usdRate // ignore: cast_nullable_to_non_nullable
as double,totalUsd: null == totalUsd ? _self.totalUsd : totalUsd // ignore: cast_nullable_to_non_nullable
as int,pricesApproximateForGuest: null == pricesApproximateForGuest ? _self.pricesApproximateForGuest : pricesApproximateForGuest // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$EstimateSummary {

 String get id;@JsonKey(name: 'room_id') String get roomId;@JsonKey(name: 'total_uzs') int get totalUzs; String get currency; String get status;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of EstimateSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EstimateSummaryCopyWith<EstimateSummary> get copyWith => _$EstimateSummaryCopyWithImpl<EstimateSummary>(this as EstimateSummary, _$identity);

  /// Serializes this EstimateSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EstimateSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EstimateSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.roomId, _this.roomId) || other.roomId == _this.roomId)&&(identical(other.totalUzs, _this.totalUzs) || other.totalUzs == _this.totalUzs)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EstimateSummary;
  return Object.hash(runtimeType,_this.id,_this.roomId,_this.totalUzs,_this.currency,_this.status,_this.createdAt);
}

@override
String toString() {
  final _this = this as EstimateSummary;
  return 'EstimateSummary(id: ${_this.id}, roomId: ${_this.roomId}, totalUzs: ${_this.totalUzs}, currency: ${_this.currency}, status: ${_this.status}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $EstimateSummaryCopyWith<$Res>  {
  factory $EstimateSummaryCopyWith(EstimateSummary value, $Res Function(EstimateSummary) _then) = _$EstimateSummaryCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'room_id') String roomId,@JsonKey(name: 'total_uzs') int totalUzs, String currency, String status,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$EstimateSummaryCopyWithImpl<$Res>
    implements $EstimateSummaryCopyWith<$Res> {
  _$EstimateSummaryCopyWithImpl(this._self, this._then);

  final EstimateSummary _self;
  final $Res Function(EstimateSummary) _then;

/// Create a copy of EstimateSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? roomId = null,Object? totalUzs = null,Object? currency = null,Object? status = null,Object? createdAt = null,}) {
  return _then(EstimateSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,totalUzs: null == totalUzs ? _self.totalUzs : totalUzs // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [EstimateSummary].
extension EstimateSummaryPatterns on EstimateSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EstimateSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EstimateSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EstimateSummary value)  $default,){
final _that = this;
switch (_that) {
case _EstimateSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EstimateSummary value)?  $default,){
final _that = this;
switch (_that) {
case _EstimateSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'room_id')  String roomId, @JsonKey(name: 'total_uzs')  int totalUzs,  String currency,  String status, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EstimateSummary() when $default != null:
return $default(_that.id,_that.roomId,_that.totalUzs,_that.currency,_that.status,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'room_id')  String roomId, @JsonKey(name: 'total_uzs')  int totalUzs,  String currency,  String status, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _EstimateSummary():
return $default(_that.id,_that.roomId,_that.totalUzs,_that.currency,_that.status,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'room_id')  String roomId, @JsonKey(name: 'total_uzs')  int totalUzs,  String currency,  String status, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _EstimateSummary() when $default != null:
return $default(_that.id,_that.roomId,_that.totalUzs,_that.currency,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EstimateSummary implements EstimateSummary {
  const _EstimateSummary({required this.id, @JsonKey(name: 'room_id') required this.roomId, @JsonKey(name: 'total_uzs') required this.totalUzs, required this.currency, required this.status, @JsonKey(name: 'created_at') required this.createdAt});
  factory _EstimateSummary.fromJson(Map<String, dynamic> json) => _$EstimateSummaryFromJson(json);

@override final  String id;
@override@JsonKey(name: 'room_id') final  String roomId;
@override@JsonKey(name: 'total_uzs') final  int totalUzs;
@override final  String currency;
@override final  String status;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of EstimateSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EstimateSummaryCopyWith<_EstimateSummary> get copyWith => __$EstimateSummaryCopyWithImpl<_EstimateSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EstimateSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EstimateSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.totalUzs, totalUzs) || other.totalUzs == totalUzs)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,roomId,totalUzs,currency,status,createdAt);
}

@override
String toString() {
    return 'EstimateSummary(id: $id, roomId: $roomId, totalUzs: $totalUzs, currency: $currency, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$EstimateSummaryCopyWith<$Res> implements $EstimateSummaryCopyWith<$Res> {
  factory _$EstimateSummaryCopyWith(_EstimateSummary value, $Res Function(_EstimateSummary) _then) = __$EstimateSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'room_id') String roomId,@JsonKey(name: 'total_uzs') int totalUzs, String currency, String status,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$EstimateSummaryCopyWithImpl<$Res>
    implements _$EstimateSummaryCopyWith<$Res> {
  __$EstimateSummaryCopyWithImpl(this._self, this._then);

  final _EstimateSummary _self;
  final $Res Function(_EstimateSummary) _then;

/// Create a copy of EstimateSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? roomId = null,Object? totalUzs = null,Object? currency = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_EstimateSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,totalUzs: null == totalUzs ? _self.totalUzs : totalUzs // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$PaginatedEstimates {

 List<EstimateSummary> get items; int get total; int get limit; int get offset;
/// Create a copy of PaginatedEstimates
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginatedEstimatesCopyWith<PaginatedEstimates> get copyWith => _$PaginatedEstimatesCopyWithImpl<PaginatedEstimates>(this as PaginatedEstimates, _$identity);

  /// Serializes this PaginatedEstimates to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PaginatedEstimates;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginatedEstimates&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.limit, _this.limit) || other.limit == _this.limit)&&(identical(other.offset, _this.offset) || other.offset == _this.offset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PaginatedEstimates;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.total,_this.limit,_this.offset);
}

@override
String toString() {
  final _this = this as PaginatedEstimates;
  return 'PaginatedEstimates(items: ${_this.items}, total: ${_this.total}, limit: ${_this.limit}, offset: ${_this.offset})';
}


}

/// @nodoc
abstract mixin class $PaginatedEstimatesCopyWith<$Res>  {
  factory $PaginatedEstimatesCopyWith(PaginatedEstimates value, $Res Function(PaginatedEstimates) _then) = _$PaginatedEstimatesCopyWithImpl;
@useResult
$Res call({
 List<EstimateSummary> items, int total, int limit, int offset
});




}
/// @nodoc
class _$PaginatedEstimatesCopyWithImpl<$Res>
    implements $PaginatedEstimatesCopyWith<$Res> {
  _$PaginatedEstimatesCopyWithImpl(this._self, this._then);

  final PaginatedEstimates _self;
  final $Res Function(PaginatedEstimates) _then;

/// Create a copy of PaginatedEstimates
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,Object? limit = null,Object? offset = null,}) {
  return _then(PaginatedEstimates(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<EstimateSummary>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaginatedEstimates].
extension PaginatedEstimatesPatterns on PaginatedEstimates {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginatedEstimates value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginatedEstimates() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginatedEstimates value)  $default,){
final _that = this;
switch (_that) {
case _PaginatedEstimates():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginatedEstimates value)?  $default,){
final _that = this;
switch (_that) {
case _PaginatedEstimates() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<EstimateSummary> items,  int total,  int limit,  int offset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginatedEstimates() when $default != null:
return $default(_that.items,_that.total,_that.limit,_that.offset);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<EstimateSummary> items,  int total,  int limit,  int offset)  $default,) {final _that = this;
switch (_that) {
case _PaginatedEstimates():
return $default(_that.items,_that.total,_that.limit,_that.offset);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<EstimateSummary> items,  int total,  int limit,  int offset)?  $default,) {final _that = this;
switch (_that) {
case _PaginatedEstimates() when $default != null:
return $default(_that.items,_that.total,_that.limit,_that.offset);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaginatedEstimates implements PaginatedEstimates {
  const _PaginatedEstimates({ List<EstimateSummary> items = const <EstimateSummary>[], this.total = 0, this.limit = 20, this.offset = 0}): _items = items;
  factory _PaginatedEstimates.fromJson(Map<String, dynamic> json) => _$PaginatedEstimatesFromJson(json);

 final  List<EstimateSummary> _items;
@override@JsonKey() List<EstimateSummary> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int total;
@override@JsonKey() final  int limit;
@override@JsonKey() final  int offset;

/// Create a copy of PaginatedEstimates
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginatedEstimatesCopyWith<_PaginatedEstimates> get copyWith => __$PaginatedEstimatesCopyWithImpl<_PaginatedEstimates>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaginatedEstimatesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginatedEstimates&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.offset, offset) || other.offset == offset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,limit,offset);
}

@override
String toString() {
    return 'PaginatedEstimates(items: $items, total: $total, limit: $limit, offset: $offset)';
}


}

/// @nodoc
abstract mixin class _$PaginatedEstimatesCopyWith<$Res> implements $PaginatedEstimatesCopyWith<$Res> {
  factory _$PaginatedEstimatesCopyWith(_PaginatedEstimates value, $Res Function(_PaginatedEstimates) _then) = __$PaginatedEstimatesCopyWithImpl;
@override @useResult
$Res call({
 List<EstimateSummary> items, int total, int limit, int offset
});




}
/// @nodoc
class __$PaginatedEstimatesCopyWithImpl<$Res>
    implements _$PaginatedEstimatesCopyWith<$Res> {
  __$PaginatedEstimatesCopyWithImpl(this._self, this._then);

  final _PaginatedEstimates _self;
  final $Res Function(_PaginatedEstimates) _then;

/// Create a copy of PaginatedEstimates
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? limit = null,Object? offset = null,}) {
  return _then(_PaginatedEstimates(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<EstimateSummary>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
