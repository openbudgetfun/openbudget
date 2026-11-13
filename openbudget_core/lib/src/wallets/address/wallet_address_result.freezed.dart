// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_address_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WalletAddressParseResult {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletAddressParseResult);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'WalletAddressParseResult()';
}


}

/// @nodoc
class $WalletAddressParseResultCopyWith<$Res>  {
$WalletAddressParseResultCopyWith(WalletAddressParseResult _, $Res Function(WalletAddressParseResult) __);
}


/// Adds pattern-matching-related methods to [WalletAddressParseResult].
extension WalletAddressParseResultPatterns on WalletAddressParseResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( WalletAddressMatch value)?  match,TResult Function( WalletAddressRefused value)?  refused,TResult Function( WalletAddressInvalid value)?  invalid,required TResult orElse(),}){
final _that = this;
switch (_that) {
case WalletAddressMatch() when match != null:
return match(_that);case WalletAddressRefused() when refused != null:
return refused(_that);case WalletAddressInvalid() when invalid != null:
return invalid(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( WalletAddressMatch value)  match,required TResult Function( WalletAddressRefused value)  refused,required TResult Function( WalletAddressInvalid value)  invalid,}){
final _that = this;
switch (_that) {
case WalletAddressMatch():
return match(_that);case WalletAddressRefused():
return refused(_that);case WalletAddressInvalid():
return invalid(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( WalletAddressMatch value)?  match,TResult? Function( WalletAddressRefused value)?  refused,TResult? Function( WalletAddressInvalid value)?  invalid,}){
final _that = this;
switch (_that) {
case WalletAddressMatch() when match != null:
return match(_that);case WalletAddressRefused() when refused != null:
return refused(_that);case WalletAddressInvalid() when invalid != null:
return invalid(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<WalletAddressCandidate> candidates)?  match,TResult Function( WalletAddressRefusal refusal)?  refused,TResult Function( String hint)?  invalid,required TResult orElse(),}) {final _that = this;
switch (_that) {
case WalletAddressMatch() when match != null:
return match(_that.candidates);case WalletAddressRefused() when refused != null:
return refused(_that.refusal);case WalletAddressInvalid() when invalid != null:
return invalid(_that.hint);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<WalletAddressCandidate> candidates)  match,required TResult Function( WalletAddressRefusal refusal)  refused,required TResult Function( String hint)  invalid,}) {final _that = this;
switch (_that) {
case WalletAddressMatch():
return match(_that.candidates);case WalletAddressRefused():
return refused(_that.refusal);case WalletAddressInvalid():
return invalid(_that.hint);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<WalletAddressCandidate> candidates)?  match,TResult? Function( WalletAddressRefusal refusal)?  refused,TResult? Function( String hint)?  invalid,}) {final _that = this;
switch (_that) {
case WalletAddressMatch() when match != null:
return match(_that.candidates);case WalletAddressRefused() when refused != null:
return refused(_that.refusal);case WalletAddressInvalid() when invalid != null:
return invalid(_that.hint);case _:
  return null;

}
}

}

/// @nodoc


class WalletAddressMatch extends WalletAddressParseResult {
  const WalletAddressMatch({required  List<WalletAddressCandidate> candidates}): _candidates = candidates,super._();
  

 final  List<WalletAddressCandidate> _candidates;
 List<WalletAddressCandidate> get candidates {
  if (_candidates is EqualUnmodifiableListView) return _candidates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_candidates);
}


/// Create a copy of WalletAddressParseResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletAddressMatchCopyWith<WalletAddressMatch> get copyWith => _$WalletAddressMatchCopyWithImpl<WalletAddressMatch>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletAddressMatch&&const DeepCollectionEquality().equals(other.candidates, _candidates));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_candidates));
}

@override
String toString() {
    return 'WalletAddressParseResult.match(candidates: $candidates)';
}


}

/// @nodoc
abstract mixin class $WalletAddressMatchCopyWith<$Res> implements $WalletAddressParseResultCopyWith<$Res> {
  factory $WalletAddressMatchCopyWith(WalletAddressMatch value, $Res Function(WalletAddressMatch) _then) = _$WalletAddressMatchCopyWithImpl;
@useResult
$Res call({
 List<WalletAddressCandidate> candidates
});




}
/// @nodoc
class _$WalletAddressMatchCopyWithImpl<$Res>
    implements $WalletAddressMatchCopyWith<$Res> {
  _$WalletAddressMatchCopyWithImpl(this._self, this._then);

  final WalletAddressMatch _self;
  final $Res Function(WalletAddressMatch) _then;

/// Create a copy of WalletAddressParseResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? candidates = null,}) {
  return _then(WalletAddressMatch(
candidates: null == candidates ? _self._candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<WalletAddressCandidate>,
  ));
}


}

/// @nodoc


class WalletAddressRefused extends WalletAddressParseResult {
  const WalletAddressRefused(this.refusal): super._();
  

 final  WalletAddressRefusal refusal;

/// Create a copy of WalletAddressParseResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletAddressRefusedCopyWith<WalletAddressRefused> get copyWith => _$WalletAddressRefusedCopyWithImpl<WalletAddressRefused>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletAddressRefused&&(identical(other.refusal, refusal) || other.refusal == refusal));
}


@override
int get hashCode {
    return Object.hash(runtimeType,refusal);
}

@override
String toString() {
    return 'WalletAddressParseResult.refused(refusal: $refusal)';
}


}

/// @nodoc
abstract mixin class $WalletAddressRefusedCopyWith<$Res> implements $WalletAddressParseResultCopyWith<$Res> {
  factory $WalletAddressRefusedCopyWith(WalletAddressRefused value, $Res Function(WalletAddressRefused) _then) = _$WalletAddressRefusedCopyWithImpl;
@useResult
$Res call({
 WalletAddressRefusal refusal
});




}
/// @nodoc
class _$WalletAddressRefusedCopyWithImpl<$Res>
    implements $WalletAddressRefusedCopyWith<$Res> {
  _$WalletAddressRefusedCopyWithImpl(this._self, this._then);

  final WalletAddressRefused _self;
  final $Res Function(WalletAddressRefused) _then;

/// Create a copy of WalletAddressParseResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? refusal = null,}) {
  return _then(WalletAddressRefused(
null == refusal ? _self.refusal : refusal // ignore: cast_nullable_to_non_nullable
as WalletAddressRefusal,
  ));
}


}

/// @nodoc


class WalletAddressInvalid extends WalletAddressParseResult {
  const WalletAddressInvalid(this.hint): super._();
  

 final  String hint;

/// Create a copy of WalletAddressParseResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletAddressInvalidCopyWith<WalletAddressInvalid> get copyWith => _$WalletAddressInvalidCopyWithImpl<WalletAddressInvalid>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletAddressInvalid&&(identical(other.hint, hint) || other.hint == hint));
}


@override
int get hashCode {
    return Object.hash(runtimeType,hint);
}

@override
String toString() {
    return 'WalletAddressParseResult.invalid(hint: $hint)';
}


}

/// @nodoc
abstract mixin class $WalletAddressInvalidCopyWith<$Res> implements $WalletAddressParseResultCopyWith<$Res> {
  factory $WalletAddressInvalidCopyWith(WalletAddressInvalid value, $Res Function(WalletAddressInvalid) _then) = _$WalletAddressInvalidCopyWithImpl;
@useResult
$Res call({
 String hint
});




}
/// @nodoc
class _$WalletAddressInvalidCopyWithImpl<$Res>
    implements $WalletAddressInvalidCopyWith<$Res> {
  _$WalletAddressInvalidCopyWithImpl(this._self, this._then);

  final WalletAddressInvalid _self;
  final $Res Function(WalletAddressInvalid) _then;

/// Create a copy of WalletAddressParseResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? hint = null,}) {
  return _then(WalletAddressInvalid(
null == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$WalletAddressCandidate {

 WalletAddressFamily get family;/// The serialized `WalletNetwork` names this candidate can be read on.
///
/// Task W1.1 moves `WalletNetwork` into core. Until it lands, the parser
/// uses the names it will serialise as, so it does not create a second
/// network enum.
 List<String> get networks;/// The form to store, per `docs/multichain-wallets.md` section 5.2.
 String get canonical;/// The form to show in the app.
 String get display; WalletAddressKind get kind;/// The HD key's script type, or null when a bare `xpub` still has to be
/// probed for one (section 5.4).
 WalletAddressHdScriptType? get hdScriptType;
/// Create a copy of WalletAddressCandidate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletAddressCandidateCopyWith<WalletAddressCandidate> get copyWith => _$WalletAddressCandidateCopyWithImpl<WalletAddressCandidate>(this as WalletAddressCandidate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WalletAddressCandidate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletAddressCandidate&&(identical(other.family, _this.family) || other.family == _this.family)&&const DeepCollectionEquality().equals(other.networks, _this.networks)&&(identical(other.canonical, _this.canonical) || other.canonical == _this.canonical)&&(identical(other.display, _this.display) || other.display == _this.display)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.hdScriptType, _this.hdScriptType) || other.hdScriptType == _this.hdScriptType));
}


@override
int get hashCode {
  final _this = this as WalletAddressCandidate;
  return Object.hash(runtimeType,_this.family,const DeepCollectionEquality().hash(_this.networks),_this.canonical,_this.display,_this.kind,_this.hdScriptType);
}

@override
String toString() {
  final _this = this as WalletAddressCandidate;
  return 'WalletAddressCandidate(family: ${_this.family}, networks: ${_this.networks}, canonical: ${_this.canonical}, display: ${_this.display}, kind: ${_this.kind}, hdScriptType: ${_this.hdScriptType})';
}


}

/// @nodoc
abstract mixin class $WalletAddressCandidateCopyWith<$Res>  {
  factory $WalletAddressCandidateCopyWith(WalletAddressCandidate value, $Res Function(WalletAddressCandidate) _then) = _$WalletAddressCandidateCopyWithImpl;
@useResult
$Res call({
 WalletAddressFamily family, List<String> networks, String canonical, String display, WalletAddressKind kind, WalletAddressHdScriptType? hdScriptType
});




}
/// @nodoc
class _$WalletAddressCandidateCopyWithImpl<$Res>
    implements $WalletAddressCandidateCopyWith<$Res> {
  _$WalletAddressCandidateCopyWithImpl(this._self, this._then);

  final WalletAddressCandidate _self;
  final $Res Function(WalletAddressCandidate) _then;

/// Create a copy of WalletAddressCandidate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? family = null,Object? networks = null,Object? canonical = null,Object? display = null,Object? kind = null,Object? hdScriptType = freezed,}) {
  return _then(WalletAddressCandidate(
family: null == family ? _self.family : family // ignore: cast_nullable_to_non_nullable
as WalletAddressFamily,networks: null == networks ? _self.networks : networks // ignore: cast_nullable_to_non_nullable
as List<String>,canonical: null == canonical ? _self.canonical : canonical // ignore: cast_nullable_to_non_nullable
as String,display: null == display ? _self.display : display // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as WalletAddressKind,hdScriptType: freezed == hdScriptType ? _self.hdScriptType : hdScriptType // ignore: cast_nullable_to_non_nullable
as WalletAddressHdScriptType?,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletAddressCandidate].
extension WalletAddressCandidatePatterns on WalletAddressCandidate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletAddressCandidate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletAddressCandidate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletAddressCandidate value)  $default,){
final _that = this;
switch (_that) {
case _WalletAddressCandidate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletAddressCandidate value)?  $default,){
final _that = this;
switch (_that) {
case _WalletAddressCandidate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WalletAddressFamily family,  List<String> networks,  String canonical,  String display,  WalletAddressKind kind,  WalletAddressHdScriptType? hdScriptType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletAddressCandidate() when $default != null:
return $default(_that.family,_that.networks,_that.canonical,_that.display,_that.kind,_that.hdScriptType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WalletAddressFamily family,  List<String> networks,  String canonical,  String display,  WalletAddressKind kind,  WalletAddressHdScriptType? hdScriptType)  $default,) {final _that = this;
switch (_that) {
case _WalletAddressCandidate():
return $default(_that.family,_that.networks,_that.canonical,_that.display,_that.kind,_that.hdScriptType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WalletAddressFamily family,  List<String> networks,  String canonical,  String display,  WalletAddressKind kind,  WalletAddressHdScriptType? hdScriptType)?  $default,) {final _that = this;
switch (_that) {
case _WalletAddressCandidate() when $default != null:
return $default(_that.family,_that.networks,_that.canonical,_that.display,_that.kind,_that.hdScriptType);case _:
  return null;

}
}

}

/// @nodoc


class _WalletAddressCandidate implements WalletAddressCandidate {
  const _WalletAddressCandidate({required this.family, required  List<String> networks, required this.canonical, required this.display, required this.kind, this.hdScriptType}): _networks = networks;
  

@override final  WalletAddressFamily family;
/// The serialized `WalletNetwork` names this candidate can be read on.
///
/// Task W1.1 moves `WalletNetwork` into core. Until it lands, the parser
/// uses the names it will serialise as, so it does not create a second
/// network enum.
 final  List<String> _networks;
/// The serialized `WalletNetwork` names this candidate can be read on.
///
/// Task W1.1 moves `WalletNetwork` into core. Until it lands, the parser
/// uses the names it will serialise as, so it does not create a second
/// network enum.
@override List<String> get networks {
  if (_networks is EqualUnmodifiableListView) return _networks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_networks);
}

/// The form to store, per `docs/multichain-wallets.md` section 5.2.
@override final  String canonical;
/// The form to show in the app.
@override final  String display;
@override final  WalletAddressKind kind;
/// The HD key's script type, or null when a bare `xpub` still has to be
/// probed for one (section 5.4).
@override final  WalletAddressHdScriptType? hdScriptType;

/// Create a copy of WalletAddressCandidate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletAddressCandidateCopyWith<_WalletAddressCandidate> get copyWith => __$WalletAddressCandidateCopyWithImpl<_WalletAddressCandidate>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletAddressCandidate&&(identical(other.family, family) || other.family == family)&&const DeepCollectionEquality().equals(other.networks, _networks)&&(identical(other.canonical, canonical) || other.canonical == canonical)&&(identical(other.display, display) || other.display == display)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.hdScriptType, hdScriptType) || other.hdScriptType == hdScriptType));
}


@override
int get hashCode {
    return Object.hash(runtimeType,family,const DeepCollectionEquality().hash(_networks),canonical,display,kind,hdScriptType);
}

@override
String toString() {
    return 'WalletAddressCandidate(family: $family, networks: $networks, canonical: $canonical, display: $display, kind: $kind, hdScriptType: $hdScriptType)';
}


}

/// @nodoc
abstract mixin class _$WalletAddressCandidateCopyWith<$Res> implements $WalletAddressCandidateCopyWith<$Res> {
  factory _$WalletAddressCandidateCopyWith(_WalletAddressCandidate value, $Res Function(_WalletAddressCandidate) _then) = __$WalletAddressCandidateCopyWithImpl;
@override @useResult
$Res call({
 WalletAddressFamily family, List<String> networks, String canonical, String display, WalletAddressKind kind, WalletAddressHdScriptType? hdScriptType
});




}
/// @nodoc
class __$WalletAddressCandidateCopyWithImpl<$Res>
    implements _$WalletAddressCandidateCopyWith<$Res> {
  __$WalletAddressCandidateCopyWithImpl(this._self, this._then);

  final _WalletAddressCandidate _self;
  final $Res Function(_WalletAddressCandidate) _then;

/// Create a copy of WalletAddressCandidate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? family = null,Object? networks = null,Object? canonical = null,Object? display = null,Object? kind = null,Object? hdScriptType = freezed,}) {
  return _then(_WalletAddressCandidate(
family: null == family ? _self.family : family // ignore: cast_nullable_to_non_nullable
as WalletAddressFamily,networks: null == networks ? _self._networks : networks // ignore: cast_nullable_to_non_nullable
as List<String>,canonical: null == canonical ? _self.canonical : canonical // ignore: cast_nullable_to_non_nullable
as String,display: null == display ? _self.display : display // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as WalletAddressKind,hdScriptType: freezed == hdScriptType ? _self.hdScriptType : hdScriptType // ignore: cast_nullable_to_non_nullable
as WalletAddressHdScriptType?,
  ));
}


}

// dart format on
