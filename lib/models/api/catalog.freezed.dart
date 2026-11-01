// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Material {

 String get id;@JsonKey(name: 'store_id') String get storeId; String get category;@JsonKey(name: 'name_uz') String get nameUz; String get unit;@JsonKey(name: 'price_uzs') int get priceUzs;@JsonKey(name: 'color_hex') String? get colorHex;@JsonKey(name: 'texture_key') String? get textureKey;@JsonKey(name: 'pbr_roughness') double get pbrRoughness;@JsonKey(name: 'image_url') String? get imageUrl;
/// Create a copy of Material
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaterialCopyWith<Material> get copyWith => _$MaterialCopyWithImpl<Material>(this as Material, _$identity);

  /// Serializes this Material to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Material;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Material&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.storeId, _this.storeId) || other.storeId == _this.storeId)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.nameUz, _this.nameUz) || other.nameUz == _this.nameUz)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.priceUzs, _this.priceUzs) || other.priceUzs == _this.priceUzs)&&(identical(other.colorHex, _this.colorHex) || other.colorHex == _this.colorHex)&&(identical(other.textureKey, _this.textureKey) || other.textureKey == _this.textureKey)&&(identical(other.pbrRoughness, _this.pbrRoughness) || other.pbrRoughness == _this.pbrRoughness)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Material;
  return Object.hash(runtimeType,_this.id,_this.storeId,_this.category,_this.nameUz,_this.unit,_this.priceUzs,_this.colorHex,_this.textureKey,_this.pbrRoughness,_this.imageUrl);
}

@override
String toString() {
  final _this = this as Material;
  return 'Material(id: ${_this.id}, storeId: ${_this.storeId}, category: ${_this.category}, nameUz: ${_this.nameUz}, unit: ${_this.unit}, priceUzs: ${_this.priceUzs}, colorHex: ${_this.colorHex}, textureKey: ${_this.textureKey}, pbrRoughness: ${_this.pbrRoughness}, imageUrl: ${_this.imageUrl})';
}


}

/// @nodoc
abstract mixin class $MaterialCopyWith<$Res>  {
  factory $MaterialCopyWith(Material value, $Res Function(Material) _then) = _$MaterialCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'store_id') String storeId, String category,@JsonKey(name: 'name_uz') String nameUz, String unit,@JsonKey(name: 'price_uzs') int priceUzs,@JsonKey(name: 'color_hex') String? colorHex,@JsonKey(name: 'texture_key') String? textureKey,@JsonKey(name: 'pbr_roughness') double pbrRoughness,@JsonKey(name: 'image_url') String? imageUrl
});




}
/// @nodoc
class _$MaterialCopyWithImpl<$Res>
    implements $MaterialCopyWith<$Res> {
  _$MaterialCopyWithImpl(this._self, this._then);

  final Material _self;
  final $Res Function(Material) _then;

/// Create a copy of Material
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeId = null,Object? category = null,Object? nameUz = null,Object? unit = null,Object? priceUzs = null,Object? colorHex = freezed,Object? textureKey = freezed,Object? pbrRoughness = null,Object? imageUrl = freezed,}) {
  return _then(Material(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,nameUz: null == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,priceUzs: null == priceUzs ? _self.priceUzs : priceUzs // ignore: cast_nullable_to_non_nullable
as int,colorHex: freezed == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String?,textureKey: freezed == textureKey ? _self.textureKey : textureKey // ignore: cast_nullable_to_non_nullable
as String?,pbrRoughness: null == pbrRoughness ? _self.pbrRoughness : pbrRoughness // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Material].
extension MaterialPatterns on Material {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Material value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Material() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Material value)  $default,){
final _that = this;
switch (_that) {
case _Material():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Material value)?  $default,){
final _that = this;
switch (_that) {
case _Material() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'store_id')  String storeId,  String category, @JsonKey(name: 'name_uz')  String nameUz,  String unit, @JsonKey(name: 'price_uzs')  int priceUzs, @JsonKey(name: 'color_hex')  String? colorHex, @JsonKey(name: 'texture_key')  String? textureKey, @JsonKey(name: 'pbr_roughness')  double pbrRoughness, @JsonKey(name: 'image_url')  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Material() when $default != null:
return $default(_that.id,_that.storeId,_that.category,_that.nameUz,_that.unit,_that.priceUzs,_that.colorHex,_that.textureKey,_that.pbrRoughness,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'store_id')  String storeId,  String category, @JsonKey(name: 'name_uz')  String nameUz,  String unit, @JsonKey(name: 'price_uzs')  int priceUzs, @JsonKey(name: 'color_hex')  String? colorHex, @JsonKey(name: 'texture_key')  String? textureKey, @JsonKey(name: 'pbr_roughness')  double pbrRoughness, @JsonKey(name: 'image_url')  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _Material():
return $default(_that.id,_that.storeId,_that.category,_that.nameUz,_that.unit,_that.priceUzs,_that.colorHex,_that.textureKey,_that.pbrRoughness,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'store_id')  String storeId,  String category, @JsonKey(name: 'name_uz')  String nameUz,  String unit, @JsonKey(name: 'price_uzs')  int priceUzs, @JsonKey(name: 'color_hex')  String? colorHex, @JsonKey(name: 'texture_key')  String? textureKey, @JsonKey(name: 'pbr_roughness')  double pbrRoughness, @JsonKey(name: 'image_url')  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _Material() when $default != null:
return $default(_that.id,_that.storeId,_that.category,_that.nameUz,_that.unit,_that.priceUzs,_that.colorHex,_that.textureKey,_that.pbrRoughness,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Material implements Material {
  const _Material({required this.id, @JsonKey(name: 'store_id') required this.storeId, required this.category, @JsonKey(name: 'name_uz') required this.nameUz, required this.unit, @JsonKey(name: 'price_uzs') required this.priceUzs, @JsonKey(name: 'color_hex') this.colorHex, @JsonKey(name: 'texture_key') this.textureKey, @JsonKey(name: 'pbr_roughness') this.pbrRoughness = 1.0, @JsonKey(name: 'image_url') this.imageUrl});
  factory _Material.fromJson(Map<String, dynamic> json) => _$MaterialFromJson(json);

@override final  String id;
@override@JsonKey(name: 'store_id') final  String storeId;
@override final  String category;
@override@JsonKey(name: 'name_uz') final  String nameUz;
@override final  String unit;
@override@JsonKey(name: 'price_uzs') final  int priceUzs;
@override@JsonKey(name: 'color_hex') final  String? colorHex;
@override@JsonKey(name: 'texture_key') final  String? textureKey;
@override@JsonKey(name: 'pbr_roughness') final  double pbrRoughness;
@override@JsonKey(name: 'image_url') final  String? imageUrl;

/// Create a copy of Material
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaterialCopyWith<_Material> get copyWith => __$MaterialCopyWithImpl<_Material>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaterialToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Material&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.category, category) || other.category == category)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.priceUzs, priceUzs) || other.priceUzs == priceUzs)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.textureKey, textureKey) || other.textureKey == textureKey)&&(identical(other.pbrRoughness, pbrRoughness) || other.pbrRoughness == pbrRoughness)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,storeId,category,nameUz,unit,priceUzs,colorHex,textureKey,pbrRoughness,imageUrl);
}

@override
String toString() {
    return 'Material(id: $id, storeId: $storeId, category: $category, nameUz: $nameUz, unit: $unit, priceUzs: $priceUzs, colorHex: $colorHex, textureKey: $textureKey, pbrRoughness: $pbrRoughness, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$MaterialCopyWith<$Res> implements $MaterialCopyWith<$Res> {
  factory _$MaterialCopyWith(_Material value, $Res Function(_Material) _then) = __$MaterialCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'store_id') String storeId, String category,@JsonKey(name: 'name_uz') String nameUz, String unit,@JsonKey(name: 'price_uzs') int priceUzs,@JsonKey(name: 'color_hex') String? colorHex,@JsonKey(name: 'texture_key') String? textureKey,@JsonKey(name: 'pbr_roughness') double pbrRoughness,@JsonKey(name: 'image_url') String? imageUrl
});




}
/// @nodoc
class __$MaterialCopyWithImpl<$Res>
    implements _$MaterialCopyWith<$Res> {
  __$MaterialCopyWithImpl(this._self, this._then);

  final _Material _self;
  final $Res Function(_Material) _then;

/// Create a copy of Material
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeId = null,Object? category = null,Object? nameUz = null,Object? unit = null,Object? priceUzs = null,Object? colorHex = freezed,Object? textureKey = freezed,Object? pbrRoughness = null,Object? imageUrl = freezed,}) {
  return _then(_Material(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,nameUz: null == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,priceUzs: null == priceUzs ? _self.priceUzs : priceUzs // ignore: cast_nullable_to_non_nullable
as int,colorHex: freezed == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String?,textureKey: freezed == textureKey ? _self.textureKey : textureKey // ignore: cast_nullable_to_non_nullable
as String?,pbrRoughness: null == pbrRoughness ? _self.pbrRoughness : pbrRoughness // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PaginatedMaterials {

 List<Material> get items; int get total; int get page;@JsonKey(name: 'per_page') int get perPage;
/// Create a copy of PaginatedMaterials
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginatedMaterialsCopyWith<PaginatedMaterials> get copyWith => _$PaginatedMaterialsCopyWithImpl<PaginatedMaterials>(this as PaginatedMaterials, _$identity);

  /// Serializes this PaginatedMaterials to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PaginatedMaterials;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginatedMaterials&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.perPage, _this.perPage) || other.perPage == _this.perPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PaginatedMaterials;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.total,_this.page,_this.perPage);
}

@override
String toString() {
  final _this = this as PaginatedMaterials;
  return 'PaginatedMaterials(items: ${_this.items}, total: ${_this.total}, page: ${_this.page}, perPage: ${_this.perPage})';
}


}

/// @nodoc
abstract mixin class $PaginatedMaterialsCopyWith<$Res>  {
  factory $PaginatedMaterialsCopyWith(PaginatedMaterials value, $Res Function(PaginatedMaterials) _then) = _$PaginatedMaterialsCopyWithImpl;
@useResult
$Res call({
 List<Material> items, int total, int page,@JsonKey(name: 'per_page') int perPage
});




}
/// @nodoc
class _$PaginatedMaterialsCopyWithImpl<$Res>
    implements $PaginatedMaterialsCopyWith<$Res> {
  _$PaginatedMaterialsCopyWithImpl(this._self, this._then);

  final PaginatedMaterials _self;
  final $Res Function(PaginatedMaterials) _then;

/// Create a copy of PaginatedMaterials
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,Object? page = null,Object? perPage = null,}) {
  return _then(PaginatedMaterials(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Material>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,perPage: null == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaginatedMaterials].
extension PaginatedMaterialsPatterns on PaginatedMaterials {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginatedMaterials value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginatedMaterials() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginatedMaterials value)  $default,){
final _that = this;
switch (_that) {
case _PaginatedMaterials():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginatedMaterials value)?  $default,){
final _that = this;
switch (_that) {
case _PaginatedMaterials() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Material> items,  int total,  int page, @JsonKey(name: 'per_page')  int perPage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginatedMaterials() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.perPage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Material> items,  int total,  int page, @JsonKey(name: 'per_page')  int perPage)  $default,) {final _that = this;
switch (_that) {
case _PaginatedMaterials():
return $default(_that.items,_that.total,_that.page,_that.perPage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Material> items,  int total,  int page, @JsonKey(name: 'per_page')  int perPage)?  $default,) {final _that = this;
switch (_that) {
case _PaginatedMaterials() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.perPage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaginatedMaterials implements PaginatedMaterials {
  const _PaginatedMaterials({ List<Material> items = const <Material>[], this.total = 0, this.page = 1, @JsonKey(name: 'per_page') this.perPage = 20}): _items = items;
  factory _PaginatedMaterials.fromJson(Map<String, dynamic> json) => _$PaginatedMaterialsFromJson(json);

 final  List<Material> _items;
@override@JsonKey() List<Material> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int total;
@override@JsonKey() final  int page;
@override@JsonKey(name: 'per_page') final  int perPage;

/// Create a copy of PaginatedMaterials
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginatedMaterialsCopyWith<_PaginatedMaterials> get copyWith => __$PaginatedMaterialsCopyWithImpl<_PaginatedMaterials>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaginatedMaterialsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginatedMaterials&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.perPage, perPage) || other.perPage == perPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,page,perPage);
}

@override
String toString() {
    return 'PaginatedMaterials(items: $items, total: $total, page: $page, perPage: $perPage)';
}


}

/// @nodoc
abstract mixin class _$PaginatedMaterialsCopyWith<$Res> implements $PaginatedMaterialsCopyWith<$Res> {
  factory _$PaginatedMaterialsCopyWith(_PaginatedMaterials value, $Res Function(_PaginatedMaterials) _then) = __$PaginatedMaterialsCopyWithImpl;
@override @useResult
$Res call({
 List<Material> items, int total, int page,@JsonKey(name: 'per_page') int perPage
});




}
/// @nodoc
class __$PaginatedMaterialsCopyWithImpl<$Res>
    implements _$PaginatedMaterialsCopyWith<$Res> {
  __$PaginatedMaterialsCopyWithImpl(this._self, this._then);

  final _PaginatedMaterials _self;
  final $Res Function(_PaginatedMaterials) _then;

/// Create a copy of PaginatedMaterials
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? page = null,Object? perPage = null,}) {
  return _then(_PaginatedMaterials(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Material>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,perPage: null == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Furniture {

 String get id;@JsonKey(name: 'store_id') String? get storeId;@JsonKey(name: 'store_name') String? get storeName; String get category;@JsonKey(name: 'name_uz') String get nameUz;@JsonKey(name: 'price_uzs') int? get priceUzs;@JsonKey(name: 'glb_url') String? get glbUrl;@JsonKey(name: 'thumbnail_url') String? get thumbnailUrl;@JsonKey(name: 'footprint_w') double? get footprintW;@JsonKey(name: 'footprint_d') double? get footprintD;@JsonKey(name: 'height_cm') double? get heightCm;
/// Create a copy of Furniture
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FurnitureCopyWith<Furniture> get copyWith => _$FurnitureCopyWithImpl<Furniture>(this as Furniture, _$identity);

  /// Serializes this Furniture to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Furniture;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Furniture&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.storeId, _this.storeId) || other.storeId == _this.storeId)&&(identical(other.storeName, _this.storeName) || other.storeName == _this.storeName)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.nameUz, _this.nameUz) || other.nameUz == _this.nameUz)&&(identical(other.priceUzs, _this.priceUzs) || other.priceUzs == _this.priceUzs)&&(identical(other.glbUrl, _this.glbUrl) || other.glbUrl == _this.glbUrl)&&(identical(other.thumbnailUrl, _this.thumbnailUrl) || other.thumbnailUrl == _this.thumbnailUrl)&&(identical(other.footprintW, _this.footprintW) || other.footprintW == _this.footprintW)&&(identical(other.footprintD, _this.footprintD) || other.footprintD == _this.footprintD)&&(identical(other.heightCm, _this.heightCm) || other.heightCm == _this.heightCm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Furniture;
  return Object.hash(runtimeType,_this.id,_this.storeId,_this.storeName,_this.category,_this.nameUz,_this.priceUzs,_this.glbUrl,_this.thumbnailUrl,_this.footprintW,_this.footprintD,_this.heightCm);
}

@override
String toString() {
  final _this = this as Furniture;
  return 'Furniture(id: ${_this.id}, storeId: ${_this.storeId}, storeName: ${_this.storeName}, category: ${_this.category}, nameUz: ${_this.nameUz}, priceUzs: ${_this.priceUzs}, glbUrl: ${_this.glbUrl}, thumbnailUrl: ${_this.thumbnailUrl}, footprintW: ${_this.footprintW}, footprintD: ${_this.footprintD}, heightCm: ${_this.heightCm})';
}


}

/// @nodoc
abstract mixin class $FurnitureCopyWith<$Res>  {
  factory $FurnitureCopyWith(Furniture value, $Res Function(Furniture) _then) = _$FurnitureCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'store_id') String? storeId,@JsonKey(name: 'store_name') String? storeName, String category,@JsonKey(name: 'name_uz') String nameUz,@JsonKey(name: 'price_uzs') int? priceUzs,@JsonKey(name: 'glb_url') String? glbUrl,@JsonKey(name: 'thumbnail_url') String? thumbnailUrl,@JsonKey(name: 'footprint_w') double? footprintW,@JsonKey(name: 'footprint_d') double? footprintD,@JsonKey(name: 'height_cm') double? heightCm
});




}
/// @nodoc
class _$FurnitureCopyWithImpl<$Res>
    implements $FurnitureCopyWith<$Res> {
  _$FurnitureCopyWithImpl(this._self, this._then);

  final Furniture _self;
  final $Res Function(Furniture) _then;

/// Create a copy of Furniture
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeId = freezed,Object? storeName = freezed,Object? category = null,Object? nameUz = null,Object? priceUzs = freezed,Object? glbUrl = freezed,Object? thumbnailUrl = freezed,Object? footprintW = freezed,Object? footprintD = freezed,Object? heightCm = freezed,}) {
  return _then(Furniture(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String?,storeName: freezed == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,nameUz: null == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String,priceUzs: freezed == priceUzs ? _self.priceUzs : priceUzs // ignore: cast_nullable_to_non_nullable
as int?,glbUrl: freezed == glbUrl ? _self.glbUrl : glbUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,footprintW: freezed == footprintW ? _self.footprintW : footprintW // ignore: cast_nullable_to_non_nullable
as double?,footprintD: freezed == footprintD ? _self.footprintD : footprintD // ignore: cast_nullable_to_non_nullable
as double?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [Furniture].
extension FurniturePatterns on Furniture {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Furniture value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Furniture() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Furniture value)  $default,){
final _that = this;
switch (_that) {
case _Furniture():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Furniture value)?  $default,){
final _that = this;
switch (_that) {
case _Furniture() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'store_id')  String? storeId, @JsonKey(name: 'store_name')  String? storeName,  String category, @JsonKey(name: 'name_uz')  String nameUz, @JsonKey(name: 'price_uzs')  int? priceUzs, @JsonKey(name: 'glb_url')  String? glbUrl, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'footprint_w')  double? footprintW, @JsonKey(name: 'footprint_d')  double? footprintD, @JsonKey(name: 'height_cm')  double? heightCm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Furniture() when $default != null:
return $default(_that.id,_that.storeId,_that.storeName,_that.category,_that.nameUz,_that.priceUzs,_that.glbUrl,_that.thumbnailUrl,_that.footprintW,_that.footprintD,_that.heightCm);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'store_id')  String? storeId, @JsonKey(name: 'store_name')  String? storeName,  String category, @JsonKey(name: 'name_uz')  String nameUz, @JsonKey(name: 'price_uzs')  int? priceUzs, @JsonKey(name: 'glb_url')  String? glbUrl, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'footprint_w')  double? footprintW, @JsonKey(name: 'footprint_d')  double? footprintD, @JsonKey(name: 'height_cm')  double? heightCm)  $default,) {final _that = this;
switch (_that) {
case _Furniture():
return $default(_that.id,_that.storeId,_that.storeName,_that.category,_that.nameUz,_that.priceUzs,_that.glbUrl,_that.thumbnailUrl,_that.footprintW,_that.footprintD,_that.heightCm);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'store_id')  String? storeId, @JsonKey(name: 'store_name')  String? storeName,  String category, @JsonKey(name: 'name_uz')  String nameUz, @JsonKey(name: 'price_uzs')  int? priceUzs, @JsonKey(name: 'glb_url')  String? glbUrl, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'footprint_w')  double? footprintW, @JsonKey(name: 'footprint_d')  double? footprintD, @JsonKey(name: 'height_cm')  double? heightCm)?  $default,) {final _that = this;
switch (_that) {
case _Furniture() when $default != null:
return $default(_that.id,_that.storeId,_that.storeName,_that.category,_that.nameUz,_that.priceUzs,_that.glbUrl,_that.thumbnailUrl,_that.footprintW,_that.footprintD,_that.heightCm);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Furniture implements Furniture {
  const _Furniture({required this.id, @JsonKey(name: 'store_id') this.storeId, @JsonKey(name: 'store_name') this.storeName, required this.category, @JsonKey(name: 'name_uz') required this.nameUz, @JsonKey(name: 'price_uzs') this.priceUzs, @JsonKey(name: 'glb_url') this.glbUrl, @JsonKey(name: 'thumbnail_url') this.thumbnailUrl, @JsonKey(name: 'footprint_w') this.footprintW, @JsonKey(name: 'footprint_d') this.footprintD, @JsonKey(name: 'height_cm') this.heightCm});
  factory _Furniture.fromJson(Map<String, dynamic> json) => _$FurnitureFromJson(json);

@override final  String id;
@override@JsonKey(name: 'store_id') final  String? storeId;
@override@JsonKey(name: 'store_name') final  String? storeName;
@override final  String category;
@override@JsonKey(name: 'name_uz') final  String nameUz;
@override@JsonKey(name: 'price_uzs') final  int? priceUzs;
@override@JsonKey(name: 'glb_url') final  String? glbUrl;
@override@JsonKey(name: 'thumbnail_url') final  String? thumbnailUrl;
@override@JsonKey(name: 'footprint_w') final  double? footprintW;
@override@JsonKey(name: 'footprint_d') final  double? footprintD;
@override@JsonKey(name: 'height_cm') final  double? heightCm;

/// Create a copy of Furniture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FurnitureCopyWith<_Furniture> get copyWith => __$FurnitureCopyWithImpl<_Furniture>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FurnitureToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Furniture&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.category, category) || other.category == category)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.priceUzs, priceUzs) || other.priceUzs == priceUzs)&&(identical(other.glbUrl, glbUrl) || other.glbUrl == glbUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.footprintW, footprintW) || other.footprintW == footprintW)&&(identical(other.footprintD, footprintD) || other.footprintD == footprintD)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,storeId,storeName,category,nameUz,priceUzs,glbUrl,thumbnailUrl,footprintW,footprintD,heightCm);
}

@override
String toString() {
    return 'Furniture(id: $id, storeId: $storeId, storeName: $storeName, category: $category, nameUz: $nameUz, priceUzs: $priceUzs, glbUrl: $glbUrl, thumbnailUrl: $thumbnailUrl, footprintW: $footprintW, footprintD: $footprintD, heightCm: $heightCm)';
}


}

/// @nodoc
abstract mixin class _$FurnitureCopyWith<$Res> implements $FurnitureCopyWith<$Res> {
  factory _$FurnitureCopyWith(_Furniture value, $Res Function(_Furniture) _then) = __$FurnitureCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'store_id') String? storeId,@JsonKey(name: 'store_name') String? storeName, String category,@JsonKey(name: 'name_uz') String nameUz,@JsonKey(name: 'price_uzs') int? priceUzs,@JsonKey(name: 'glb_url') String? glbUrl,@JsonKey(name: 'thumbnail_url') String? thumbnailUrl,@JsonKey(name: 'footprint_w') double? footprintW,@JsonKey(name: 'footprint_d') double? footprintD,@JsonKey(name: 'height_cm') double? heightCm
});




}
/// @nodoc
class __$FurnitureCopyWithImpl<$Res>
    implements _$FurnitureCopyWith<$Res> {
  __$FurnitureCopyWithImpl(this._self, this._then);

  final _Furniture _self;
  final $Res Function(_Furniture) _then;

/// Create a copy of Furniture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeId = freezed,Object? storeName = freezed,Object? category = null,Object? nameUz = null,Object? priceUzs = freezed,Object? glbUrl = freezed,Object? thumbnailUrl = freezed,Object? footprintW = freezed,Object? footprintD = freezed,Object? heightCm = freezed,}) {
  return _then(_Furniture(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String?,storeName: freezed == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,nameUz: null == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String,priceUzs: freezed == priceUzs ? _self.priceUzs : priceUzs // ignore: cast_nullable_to_non_nullable
as int?,glbUrl: freezed == glbUrl ? _self.glbUrl : glbUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,footprintW: freezed == footprintW ? _self.footprintW : footprintW // ignore: cast_nullable_to_non_nullable
as double?,footprintD: freezed == footprintD ? _self.footprintD : footprintD // ignore: cast_nullable_to_non_nullable
as double?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$PaginatedFurniture {

 List<Furniture> get items; int get total; int get page;@JsonKey(name: 'per_page') int get perPage;
/// Create a copy of PaginatedFurniture
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginatedFurnitureCopyWith<PaginatedFurniture> get copyWith => _$PaginatedFurnitureCopyWithImpl<PaginatedFurniture>(this as PaginatedFurniture, _$identity);

  /// Serializes this PaginatedFurniture to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PaginatedFurniture;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginatedFurniture&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.perPage, _this.perPage) || other.perPage == _this.perPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PaginatedFurniture;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.total,_this.page,_this.perPage);
}

@override
String toString() {
  final _this = this as PaginatedFurniture;
  return 'PaginatedFurniture(items: ${_this.items}, total: ${_this.total}, page: ${_this.page}, perPage: ${_this.perPage})';
}


}

/// @nodoc
abstract mixin class $PaginatedFurnitureCopyWith<$Res>  {
  factory $PaginatedFurnitureCopyWith(PaginatedFurniture value, $Res Function(PaginatedFurniture) _then) = _$PaginatedFurnitureCopyWithImpl;
@useResult
$Res call({
 List<Furniture> items, int total, int page,@JsonKey(name: 'per_page') int perPage
});




}
/// @nodoc
class _$PaginatedFurnitureCopyWithImpl<$Res>
    implements $PaginatedFurnitureCopyWith<$Res> {
  _$PaginatedFurnitureCopyWithImpl(this._self, this._then);

  final PaginatedFurniture _self;
  final $Res Function(PaginatedFurniture) _then;

/// Create a copy of PaginatedFurniture
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,Object? page = null,Object? perPage = null,}) {
  return _then(PaginatedFurniture(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Furniture>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,perPage: null == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaginatedFurniture].
extension PaginatedFurniturePatterns on PaginatedFurniture {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginatedFurniture value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginatedFurniture() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginatedFurniture value)  $default,){
final _that = this;
switch (_that) {
case _PaginatedFurniture():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginatedFurniture value)?  $default,){
final _that = this;
switch (_that) {
case _PaginatedFurniture() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Furniture> items,  int total,  int page, @JsonKey(name: 'per_page')  int perPage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginatedFurniture() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.perPage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Furniture> items,  int total,  int page, @JsonKey(name: 'per_page')  int perPage)  $default,) {final _that = this;
switch (_that) {
case _PaginatedFurniture():
return $default(_that.items,_that.total,_that.page,_that.perPage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Furniture> items,  int total,  int page, @JsonKey(name: 'per_page')  int perPage)?  $default,) {final _that = this;
switch (_that) {
case _PaginatedFurniture() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.perPage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaginatedFurniture implements PaginatedFurniture {
  const _PaginatedFurniture({ List<Furniture> items = const <Furniture>[], this.total = 0, this.page = 1, @JsonKey(name: 'per_page') this.perPage = 20}): _items = items;
  factory _PaginatedFurniture.fromJson(Map<String, dynamic> json) => _$PaginatedFurnitureFromJson(json);

 final  List<Furniture> _items;
@override@JsonKey() List<Furniture> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int total;
@override@JsonKey() final  int page;
@override@JsonKey(name: 'per_page') final  int perPage;

/// Create a copy of PaginatedFurniture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginatedFurnitureCopyWith<_PaginatedFurniture> get copyWith => __$PaginatedFurnitureCopyWithImpl<_PaginatedFurniture>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaginatedFurnitureToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginatedFurniture&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.perPage, perPage) || other.perPage == perPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,page,perPage);
}

@override
String toString() {
    return 'PaginatedFurniture(items: $items, total: $total, page: $page, perPage: $perPage)';
}


}

/// @nodoc
abstract mixin class _$PaginatedFurnitureCopyWith<$Res> implements $PaginatedFurnitureCopyWith<$Res> {
  factory _$PaginatedFurnitureCopyWith(_PaginatedFurniture value, $Res Function(_PaginatedFurniture) _then) = __$PaginatedFurnitureCopyWithImpl;
@override @useResult
$Res call({
 List<Furniture> items, int total, int page,@JsonKey(name: 'per_page') int perPage
});




}
/// @nodoc
class __$PaginatedFurnitureCopyWithImpl<$Res>
    implements _$PaginatedFurnitureCopyWith<$Res> {
  __$PaginatedFurnitureCopyWithImpl(this._self, this._then);

  final _PaginatedFurniture _self;
  final $Res Function(_PaginatedFurniture) _then;

/// Create a copy of PaginatedFurniture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? page = null,Object? perPage = null,}) {
  return _then(_PaginatedFurniture(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Furniture>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,perPage: null == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Store {

 String get id; String get name; String? get district; String? get phone; String? get telegram;@JsonKey(name: 'logo_color') String? get logoColor;@JsonKey(name: 'partner_tier') String get partnerTier;
/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreCopyWith<Store> get copyWith => _$StoreCopyWithImpl<Store>(this as Store, _$identity);

  /// Serializes this Store to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Store;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Store&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.district, _this.district) || other.district == _this.district)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.telegram, _this.telegram) || other.telegram == _this.telegram)&&(identical(other.logoColor, _this.logoColor) || other.logoColor == _this.logoColor)&&(identical(other.partnerTier, _this.partnerTier) || other.partnerTier == _this.partnerTier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Store;
  return Object.hash(runtimeType,_this.id,_this.name,_this.district,_this.phone,_this.telegram,_this.logoColor,_this.partnerTier);
}

@override
String toString() {
  final _this = this as Store;
  return 'Store(id: ${_this.id}, name: ${_this.name}, district: ${_this.district}, phone: ${_this.phone}, telegram: ${_this.telegram}, logoColor: ${_this.logoColor}, partnerTier: ${_this.partnerTier})';
}


}

/// @nodoc
abstract mixin class $StoreCopyWith<$Res>  {
  factory $StoreCopyWith(Store value, $Res Function(Store) _then) = _$StoreCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? district, String? phone, String? telegram,@JsonKey(name: 'logo_color') String? logoColor,@JsonKey(name: 'partner_tier') String partnerTier
});




}
/// @nodoc
class _$StoreCopyWithImpl<$Res>
    implements $StoreCopyWith<$Res> {
  _$StoreCopyWithImpl(this._self, this._then);

  final Store _self;
  final $Res Function(Store) _then;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? district = freezed,Object? phone = freezed,Object? telegram = freezed,Object? logoColor = freezed,Object? partnerTier = null,}) {
  return _then(Store(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,telegram: freezed == telegram ? _self.telegram : telegram // ignore: cast_nullable_to_non_nullable
as String?,logoColor: freezed == logoColor ? _self.logoColor : logoColor // ignore: cast_nullable_to_non_nullable
as String?,partnerTier: null == partnerTier ? _self.partnerTier : partnerTier // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Store].
extension StorePatterns on Store {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Store value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Store() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Store value)  $default,){
final _that = this;
switch (_that) {
case _Store():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Store value)?  $default,){
final _that = this;
switch (_that) {
case _Store() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? district,  String? phone,  String? telegram, @JsonKey(name: 'logo_color')  String? logoColor, @JsonKey(name: 'partner_tier')  String partnerTier)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Store() when $default != null:
return $default(_that.id,_that.name,_that.district,_that.phone,_that.telegram,_that.logoColor,_that.partnerTier);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? district,  String? phone,  String? telegram, @JsonKey(name: 'logo_color')  String? logoColor, @JsonKey(name: 'partner_tier')  String partnerTier)  $default,) {final _that = this;
switch (_that) {
case _Store():
return $default(_that.id,_that.name,_that.district,_that.phone,_that.telegram,_that.logoColor,_that.partnerTier);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? district,  String? phone,  String? telegram, @JsonKey(name: 'logo_color')  String? logoColor, @JsonKey(name: 'partner_tier')  String partnerTier)?  $default,) {final _that = this;
switch (_that) {
case _Store() when $default != null:
return $default(_that.id,_that.name,_that.district,_that.phone,_that.telegram,_that.logoColor,_that.partnerTier);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Store implements Store {
  const _Store({required this.id, required this.name, this.district, this.phone, this.telegram, @JsonKey(name: 'logo_color') this.logoColor, @JsonKey(name: 'partner_tier') required this.partnerTier});
  factory _Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? district;
@override final  String? phone;
@override final  String? telegram;
@override@JsonKey(name: 'logo_color') final  String? logoColor;
@override@JsonKey(name: 'partner_tier') final  String partnerTier;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreCopyWith<_Store> get copyWith => __$StoreCopyWithImpl<_Store>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoreToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Store&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.district, district) || other.district == district)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.telegram, telegram) || other.telegram == telegram)&&(identical(other.logoColor, logoColor) || other.logoColor == logoColor)&&(identical(other.partnerTier, partnerTier) || other.partnerTier == partnerTier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,district,phone,telegram,logoColor,partnerTier);
}

@override
String toString() {
    return 'Store(id: $id, name: $name, district: $district, phone: $phone, telegram: $telegram, logoColor: $logoColor, partnerTier: $partnerTier)';
}


}

/// @nodoc
abstract mixin class _$StoreCopyWith<$Res> implements $StoreCopyWith<$Res> {
  factory _$StoreCopyWith(_Store value, $Res Function(_Store) _then) = __$StoreCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? district, String? phone, String? telegram,@JsonKey(name: 'logo_color') String? logoColor,@JsonKey(name: 'partner_tier') String partnerTier
});




}
/// @nodoc
class __$StoreCopyWithImpl<$Res>
    implements _$StoreCopyWith<$Res> {
  __$StoreCopyWithImpl(this._self, this._then);

  final _Store _self;
  final $Res Function(_Store) _then;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? district = freezed,Object? phone = freezed,Object? telegram = freezed,Object? logoColor = freezed,Object? partnerTier = null,}) {
  return _then(_Store(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,telegram: freezed == telegram ? _self.telegram : telegram // ignore: cast_nullable_to_non_nullable
as String?,logoColor: freezed == logoColor ? _self.logoColor : logoColor // ignore: cast_nullable_to_non_nullable
as String?,partnerTier: null == partnerTier ? _self.partnerTier : partnerTier // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
