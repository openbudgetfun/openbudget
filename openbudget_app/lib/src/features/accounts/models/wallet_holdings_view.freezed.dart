// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_holdings_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WalletAssetGroup {

 WalletHolding get primary; List<WalletHolding> get positions;
/// Create a copy of WalletAssetGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletAssetGroupCopyWith<WalletAssetGroup> get copyWith => _$WalletAssetGroupCopyWithImpl<WalletAssetGroup>(this as WalletAssetGroup, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WalletAssetGroup;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletAssetGroup&&(identical(other.primary, _this.primary) || other.primary == _this.primary)&&const DeepCollectionEquality().equals(other.positions, _this.positions));
}


@override
int get hashCode {
  final _this = this as WalletAssetGroup;
  return Object.hash(runtimeType,_this.primary,const DeepCollectionEquality().hash(_this.positions));
}

@override
String toString() {
  final _this = this as WalletAssetGroup;
  return 'WalletAssetGroup(primary: ${_this.primary}, positions: ${_this.positions})';
}


}

/// @nodoc
abstract mixin class $WalletAssetGroupCopyWith<$Res>  {
  factory $WalletAssetGroupCopyWith(WalletAssetGroup value, $Res Function(WalletAssetGroup) _then) = _$WalletAssetGroupCopyWithImpl;
@useResult
$Res call({
 WalletHolding primary, List<WalletHolding> positions
});




}
/// @nodoc
class _$WalletAssetGroupCopyWithImpl<$Res>
    implements $WalletAssetGroupCopyWith<$Res> {
  _$WalletAssetGroupCopyWithImpl(this._self, this._then);

  final WalletAssetGroup _self;
  final $Res Function(WalletAssetGroup) _then;

/// Create a copy of WalletAssetGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? primary = null,Object? positions = null,}) {
  return _then(WalletAssetGroup(
primary: null == primary ? _self.primary : primary // ignore: cast_nullable_to_non_nullable
as WalletHolding,positions: null == positions ? _self.positions : positions // ignore: cast_nullable_to_non_nullable
as List<WalletHolding>,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletAssetGroup].
extension WalletAssetGroupPatterns on WalletAssetGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletAssetGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletAssetGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletAssetGroup value)  $default,){
final _that = this;
switch (_that) {
case _WalletAssetGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletAssetGroup value)?  $default,){
final _that = this;
switch (_that) {
case _WalletAssetGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WalletHolding primary,  List<WalletHolding> positions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletAssetGroup() when $default != null:
return $default(_that.primary,_that.positions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WalletHolding primary,  List<WalletHolding> positions)  $default,) {final _that = this;
switch (_that) {
case _WalletAssetGroup():
return $default(_that.primary,_that.positions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WalletHolding primary,  List<WalletHolding> positions)?  $default,) {final _that = this;
switch (_that) {
case _WalletAssetGroup() when $default != null:
return $default(_that.primary,_that.positions);case _:
  return null;

}
}

}

/// @nodoc


class _WalletAssetGroup extends WalletAssetGroup {
  const _WalletAssetGroup({required this.primary,  List<WalletHolding> positions = const <WalletHolding>[]}): _positions = positions,super._();
  

@override final  WalletHolding primary;
 final  List<WalletHolding> _positions;
@override@JsonKey() List<WalletHolding> get positions {
  if (_positions is EqualUnmodifiableListView) return _positions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_positions);
}


/// Create a copy of WalletAssetGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletAssetGroupCopyWith<_WalletAssetGroup> get copyWith => __$WalletAssetGroupCopyWithImpl<_WalletAssetGroup>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletAssetGroup&&(identical(other.primary, primary) || other.primary == primary)&&const DeepCollectionEquality().equals(other.positions, _positions));
}


@override
int get hashCode {
    return Object.hash(runtimeType,primary,const DeepCollectionEquality().hash(_positions));
}

@override
String toString() {
    return 'WalletAssetGroup(primary: $primary, positions: $positions)';
}


}

/// @nodoc
abstract mixin class _$WalletAssetGroupCopyWith<$Res> implements $WalletAssetGroupCopyWith<$Res> {
  factory _$WalletAssetGroupCopyWith(_WalletAssetGroup value, $Res Function(_WalletAssetGroup) _then) = __$WalletAssetGroupCopyWithImpl;
@override @useResult
$Res call({
 WalletHolding primary, List<WalletHolding> positions
});




}
/// @nodoc
class __$WalletAssetGroupCopyWithImpl<$Res>
    implements _$WalletAssetGroupCopyWith<$Res> {
  __$WalletAssetGroupCopyWithImpl(this._self, this._then);

  final _WalletAssetGroup _self;
  final $Res Function(_WalletAssetGroup) _then;

/// Create a copy of WalletAssetGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? primary = null,Object? positions = null,}) {
  return _then(_WalletAssetGroup(
primary: null == primary ? _self.primary : primary // ignore: cast_nullable_to_non_nullable
as WalletHolding,positions: null == positions ? _self._positions : positions // ignore: cast_nullable_to_non_nullable
as List<WalletHolding>,
  ));
}


}

/// @nodoc
mixin _$WalletNetworkSection {

 WalletNetwork get network; List<WalletAssetGroup> get groups;/// Sum of the counted holdings' `valueMinor`, or null when none counts.
 int? get subtotalMinor;/// The currency of [subtotalMinor].
 String get currencyCode;/// When the network was last read successfully, if ever.
 DateTime? get lastReadAt;/// The last read's failure in plain words; null when it succeeded.
 String? get lastError;/// Whether the network has a read-state row at all.
 bool get hasReadState;
/// Create a copy of WalletNetworkSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletNetworkSectionCopyWith<WalletNetworkSection> get copyWith => _$WalletNetworkSectionCopyWithImpl<WalletNetworkSection>(this as WalletNetworkSection, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WalletNetworkSection;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletNetworkSection&&(identical(other.network, _this.network) || other.network == _this.network)&&const DeepCollectionEquality().equals(other.groups, _this.groups)&&(identical(other.subtotalMinor, _this.subtotalMinor) || other.subtotalMinor == _this.subtotalMinor)&&(identical(other.currencyCode, _this.currencyCode) || other.currencyCode == _this.currencyCode)&&(identical(other.lastReadAt, _this.lastReadAt) || other.lastReadAt == _this.lastReadAt)&&(identical(other.lastError, _this.lastError) || other.lastError == _this.lastError)&&(identical(other.hasReadState, _this.hasReadState) || other.hasReadState == _this.hasReadState));
}


@override
int get hashCode {
  final _this = this as WalletNetworkSection;
  return Object.hash(runtimeType,_this.network,const DeepCollectionEquality().hash(_this.groups),_this.subtotalMinor,_this.currencyCode,_this.lastReadAt,_this.lastError,_this.hasReadState);
}

@override
String toString() {
  final _this = this as WalletNetworkSection;
  return 'WalletNetworkSection(network: ${_this.network}, groups: ${_this.groups}, subtotalMinor: ${_this.subtotalMinor}, currencyCode: ${_this.currencyCode}, lastReadAt: ${_this.lastReadAt}, lastError: ${_this.lastError}, hasReadState: ${_this.hasReadState})';
}


}

/// @nodoc
abstract mixin class $WalletNetworkSectionCopyWith<$Res>  {
  factory $WalletNetworkSectionCopyWith(WalletNetworkSection value, $Res Function(WalletNetworkSection) _then) = _$WalletNetworkSectionCopyWithImpl;
@useResult
$Res call({
 WalletNetwork network, List<WalletAssetGroup> groups, int? subtotalMinor, String currencyCode, DateTime? lastReadAt, String? lastError, bool hasReadState
});




}
/// @nodoc
class _$WalletNetworkSectionCopyWithImpl<$Res>
    implements $WalletNetworkSectionCopyWith<$Res> {
  _$WalletNetworkSectionCopyWithImpl(this._self, this._then);

  final WalletNetworkSection _self;
  final $Res Function(WalletNetworkSection) _then;

/// Create a copy of WalletNetworkSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? network = null,Object? groups = null,Object? subtotalMinor = freezed,Object? currencyCode = null,Object? lastReadAt = freezed,Object? lastError = freezed,Object? hasReadState = null,}) {
  return _then(WalletNetworkSection(
network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as WalletNetwork,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<WalletAssetGroup>,subtotalMinor: freezed == subtotalMinor ? _self.subtotalMinor : subtotalMinor // ignore: cast_nullable_to_non_nullable
as int?,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,lastReadAt: freezed == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,hasReadState: null == hasReadState ? _self.hasReadState : hasReadState // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletNetworkSection].
extension WalletNetworkSectionPatterns on WalletNetworkSection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletNetworkSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletNetworkSection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletNetworkSection value)  $default,){
final _that = this;
switch (_that) {
case _WalletNetworkSection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletNetworkSection value)?  $default,){
final _that = this;
switch (_that) {
case _WalletNetworkSection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WalletNetwork network,  List<WalletAssetGroup> groups,  int? subtotalMinor,  String currencyCode,  DateTime? lastReadAt,  String? lastError,  bool hasReadState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletNetworkSection() when $default != null:
return $default(_that.network,_that.groups,_that.subtotalMinor,_that.currencyCode,_that.lastReadAt,_that.lastError,_that.hasReadState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WalletNetwork network,  List<WalletAssetGroup> groups,  int? subtotalMinor,  String currencyCode,  DateTime? lastReadAt,  String? lastError,  bool hasReadState)  $default,) {final _that = this;
switch (_that) {
case _WalletNetworkSection():
return $default(_that.network,_that.groups,_that.subtotalMinor,_that.currencyCode,_that.lastReadAt,_that.lastError,_that.hasReadState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WalletNetwork network,  List<WalletAssetGroup> groups,  int? subtotalMinor,  String currencyCode,  DateTime? lastReadAt,  String? lastError,  bool hasReadState)?  $default,) {final _that = this;
switch (_that) {
case _WalletNetworkSection() when $default != null:
return $default(_that.network,_that.groups,_that.subtotalMinor,_that.currencyCode,_that.lastReadAt,_that.lastError,_that.hasReadState);case _:
  return null;

}
}

}

/// @nodoc


class _WalletNetworkSection extends WalletNetworkSection {
  const _WalletNetworkSection({required this.network, required  List<WalletAssetGroup> groups, required this.subtotalMinor, required this.currencyCode, this.lastReadAt, this.lastError, this.hasReadState = false}): _groups = groups,super._();
  

@override final  WalletNetwork network;
 final  List<WalletAssetGroup> _groups;
@override List<WalletAssetGroup> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

/// Sum of the counted holdings' `valueMinor`, or null when none counts.
@override final  int? subtotalMinor;
/// The currency of [subtotalMinor].
@override final  String currencyCode;
/// When the network was last read successfully, if ever.
@override final  DateTime? lastReadAt;
/// The last read's failure in plain words; null when it succeeded.
@override final  String? lastError;
/// Whether the network has a read-state row at all.
@override@JsonKey() final  bool hasReadState;

/// Create a copy of WalletNetworkSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletNetworkSectionCopyWith<_WalletNetworkSection> get copyWith => __$WalletNetworkSectionCopyWithImpl<_WalletNetworkSection>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletNetworkSection&&(identical(other.network, network) || other.network == network)&&const DeepCollectionEquality().equals(other.groups, _groups)&&(identical(other.subtotalMinor, subtotalMinor) || other.subtotalMinor == subtotalMinor)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.lastReadAt, lastReadAt) || other.lastReadAt == lastReadAt)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.hasReadState, hasReadState) || other.hasReadState == hasReadState));
}


@override
int get hashCode {
    return Object.hash(runtimeType,network,const DeepCollectionEquality().hash(_groups),subtotalMinor,currencyCode,lastReadAt,lastError,hasReadState);
}

@override
String toString() {
    return 'WalletNetworkSection(network: $network, groups: $groups, subtotalMinor: $subtotalMinor, currencyCode: $currencyCode, lastReadAt: $lastReadAt, lastError: $lastError, hasReadState: $hasReadState)';
}


}

/// @nodoc
abstract mixin class _$WalletNetworkSectionCopyWith<$Res> implements $WalletNetworkSectionCopyWith<$Res> {
  factory _$WalletNetworkSectionCopyWith(_WalletNetworkSection value, $Res Function(_WalletNetworkSection) _then) = __$WalletNetworkSectionCopyWithImpl;
@override @useResult
$Res call({
 WalletNetwork network, List<WalletAssetGroup> groups, int? subtotalMinor, String currencyCode, DateTime? lastReadAt, String? lastError, bool hasReadState
});




}
/// @nodoc
class __$WalletNetworkSectionCopyWithImpl<$Res>
    implements _$WalletNetworkSectionCopyWith<$Res> {
  __$WalletNetworkSectionCopyWithImpl(this._self, this._then);

  final _WalletNetworkSection _self;
  final $Res Function(_WalletNetworkSection) _then;

/// Create a copy of WalletNetworkSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? network = null,Object? groups = null,Object? subtotalMinor = freezed,Object? currencyCode = null,Object? lastReadAt = freezed,Object? lastError = freezed,Object? hasReadState = null,}) {
  return _then(_WalletNetworkSection(
network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as WalletNetwork,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<WalletAssetGroup>,subtotalMinor: freezed == subtotalMinor ? _self.subtotalMinor : subtotalMinor // ignore: cast_nullable_to_non_nullable
as int?,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,lastReadAt: freezed == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,hasReadState: null == hasReadState ? _self.hasReadState : hasReadState // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$HiddenHolding {

 WalletHolding get holding; HiddenReason get reason;
/// Create a copy of HiddenHolding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HiddenHoldingCopyWith<HiddenHolding> get copyWith => _$HiddenHoldingCopyWithImpl<HiddenHolding>(this as HiddenHolding, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HiddenHolding;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HiddenHolding&&(identical(other.holding, _this.holding) || other.holding == _this.holding)&&(identical(other.reason, _this.reason) || other.reason == _this.reason));
}


@override
int get hashCode {
  final _this = this as HiddenHolding;
  return Object.hash(runtimeType,_this.holding,_this.reason);
}

@override
String toString() {
  final _this = this as HiddenHolding;
  return 'HiddenHolding(holding: ${_this.holding}, reason: ${_this.reason})';
}


}

/// @nodoc
abstract mixin class $HiddenHoldingCopyWith<$Res>  {
  factory $HiddenHoldingCopyWith(HiddenHolding value, $Res Function(HiddenHolding) _then) = _$HiddenHoldingCopyWithImpl;
@useResult
$Res call({
 WalletHolding holding, HiddenReason reason
});




}
/// @nodoc
class _$HiddenHoldingCopyWithImpl<$Res>
    implements $HiddenHoldingCopyWith<$Res> {
  _$HiddenHoldingCopyWithImpl(this._self, this._then);

  final HiddenHolding _self;
  final $Res Function(HiddenHolding) _then;

/// Create a copy of HiddenHolding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? holding = null,Object? reason = null,}) {
  return _then(HiddenHolding(
holding: null == holding ? _self.holding : holding // ignore: cast_nullable_to_non_nullable
as WalletHolding,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as HiddenReason,
  ));
}

}


/// Adds pattern-matching-related methods to [HiddenHolding].
extension HiddenHoldingPatterns on HiddenHolding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HiddenHolding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HiddenHolding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HiddenHolding value)  $default,){
final _that = this;
switch (_that) {
case _HiddenHolding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HiddenHolding value)?  $default,){
final _that = this;
switch (_that) {
case _HiddenHolding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WalletHolding holding,  HiddenReason reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HiddenHolding() when $default != null:
return $default(_that.holding,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WalletHolding holding,  HiddenReason reason)  $default,) {final _that = this;
switch (_that) {
case _HiddenHolding():
return $default(_that.holding,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WalletHolding holding,  HiddenReason reason)?  $default,) {final _that = this;
switch (_that) {
case _HiddenHolding() when $default != null:
return $default(_that.holding,_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class _HiddenHolding implements HiddenHolding {
  const _HiddenHolding({required this.holding, required this.reason});
  

@override final  WalletHolding holding;
@override final  HiddenReason reason;

/// Create a copy of HiddenHolding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HiddenHoldingCopyWith<_HiddenHolding> get copyWith => __$HiddenHoldingCopyWithImpl<_HiddenHolding>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HiddenHolding&&(identical(other.holding, holding) || other.holding == holding)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,holding,reason);
}

@override
String toString() {
    return 'HiddenHolding(holding: $holding, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$HiddenHoldingCopyWith<$Res> implements $HiddenHoldingCopyWith<$Res> {
  factory _$HiddenHoldingCopyWith(_HiddenHolding value, $Res Function(_HiddenHolding) _then) = __$HiddenHoldingCopyWithImpl;
@override @useResult
$Res call({
 WalletHolding holding, HiddenReason reason
});




}
/// @nodoc
class __$HiddenHoldingCopyWithImpl<$Res>
    implements _$HiddenHoldingCopyWith<$Res> {
  __$HiddenHoldingCopyWithImpl(this._self, this._then);

  final _HiddenHolding _self;
  final $Res Function(_HiddenHolding) _then;

/// Create a copy of HiddenHolding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? holding = null,Object? reason = null,}) {
  return _then(_HiddenHolding(
holding: null == holding ? _self.holding : holding // ignore: cast_nullable_to_non_nullable
as WalletHolding,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as HiddenReason,
  ));
}


}

/// @nodoc
mixin _$WalletHoldingsView {

 List<WalletNetworkSection> get sections; List<HiddenHolding> get hidden;
/// Create a copy of WalletHoldingsView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletHoldingsViewCopyWith<WalletHoldingsView> get copyWith => _$WalletHoldingsViewCopyWithImpl<WalletHoldingsView>(this as WalletHoldingsView, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WalletHoldingsView;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletHoldingsView&&const DeepCollectionEquality().equals(other.sections, _this.sections)&&const DeepCollectionEquality().equals(other.hidden, _this.hidden));
}


@override
int get hashCode {
  final _this = this as WalletHoldingsView;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.sections),const DeepCollectionEquality().hash(_this.hidden));
}

@override
String toString() {
  final _this = this as WalletHoldingsView;
  return 'WalletHoldingsView(sections: ${_this.sections}, hidden: ${_this.hidden})';
}


}

/// @nodoc
abstract mixin class $WalletHoldingsViewCopyWith<$Res>  {
  factory $WalletHoldingsViewCopyWith(WalletHoldingsView value, $Res Function(WalletHoldingsView) _then) = _$WalletHoldingsViewCopyWithImpl;
@useResult
$Res call({
 List<WalletNetworkSection> sections, List<HiddenHolding> hidden
});




}
/// @nodoc
class _$WalletHoldingsViewCopyWithImpl<$Res>
    implements $WalletHoldingsViewCopyWith<$Res> {
  _$WalletHoldingsViewCopyWithImpl(this._self, this._then);

  final WalletHoldingsView _self;
  final $Res Function(WalletHoldingsView) _then;

/// Create a copy of WalletHoldingsView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sections = null,Object? hidden = null,}) {
  return _then(WalletHoldingsView(
sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<WalletNetworkSection>,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as List<HiddenHolding>,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletHoldingsView].
extension WalletHoldingsViewPatterns on WalletHoldingsView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletHoldingsView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletHoldingsView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletHoldingsView value)  $default,){
final _that = this;
switch (_that) {
case _WalletHoldingsView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletHoldingsView value)?  $default,){
final _that = this;
switch (_that) {
case _WalletHoldingsView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<WalletNetworkSection> sections,  List<HiddenHolding> hidden)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletHoldingsView() when $default != null:
return $default(_that.sections,_that.hidden);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<WalletNetworkSection> sections,  List<HiddenHolding> hidden)  $default,) {final _that = this;
switch (_that) {
case _WalletHoldingsView():
return $default(_that.sections,_that.hidden);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<WalletNetworkSection> sections,  List<HiddenHolding> hidden)?  $default,) {final _that = this;
switch (_that) {
case _WalletHoldingsView() when $default != null:
return $default(_that.sections,_that.hidden);case _:
  return null;

}
}

}

/// @nodoc


class _WalletHoldingsView extends WalletHoldingsView {
  const _WalletHoldingsView({required  List<WalletNetworkSection> sections, required  List<HiddenHolding> hidden}): _sections = sections,_hidden = hidden,super._();
  

 final  List<WalletNetworkSection> _sections;
@override List<WalletNetworkSection> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}

 final  List<HiddenHolding> _hidden;
@override List<HiddenHolding> get hidden {
  if (_hidden is EqualUnmodifiableListView) return _hidden;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hidden);
}


/// Create a copy of WalletHoldingsView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletHoldingsViewCopyWith<_WalletHoldingsView> get copyWith => __$WalletHoldingsViewCopyWithImpl<_WalletHoldingsView>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletHoldingsView&&const DeepCollectionEquality().equals(other.sections, _sections)&&const DeepCollectionEquality().equals(other.hidden, _hidden));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_sections),const DeepCollectionEquality().hash(_hidden));
}

@override
String toString() {
    return 'WalletHoldingsView(sections: $sections, hidden: $hidden)';
}


}

/// @nodoc
abstract mixin class _$WalletHoldingsViewCopyWith<$Res> implements $WalletHoldingsViewCopyWith<$Res> {
  factory _$WalletHoldingsViewCopyWith(_WalletHoldingsView value, $Res Function(_WalletHoldingsView) _then) = __$WalletHoldingsViewCopyWithImpl;
@override @useResult
$Res call({
 List<WalletNetworkSection> sections, List<HiddenHolding> hidden
});




}
/// @nodoc
class __$WalletHoldingsViewCopyWithImpl<$Res>
    implements _$WalletHoldingsViewCopyWith<$Res> {
  __$WalletHoldingsViewCopyWithImpl(this._self, this._then);

  final _WalletHoldingsView _self;
  final $Res Function(_WalletHoldingsView) _then;

/// Create a copy of WalletHoldingsView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sections = null,Object? hidden = null,}) {
  return _then(_WalletHoldingsView(
sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<WalletNetworkSection>,hidden: null == hidden ? _self._hidden : hidden // ignore: cast_nullable_to_non_nullable
as List<HiddenHolding>,
  ));
}


}

// dart format on
