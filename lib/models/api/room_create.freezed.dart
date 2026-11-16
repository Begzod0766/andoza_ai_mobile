// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room_create.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WallElementCreate {

@JsonKey(unknownEnumValue: WallElementType.unknown) WallElementType get type; double get width; double get height;@JsonKey(name: 'sill_height') double get sillHeight; double get position;
/// Create a copy of WallElementCreate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WallElementCreateCopyWith<WallElementCreate> get copyWith => _$WallElementCreateCopyWithImpl<WallElementCreate>(this as WallElementCreate, _$identity);

  /// Serializes this WallElementCreate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WallElementCreate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WallElementCreate&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&(identical(other.sillHeight, _this.sillHeight) || other.sillHeight == _this.sillHeight)&&(identical(other.position, _this.position) || other.position == _this.position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WallElementCreate;
  return Object.hash(runtimeType,_this.type,_this.width,_this.height,_this.sillHeight,_this.position);
}

@override
String toString() {
  final _this = this as WallElementCreate;
  return 'WallElementCreate(type: ${_this.type}, width: ${_this.width}, height: ${_this.height}, sillHeight: ${_this.sillHeight}, position: ${_this.position})';
}


}

/// @nodoc
abstract mixin class $WallElementCreateCopyWith<$Res>  {
  factory $WallElementCreateCopyWith(WallElementCreate value, $Res Function(WallElementCreate) _then) = _$WallElementCreateCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: WallElementType.unknown) WallElementType type, double width, double height,@JsonKey(name: 'sill_height') double sillHeight, double position
});




}
/// @nodoc
class _$WallElementCreateCopyWithImpl<$Res>
    implements $WallElementCreateCopyWith<$Res> {
  _$WallElementCreateCopyWithImpl(this._self, this._then);

  final WallElementCreate _self;
  final $Res Function(WallElementCreate) _then;

/// Create a copy of WallElementCreate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? width = null,Object? height = null,Object? sillHeight = null,Object? position = null,}) {
  return _then(WallElementCreate(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WallElementType,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,sillHeight: null == sillHeight ? _self.sillHeight : sillHeight // ignore: cast_nullable_to_non_nullable
as double,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [WallElementCreate].
extension WallElementCreatePatterns on WallElementCreate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WallElementCreate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WallElementCreate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WallElementCreate value)  $default,){
final _that = this;
switch (_that) {
case _WallElementCreate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WallElementCreate value)?  $default,){
final _that = this;
switch (_that) {
case _WallElementCreate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: WallElementType.unknown)  WallElementType type,  double width,  double height, @JsonKey(name: 'sill_height')  double sillHeight,  double position)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WallElementCreate() when $default != null:
return $default(_that.type,_that.width,_that.height,_that.sillHeight,_that.position);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: WallElementType.unknown)  WallElementType type,  double width,  double height, @JsonKey(name: 'sill_height')  double sillHeight,  double position)  $default,) {final _that = this;
switch (_that) {
case _WallElementCreate():
return $default(_that.type,_that.width,_that.height,_that.sillHeight,_that.position);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: WallElementType.unknown)  WallElementType type,  double width,  double height, @JsonKey(name: 'sill_height')  double sillHeight,  double position)?  $default,) {final _that = this;
switch (_that) {
case _WallElementCreate() when $default != null:
return $default(_that.type,_that.width,_that.height,_that.sillHeight,_that.position);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WallElementCreate implements WallElementCreate {
  const _WallElementCreate({@JsonKey(unknownEnumValue: WallElementType.unknown) required this.type, required this.width, required this.height, @JsonKey(name: 'sill_height') this.sillHeight = 0.0, this.position = 0.5});
  factory _WallElementCreate.fromJson(Map<String, dynamic> json) => _$WallElementCreateFromJson(json);

@override@JsonKey(unknownEnumValue: WallElementType.unknown) final  WallElementType type;
@override final  double width;
@override final  double height;
@override@JsonKey(name: 'sill_height') final  double sillHeight;
@override@JsonKey() final  double position;

/// Create a copy of WallElementCreate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WallElementCreateCopyWith<_WallElementCreate> get copyWith => __$WallElementCreateCopyWithImpl<_WallElementCreate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WallElementCreateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WallElementCreate&&(identical(other.type, type) || other.type == type)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.sillHeight, sillHeight) || other.sillHeight == sillHeight)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,width,height,sillHeight,position);
}

@override
String toString() {
    return 'WallElementCreate(type: $type, width: $width, height: $height, sillHeight: $sillHeight, position: $position)';
}


}

/// @nodoc
abstract mixin class _$WallElementCreateCopyWith<$Res> implements $WallElementCreateCopyWith<$Res> {
  factory _$WallElementCreateCopyWith(_WallElementCreate value, $Res Function(_WallElementCreate) _then) = __$WallElementCreateCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: WallElementType.unknown) WallElementType type, double width, double height,@JsonKey(name: 'sill_height') double sillHeight, double position
});




}
/// @nodoc
class __$WallElementCreateCopyWithImpl<$Res>
    implements _$WallElementCreateCopyWith<$Res> {
  __$WallElementCreateCopyWithImpl(this._self, this._then);

  final _WallElementCreate _self;
  final $Res Function(_WallElementCreate) _then;

/// Create a copy of WallElementCreate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? width = null,Object? height = null,Object? sillHeight = null,Object? position = null,}) {
  return _then(_WallElementCreate(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WallElementType,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,sillHeight: null == sillHeight ? _self.sillHeight : sillHeight // ignore: cast_nullable_to_non_nullable
as double,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$WallCreate {

 String get id; double get length; List<WallElementCreate> get elements;
/// Create a copy of WallCreate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WallCreateCopyWith<WallCreate> get copyWith => _$WallCreateCopyWithImpl<WallCreate>(this as WallCreate, _$identity);

  /// Serializes this WallCreate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WallCreate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WallCreate&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.length, _this.length) || other.length == _this.length)&&const DeepCollectionEquality().equals(other.elements, _this.elements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WallCreate;
  return Object.hash(runtimeType,_this.id,_this.length,const DeepCollectionEquality().hash(_this.elements));
}

@override
String toString() {
  final _this = this as WallCreate;
  return 'WallCreate(id: ${_this.id}, length: ${_this.length}, elements: ${_this.elements})';
}


}

/// @nodoc
abstract mixin class $WallCreateCopyWith<$Res>  {
  factory $WallCreateCopyWith(WallCreate value, $Res Function(WallCreate) _then) = _$WallCreateCopyWithImpl;
@useResult
$Res call({
 String id, double length, List<WallElementCreate> elements
});




}
/// @nodoc
class _$WallCreateCopyWithImpl<$Res>
    implements $WallCreateCopyWith<$Res> {
  _$WallCreateCopyWithImpl(this._self, this._then);

  final WallCreate _self;
  final $Res Function(WallCreate) _then;

/// Create a copy of WallCreate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? length = null,Object? elements = null,}) {
  return _then(WallCreate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,length: null == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as double,elements: null == elements ? _self.elements : elements // ignore: cast_nullable_to_non_nullable
as List<WallElementCreate>,
  ));
}

}


/// Adds pattern-matching-related methods to [WallCreate].
extension WallCreatePatterns on WallCreate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WallCreate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WallCreate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WallCreate value)  $default,){
final _that = this;
switch (_that) {
case _WallCreate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WallCreate value)?  $default,){
final _that = this;
switch (_that) {
case _WallCreate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double length,  List<WallElementCreate> elements)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WallCreate() when $default != null:
return $default(_that.id,_that.length,_that.elements);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double length,  List<WallElementCreate> elements)  $default,) {final _that = this;
switch (_that) {
case _WallCreate():
return $default(_that.id,_that.length,_that.elements);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double length,  List<WallElementCreate> elements)?  $default,) {final _that = this;
switch (_that) {
case _WallCreate() when $default != null:
return $default(_that.id,_that.length,_that.elements);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WallCreate implements WallCreate {
  const _WallCreate({required this.id, required this.length,  List<WallElementCreate> elements = const <WallElementCreate>[]}): _elements = elements;
  factory _WallCreate.fromJson(Map<String, dynamic> json) => _$WallCreateFromJson(json);

@override final  String id;
@override final  double length;
 final  List<WallElementCreate> _elements;
@override@JsonKey() List<WallElementCreate> get elements {
  if (_elements is EqualUnmodifiableListView) return _elements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_elements);
}


/// Create a copy of WallCreate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WallCreateCopyWith<_WallCreate> get copyWith => __$WallCreateCopyWithImpl<_WallCreate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WallCreateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WallCreate&&(identical(other.id, id) || other.id == id)&&(identical(other.length, length) || other.length == length)&&const DeepCollectionEquality().equals(other.elements, _elements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,length,const DeepCollectionEquality().hash(_elements));
}

@override
String toString() {
    return 'WallCreate(id: $id, length: $length, elements: $elements)';
}


}

/// @nodoc
abstract mixin class _$WallCreateCopyWith<$Res> implements $WallCreateCopyWith<$Res> {
  factory _$WallCreateCopyWith(_WallCreate value, $Res Function(_WallCreate) _then) = __$WallCreateCopyWithImpl;
@override @useResult
$Res call({
 String id, double length, List<WallElementCreate> elements
});




}
/// @nodoc
class __$WallCreateCopyWithImpl<$Res>
    implements _$WallCreateCopyWith<$Res> {
  __$WallCreateCopyWithImpl(this._self, this._then);

  final _WallCreate _self;
  final $Res Function(_WallCreate) _then;

/// Create a copy of WallCreate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? length = null,Object? elements = null,}) {
  return _then(_WallCreate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,length: null == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as double,elements: null == elements ? _self._elements : elements // ignore: cast_nullable_to_non_nullable
as List<WallElementCreate>,
  ));
}


}


/// @nodoc
mixin _$RoomGeometryCreate {

 List<WallCreate> get walls;@JsonKey(name: 'vertices', includeIfNull: false) List<List<double>>? get vertices;
/// Create a copy of RoomGeometryCreate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomGeometryCreateCopyWith<RoomGeometryCreate> get copyWith => _$RoomGeometryCreateCopyWithImpl<RoomGeometryCreate>(this as RoomGeometryCreate, _$identity);

  /// Serializes this RoomGeometryCreate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RoomGeometryCreate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomGeometryCreate&&const DeepCollectionEquality().equals(other.walls, _this.walls)&&const DeepCollectionEquality().equals(other.vertices, _this.vertices));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RoomGeometryCreate;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.walls),const DeepCollectionEquality().hash(_this.vertices));
}

@override
String toString() {
  final _this = this as RoomGeometryCreate;
  return 'RoomGeometryCreate(walls: ${_this.walls}, vertices: ${_this.vertices})';
}


}

/// @nodoc
abstract mixin class $RoomGeometryCreateCopyWith<$Res>  {
  factory $RoomGeometryCreateCopyWith(RoomGeometryCreate value, $Res Function(RoomGeometryCreate) _then) = _$RoomGeometryCreateCopyWithImpl;
@useResult
$Res call({
 List<WallCreate> walls,@JsonKey(name: 'vertices', includeIfNull: false) List<List<double>>? vertices
});




}
/// @nodoc
class _$RoomGeometryCreateCopyWithImpl<$Res>
    implements $RoomGeometryCreateCopyWith<$Res> {
  _$RoomGeometryCreateCopyWithImpl(this._self, this._then);

  final RoomGeometryCreate _self;
  final $Res Function(RoomGeometryCreate) _then;

/// Create a copy of RoomGeometryCreate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? walls = null,Object? vertices = freezed,}) {
  return _then(RoomGeometryCreate(
walls: null == walls ? _self.walls : walls // ignore: cast_nullable_to_non_nullable
as List<WallCreate>,vertices: freezed == vertices ? _self.vertices : vertices // ignore: cast_nullable_to_non_nullable
as List<List<double>>?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoomGeometryCreate].
extension RoomGeometryCreatePatterns on RoomGeometryCreate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoomGeometryCreate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoomGeometryCreate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoomGeometryCreate value)  $default,){
final _that = this;
switch (_that) {
case _RoomGeometryCreate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoomGeometryCreate value)?  $default,){
final _that = this;
switch (_that) {
case _RoomGeometryCreate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<WallCreate> walls, @JsonKey(name: 'vertices', includeIfNull: false)  List<List<double>>? vertices)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoomGeometryCreate() when $default != null:
return $default(_that.walls,_that.vertices);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<WallCreate> walls, @JsonKey(name: 'vertices', includeIfNull: false)  List<List<double>>? vertices)  $default,) {final _that = this;
switch (_that) {
case _RoomGeometryCreate():
return $default(_that.walls,_that.vertices);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<WallCreate> walls, @JsonKey(name: 'vertices', includeIfNull: false)  List<List<double>>? vertices)?  $default,) {final _that = this;
switch (_that) {
case _RoomGeometryCreate() when $default != null:
return $default(_that.walls,_that.vertices);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoomGeometryCreate implements RoomGeometryCreate {
  const _RoomGeometryCreate({required  List<WallCreate> walls, @JsonKey(name: 'vertices', includeIfNull: false)  List<List<double>>? vertices}): _walls = walls,_vertices = vertices;
  factory _RoomGeometryCreate.fromJson(Map<String, dynamic> json) => _$RoomGeometryCreateFromJson(json);

 final  List<WallCreate> _walls;
@override List<WallCreate> get walls {
  if (_walls is EqualUnmodifiableListView) return _walls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_walls);
}

 final  List<List<double>>? _vertices;
@override@JsonKey(name: 'vertices', includeIfNull: false) List<List<double>>? get vertices {
  final value = _vertices;
  if (value == null) return null;
  if (_vertices is EqualUnmodifiableListView) return _vertices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of RoomGeometryCreate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoomGeometryCreateCopyWith<_RoomGeometryCreate> get copyWith => __$RoomGeometryCreateCopyWithImpl<_RoomGeometryCreate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoomGeometryCreateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoomGeometryCreate&&const DeepCollectionEquality().equals(other.walls, _walls)&&const DeepCollectionEquality().equals(other.vertices, _vertices));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_walls),const DeepCollectionEquality().hash(_vertices));
}

@override
String toString() {
    return 'RoomGeometryCreate(walls: $walls, vertices: $vertices)';
}


}

/// @nodoc
abstract mixin class _$RoomGeometryCreateCopyWith<$Res> implements $RoomGeometryCreateCopyWith<$Res> {
  factory _$RoomGeometryCreateCopyWith(_RoomGeometryCreate value, $Res Function(_RoomGeometryCreate) _then) = __$RoomGeometryCreateCopyWithImpl;
@override @useResult
$Res call({
 List<WallCreate> walls,@JsonKey(name: 'vertices', includeIfNull: false) List<List<double>>? vertices
});




}
/// @nodoc
class __$RoomGeometryCreateCopyWithImpl<$Res>
    implements _$RoomGeometryCreateCopyWith<$Res> {
  __$RoomGeometryCreateCopyWithImpl(this._self, this._then);

  final _RoomGeometryCreate _self;
  final $Res Function(_RoomGeometryCreate) _then;

/// Create a copy of RoomGeometryCreate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? walls = null,Object? vertices = freezed,}) {
  return _then(_RoomGeometryCreate(
walls: null == walls ? _self._walls : walls // ignore: cast_nullable_to_non_nullable
as List<WallCreate>,vertices: freezed == vertices ? _self._vertices : vertices // ignore: cast_nullable_to_non_nullable
as List<List<double>>?,
  ));
}


}


/// @nodoc
mixin _$RoomCreate {

 String get name;@JsonKey(name: 'ceiling_h') double get ceilingH; RoomGeometryCreate get geometry;/// `hammom`, `oshxona`, … (backend `RoomType`); omitted when not picked.
@JsonKey(name: 'room_type', includeIfNull: false) String? get roomType;
/// Create a copy of RoomCreate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomCreateCopyWith<RoomCreate> get copyWith => _$RoomCreateCopyWithImpl<RoomCreate>(this as RoomCreate, _$identity);

  /// Serializes this RoomCreate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RoomCreate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomCreate&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.ceilingH, _this.ceilingH) || other.ceilingH == _this.ceilingH)&&(identical(other.geometry, _this.geometry) || other.geometry == _this.geometry)&&(identical(other.roomType, _this.roomType) || other.roomType == _this.roomType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RoomCreate;
  return Object.hash(runtimeType,_this.name,_this.ceilingH,_this.geometry,_this.roomType);
}

@override
String toString() {
  final _this = this as RoomCreate;
  return 'RoomCreate(name: ${_this.name}, ceilingH: ${_this.ceilingH}, geometry: ${_this.geometry}, roomType: ${_this.roomType})';
}


}

/// @nodoc
abstract mixin class $RoomCreateCopyWith<$Res>  {
  factory $RoomCreateCopyWith(RoomCreate value, $Res Function(RoomCreate) _then) = _$RoomCreateCopyWithImpl;
@useResult
$Res call({
 String name,@JsonKey(name: 'ceiling_h') double ceilingH, RoomGeometryCreate geometry,@JsonKey(name: 'room_type', includeIfNull: false) String? roomType
});


$RoomGeometryCreateCopyWith<$Res> get geometry;

}
/// @nodoc
class _$RoomCreateCopyWithImpl<$Res>
    implements $RoomCreateCopyWith<$Res> {
  _$RoomCreateCopyWithImpl(this._self, this._then);

  final RoomCreate _self;
  final $Res Function(RoomCreate) _then;

/// Create a copy of RoomCreate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? ceilingH = null,Object? geometry = null,Object? roomType = freezed,}) {
  return _then(RoomCreate(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ceilingH: null == ceilingH ? _self.ceilingH : ceilingH // ignore: cast_nullable_to_non_nullable
as double,geometry: null == geometry ? _self.geometry : geometry // ignore: cast_nullable_to_non_nullable
as RoomGeometryCreate,roomType: freezed == roomType ? _self.roomType : roomType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RoomCreate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoomGeometryCreateCopyWith<$Res> get geometry {
  
  return $RoomGeometryCreateCopyWith<$Res>(_self.geometry, (value) {
    return _then(_self.copyWith(geometry: value));
  });
}
}


/// Adds pattern-matching-related methods to [RoomCreate].
extension RoomCreatePatterns on RoomCreate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoomCreate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoomCreate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoomCreate value)  $default,){
final _that = this;
switch (_that) {
case _RoomCreate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoomCreate value)?  $default,){
final _that = this;
switch (_that) {
case _RoomCreate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name, @JsonKey(name: 'ceiling_h')  double ceilingH,  RoomGeometryCreate geometry, @JsonKey(name: 'room_type', includeIfNull: false)  String? roomType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoomCreate() when $default != null:
return $default(_that.name,_that.ceilingH,_that.geometry,_that.roomType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name, @JsonKey(name: 'ceiling_h')  double ceilingH,  RoomGeometryCreate geometry, @JsonKey(name: 'room_type', includeIfNull: false)  String? roomType)  $default,) {final _that = this;
switch (_that) {
case _RoomCreate():
return $default(_that.name,_that.ceilingH,_that.geometry,_that.roomType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name, @JsonKey(name: 'ceiling_h')  double ceilingH,  RoomGeometryCreate geometry, @JsonKey(name: 'room_type', includeIfNull: false)  String? roomType)?  $default,) {final _that = this;
switch (_that) {
case _RoomCreate() when $default != null:
return $default(_that.name,_that.ceilingH,_that.geometry,_that.roomType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoomCreate implements RoomCreate {
  const _RoomCreate({required this.name, @JsonKey(name: 'ceiling_h') required this.ceilingH, required this.geometry, @JsonKey(name: 'room_type', includeIfNull: false) this.roomType});
  factory _RoomCreate.fromJson(Map<String, dynamic> json) => _$RoomCreateFromJson(json);

@override final  String name;
@override@JsonKey(name: 'ceiling_h') final  double ceilingH;
@override final  RoomGeometryCreate geometry;
/// `hammom`, `oshxona`, … (backend `RoomType`); omitted when not picked.
@override@JsonKey(name: 'room_type', includeIfNull: false) final  String? roomType;

/// Create a copy of RoomCreate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoomCreateCopyWith<_RoomCreate> get copyWith => __$RoomCreateCopyWithImpl<_RoomCreate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoomCreateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoomCreate&&(identical(other.name, name) || other.name == name)&&(identical(other.ceilingH, ceilingH) || other.ceilingH == ceilingH)&&(identical(other.geometry, geometry) || other.geometry == geometry)&&(identical(other.roomType, roomType) || other.roomType == roomType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,ceilingH,geometry,roomType);
}

@override
String toString() {
    return 'RoomCreate(name: $name, ceilingH: $ceilingH, geometry: $geometry, roomType: $roomType)';
}


}

/// @nodoc
abstract mixin class _$RoomCreateCopyWith<$Res> implements $RoomCreateCopyWith<$Res> {
  factory _$RoomCreateCopyWith(_RoomCreate value, $Res Function(_RoomCreate) _then) = __$RoomCreateCopyWithImpl;
@override @useResult
$Res call({
 String name,@JsonKey(name: 'ceiling_h') double ceilingH, RoomGeometryCreate geometry,@JsonKey(name: 'room_type', includeIfNull: false) String? roomType
});


@override $RoomGeometryCreateCopyWith<$Res> get geometry;

}
/// @nodoc
class __$RoomCreateCopyWithImpl<$Res>
    implements _$RoomCreateCopyWith<$Res> {
  __$RoomCreateCopyWithImpl(this._self, this._then);

  final _RoomCreate _self;
  final $Res Function(_RoomCreate) _then;

/// Create a copy of RoomCreate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? ceilingH = null,Object? geometry = null,Object? roomType = freezed,}) {
  return _then(_RoomCreate(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ceilingH: null == ceilingH ? _self.ceilingH : ceilingH // ignore: cast_nullable_to_non_nullable
as double,geometry: null == geometry ? _self.geometry : geometry // ignore: cast_nullable_to_non_nullable
as RoomGeometryCreate,roomType: freezed == roomType ? _self.roomType : roomType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RoomCreate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoomGeometryCreateCopyWith<$Res> get geometry {
  
  return $RoomGeometryCreateCopyWith<$Res>(_self.geometry, (value) {
    return _then(_self.copyWith(geometry: value));
  });
}
}

// dart format on
