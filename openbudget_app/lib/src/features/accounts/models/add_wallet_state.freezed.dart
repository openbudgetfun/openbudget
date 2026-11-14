// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_wallet_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WalletPreviewState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletPreviewState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'WalletPreviewState()';
}


}

/// @nodoc
class $WalletPreviewStateCopyWith<$Res>  {
$WalletPreviewStateCopyWith(WalletPreviewState _, $Res Function(WalletPreviewState) __);
}


/// Adds pattern-matching-related methods to [WalletPreviewState].
extension WalletPreviewStatePatterns on WalletPreviewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( WalletPreviewIdle value)?  idle,TResult Function( WalletPreviewLoading value)?  loading,TResult Function( WalletPreviewLoaded value)?  loaded,TResult Function( WalletPreviewFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case WalletPreviewIdle() when idle != null:
return idle(_that);case WalletPreviewLoading() when loading != null:
return loading(_that);case WalletPreviewLoaded() when loaded != null:
return loaded(_that);case WalletPreviewFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( WalletPreviewIdle value)  idle,required TResult Function( WalletPreviewLoading value)  loading,required TResult Function( WalletPreviewLoaded value)  loaded,required TResult Function( WalletPreviewFailed value)  failed,}){
final _that = this;
switch (_that) {
case WalletPreviewIdle():
return idle(_that);case WalletPreviewLoading():
return loading(_that);case WalletPreviewLoaded():
return loaded(_that);case WalletPreviewFailed():
return failed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( WalletPreviewIdle value)?  idle,TResult? Function( WalletPreviewLoading value)?  loading,TResult? Function( WalletPreviewLoaded value)?  loaded,TResult? Function( WalletPreviewFailed value)?  failed,}){
final _that = this;
switch (_that) {
case WalletPreviewIdle() when idle != null:
return idle(_that);case WalletPreviewLoading() when loading != null:
return loading(_that);case WalletPreviewLoaded() when loaded != null:
return loaded(_that);case WalletPreviewFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  loading,TResult Function( WalletPreview preview)?  loaded,TResult Function( WalletPreviewFailure reason)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case WalletPreviewIdle() when idle != null:
return idle();case WalletPreviewLoading() when loading != null:
return loading();case WalletPreviewLoaded() when loaded != null:
return loaded(_that.preview);case WalletPreviewFailed() when failed != null:
return failed(_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  loading,required TResult Function( WalletPreview preview)  loaded,required TResult Function( WalletPreviewFailure reason)  failed,}) {final _that = this;
switch (_that) {
case WalletPreviewIdle():
return idle();case WalletPreviewLoading():
return loading();case WalletPreviewLoaded():
return loaded(_that.preview);case WalletPreviewFailed():
return failed(_that.reason);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  loading,TResult? Function( WalletPreview preview)?  loaded,TResult? Function( WalletPreviewFailure reason)?  failed,}) {final _that = this;
switch (_that) {
case WalletPreviewIdle() when idle != null:
return idle();case WalletPreviewLoading() when loading != null:
return loading();case WalletPreviewLoaded() when loaded != null:
return loaded(_that.preview);case WalletPreviewFailed() when failed != null:
return failed(_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class WalletPreviewIdle implements WalletPreviewState {
  const WalletPreviewIdle();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletPreviewIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'WalletPreviewState.idle()';
}


}




/// @nodoc


class WalletPreviewLoading implements WalletPreviewState {
  const WalletPreviewLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletPreviewLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'WalletPreviewState.loading()';
}


}




/// @nodoc


class WalletPreviewLoaded implements WalletPreviewState {
  const WalletPreviewLoaded(this.preview);
  

 final  WalletPreview preview;

/// Create a copy of WalletPreviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletPreviewLoadedCopyWith<WalletPreviewLoaded> get copyWith => _$WalletPreviewLoadedCopyWithImpl<WalletPreviewLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletPreviewLoaded&&(identical(other.preview, preview) || other.preview == preview));
}


@override
int get hashCode {
    return Object.hash(runtimeType,preview);
}

@override
String toString() {
    return 'WalletPreviewState.loaded(preview: $preview)';
}


}

/// @nodoc
abstract mixin class $WalletPreviewLoadedCopyWith<$Res> implements $WalletPreviewStateCopyWith<$Res> {
  factory $WalletPreviewLoadedCopyWith(WalletPreviewLoaded value, $Res Function(WalletPreviewLoaded) _then) = _$WalletPreviewLoadedCopyWithImpl;
@useResult
$Res call({
 WalletPreview preview
});




}
/// @nodoc
class _$WalletPreviewLoadedCopyWithImpl<$Res>
    implements $WalletPreviewLoadedCopyWith<$Res> {
  _$WalletPreviewLoadedCopyWithImpl(this._self, this._then);

  final WalletPreviewLoaded _self;
  final $Res Function(WalletPreviewLoaded) _then;

/// Create a copy of WalletPreviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? preview = null,}) {
  return _then(WalletPreviewLoaded(
null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as WalletPreview,
  ));
}


}

/// @nodoc


class WalletPreviewFailed implements WalletPreviewState {
  const WalletPreviewFailed(this.reason);
  

 final  WalletPreviewFailure reason;

/// Create a copy of WalletPreviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletPreviewFailedCopyWith<WalletPreviewFailed> get copyWith => _$WalletPreviewFailedCopyWithImpl<WalletPreviewFailed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletPreviewFailed&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'WalletPreviewState.failed(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $WalletPreviewFailedCopyWith<$Res> implements $WalletPreviewStateCopyWith<$Res> {
  factory $WalletPreviewFailedCopyWith(WalletPreviewFailed value, $Res Function(WalletPreviewFailed) _then) = _$WalletPreviewFailedCopyWithImpl;
@useResult
$Res call({
 WalletPreviewFailure reason
});




}
/// @nodoc
class _$WalletPreviewFailedCopyWithImpl<$Res>
    implements $WalletPreviewFailedCopyWith<$Res> {
  _$WalletPreviewFailedCopyWithImpl(this._self, this._then);

  final WalletPreviewFailed _self;
  final $Res Function(WalletPreviewFailed) _then;

/// Create a copy of WalletPreviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(WalletPreviewFailed(
null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as WalletPreviewFailure,
  ));
}


}

/// @nodoc
mixin _$AddWalletSubmission {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AddWalletSubmission);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AddWalletSubmission()';
}


}

/// @nodoc
class $AddWalletSubmissionCopyWith<$Res>  {
$AddWalletSubmissionCopyWith(AddWalletSubmission _, $Res Function(AddWalletSubmission) __);
}


/// Adds pattern-matching-related methods to [AddWalletSubmission].
extension AddWalletSubmissionPatterns on AddWalletSubmission {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AddWalletIdle value)?  idle,TResult Function( AddWalletReading value)?  reading,TResult Function( AddWalletUnreadable value)?  unreadable,TResult Function( AddWalletAdded value)?  added,TResult Function( AddWalletFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AddWalletIdle() when idle != null:
return idle(_that);case AddWalletReading() when reading != null:
return reading(_that);case AddWalletUnreadable() when unreadable != null:
return unreadable(_that);case AddWalletAdded() when added != null:
return added(_that);case AddWalletFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AddWalletIdle value)  idle,required TResult Function( AddWalletReading value)  reading,required TResult Function( AddWalletUnreadable value)  unreadable,required TResult Function( AddWalletAdded value)  added,required TResult Function( AddWalletFailed value)  failed,}){
final _that = this;
switch (_that) {
case AddWalletIdle():
return idle(_that);case AddWalletReading():
return reading(_that);case AddWalletUnreadable():
return unreadable(_that);case AddWalletAdded():
return added(_that);case AddWalletFailed():
return failed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AddWalletIdle value)?  idle,TResult? Function( AddWalletReading value)?  reading,TResult? Function( AddWalletUnreadable value)?  unreadable,TResult? Function( AddWalletAdded value)?  added,TResult? Function( AddWalletFailed value)?  failed,}){
final _that = this;
switch (_that) {
case AddWalletIdle() when idle != null:
return idle(_that);case AddWalletReading() when reading != null:
return reading(_that);case AddWalletUnreadable() when unreadable != null:
return unreadable(_that);case AddWalletAdded() when added != null:
return added(_that);case AddWalletFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( List<WalletNetwork> networks)?  reading,TResult Function( Wallet wallet,  String accountName,  List<WalletNetwork> networks,  String? reason)?  unreadable,TResult Function( Wallet wallet,  String accountName,  List<WalletNetwork> networks)?  added,TResult Function( String? message)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AddWalletIdle() when idle != null:
return idle();case AddWalletReading() when reading != null:
return reading(_that.networks);case AddWalletUnreadable() when unreadable != null:
return unreadable(_that.wallet,_that.accountName,_that.networks,_that.reason);case AddWalletAdded() when added != null:
return added(_that.wallet,_that.accountName,_that.networks);case AddWalletFailed() when failed != null:
return failed(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( List<WalletNetwork> networks)  reading,required TResult Function( Wallet wallet,  String accountName,  List<WalletNetwork> networks,  String? reason)  unreadable,required TResult Function( Wallet wallet,  String accountName,  List<WalletNetwork> networks)  added,required TResult Function( String? message)  failed,}) {final _that = this;
switch (_that) {
case AddWalletIdle():
return idle();case AddWalletReading():
return reading(_that.networks);case AddWalletUnreadable():
return unreadable(_that.wallet,_that.accountName,_that.networks,_that.reason);case AddWalletAdded():
return added(_that.wallet,_that.accountName,_that.networks);case AddWalletFailed():
return failed(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( List<WalletNetwork> networks)?  reading,TResult? Function( Wallet wallet,  String accountName,  List<WalletNetwork> networks,  String? reason)?  unreadable,TResult? Function( Wallet wallet,  String accountName,  List<WalletNetwork> networks)?  added,TResult? Function( String? message)?  failed,}) {final _that = this;
switch (_that) {
case AddWalletIdle() when idle != null:
return idle();case AddWalletReading() when reading != null:
return reading(_that.networks);case AddWalletUnreadable() when unreadable != null:
return unreadable(_that.wallet,_that.accountName,_that.networks,_that.reason);case AddWalletAdded() when added != null:
return added(_that.wallet,_that.accountName,_that.networks);case AddWalletFailed() when failed != null:
return failed(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class AddWalletIdle implements AddWalletSubmission {
  const AddWalletIdle();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AddWalletIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AddWalletSubmission.idle()';
}


}




/// @nodoc


class AddWalletReading implements AddWalletSubmission {
  const AddWalletReading( List<WalletNetwork> networks): _networks = networks;
  

 final  List<WalletNetwork> _networks;
 List<WalletNetwork> get networks {
  if (_networks is EqualUnmodifiableListView) return _networks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_networks);
}


/// Create a copy of AddWalletSubmission
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddWalletReadingCopyWith<AddWalletReading> get copyWith => _$AddWalletReadingCopyWithImpl<AddWalletReading>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AddWalletReading&&const DeepCollectionEquality().equals(other.networks, _networks));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_networks));
}

@override
String toString() {
    return 'AddWalletSubmission.reading(networks: $networks)';
}


}

/// @nodoc
abstract mixin class $AddWalletReadingCopyWith<$Res> implements $AddWalletSubmissionCopyWith<$Res> {
  factory $AddWalletReadingCopyWith(AddWalletReading value, $Res Function(AddWalletReading) _then) = _$AddWalletReadingCopyWithImpl;
@useResult
$Res call({
 List<WalletNetwork> networks
});




}
/// @nodoc
class _$AddWalletReadingCopyWithImpl<$Res>
    implements $AddWalletReadingCopyWith<$Res> {
  _$AddWalletReadingCopyWithImpl(this._self, this._then);

  final AddWalletReading _self;
  final $Res Function(AddWalletReading) _then;

/// Create a copy of AddWalletSubmission
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? networks = null,}) {
  return _then(AddWalletReading(
null == networks ? _self._networks : networks // ignore: cast_nullable_to_non_nullable
as List<WalletNetwork>,
  ));
}


}

/// @nodoc


class AddWalletUnreadable implements AddWalletSubmission {
  const AddWalletUnreadable({required this.wallet, required this.accountName, required  List<WalletNetwork> networks, this.reason}): _networks = networks;
  

 final  Wallet wallet;
 final  String accountName;
 final  List<WalletNetwork> _networks;
 List<WalletNetwork> get networks {
  if (_networks is EqualUnmodifiableListView) return _networks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_networks);
}

 final  String? reason;

/// Create a copy of AddWalletSubmission
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddWalletUnreadableCopyWith<AddWalletUnreadable> get copyWith => _$AddWalletUnreadableCopyWithImpl<AddWalletUnreadable>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AddWalletUnreadable&&(identical(other.wallet, wallet) || other.wallet == wallet)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&const DeepCollectionEquality().equals(other.networks, _networks)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,wallet,accountName,const DeepCollectionEquality().hash(_networks),reason);
}

@override
String toString() {
    return 'AddWalletSubmission.unreadable(wallet: $wallet, accountName: $accountName, networks: $networks, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $AddWalletUnreadableCopyWith<$Res> implements $AddWalletSubmissionCopyWith<$Res> {
  factory $AddWalletUnreadableCopyWith(AddWalletUnreadable value, $Res Function(AddWalletUnreadable) _then) = _$AddWalletUnreadableCopyWithImpl;
@useResult
$Res call({
 Wallet wallet, String accountName, List<WalletNetwork> networks, String? reason
});




}
/// @nodoc
class _$AddWalletUnreadableCopyWithImpl<$Res>
    implements $AddWalletUnreadableCopyWith<$Res> {
  _$AddWalletUnreadableCopyWithImpl(this._self, this._then);

  final AddWalletUnreadable _self;
  final $Res Function(AddWalletUnreadable) _then;

/// Create a copy of AddWalletSubmission
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? wallet = null,Object? accountName = null,Object? networks = null,Object? reason = freezed,}) {
  return _then(AddWalletUnreadable(
wallet: null == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as Wallet,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,networks: null == networks ? _self._networks : networks // ignore: cast_nullable_to_non_nullable
as List<WalletNetwork>,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class AddWalletAdded implements AddWalletSubmission {
  const AddWalletAdded({required this.wallet, required this.accountName, required  List<WalletNetwork> networks}): _networks = networks;
  

 final  Wallet wallet;
 final  String accountName;
 final  List<WalletNetwork> _networks;
 List<WalletNetwork> get networks {
  if (_networks is EqualUnmodifiableListView) return _networks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_networks);
}


/// Create a copy of AddWalletSubmission
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddWalletAddedCopyWith<AddWalletAdded> get copyWith => _$AddWalletAddedCopyWithImpl<AddWalletAdded>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AddWalletAdded&&(identical(other.wallet, wallet) || other.wallet == wallet)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&const DeepCollectionEquality().equals(other.networks, _networks));
}


@override
int get hashCode {
    return Object.hash(runtimeType,wallet,accountName,const DeepCollectionEquality().hash(_networks));
}

@override
String toString() {
    return 'AddWalletSubmission.added(wallet: $wallet, accountName: $accountName, networks: $networks)';
}


}

/// @nodoc
abstract mixin class $AddWalletAddedCopyWith<$Res> implements $AddWalletSubmissionCopyWith<$Res> {
  factory $AddWalletAddedCopyWith(AddWalletAdded value, $Res Function(AddWalletAdded) _then) = _$AddWalletAddedCopyWithImpl;
@useResult
$Res call({
 Wallet wallet, String accountName, List<WalletNetwork> networks
});




}
/// @nodoc
class _$AddWalletAddedCopyWithImpl<$Res>
    implements $AddWalletAddedCopyWith<$Res> {
  _$AddWalletAddedCopyWithImpl(this._self, this._then);

  final AddWalletAdded _self;
  final $Res Function(AddWalletAdded) _then;

/// Create a copy of AddWalletSubmission
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? wallet = null,Object? accountName = null,Object? networks = null,}) {
  return _then(AddWalletAdded(
wallet: null == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as Wallet,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,networks: null == networks ? _self._networks : networks // ignore: cast_nullable_to_non_nullable
as List<WalletNetwork>,
  ));
}


}

/// @nodoc


class AddWalletFailed implements AddWalletSubmission {
  const AddWalletFailed(this.message);
  

 final  String? message;

/// Create a copy of AddWalletSubmission
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddWalletFailedCopyWith<AddWalletFailed> get copyWith => _$AddWalletFailedCopyWithImpl<AddWalletFailed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AddWalletFailed&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'AddWalletSubmission.failed(message: $message)';
}


}

/// @nodoc
abstract mixin class $AddWalletFailedCopyWith<$Res> implements $AddWalletSubmissionCopyWith<$Res> {
  factory $AddWalletFailedCopyWith(AddWalletFailed value, $Res Function(AddWalletFailed) _then) = _$AddWalletFailedCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class _$AddWalletFailedCopyWithImpl<$Res>
    implements $AddWalletFailedCopyWith<$Res> {
  _$AddWalletFailedCopyWithImpl(this._self, this._then);

  final AddWalletFailed _self;
  final $Res Function(AddWalletFailed) _then;

/// Create a copy of AddWalletSubmission
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(AddWalletFailed(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$AddWalletState {

 WalletPreviewState get preview;/// The networks the wallet will read, in catalogue order.
 List<WalletNetwork> get selected; AddWalletSubmission get submission;
/// Create a copy of AddWalletState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddWalletStateCopyWith<AddWalletState> get copyWith => _$AddWalletStateCopyWithImpl<AddWalletState>(this as AddWalletState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AddWalletState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddWalletState&&(identical(other.preview, _this.preview) || other.preview == _this.preview)&&const DeepCollectionEquality().equals(other.selected, _this.selected)&&(identical(other.submission, _this.submission) || other.submission == _this.submission));
}


@override
int get hashCode {
  final _this = this as AddWalletState;
  return Object.hash(runtimeType,_this.preview,const DeepCollectionEquality().hash(_this.selected),_this.submission);
}

@override
String toString() {
  final _this = this as AddWalletState;
  return 'AddWalletState(preview: ${_this.preview}, selected: ${_this.selected}, submission: ${_this.submission})';
}


}

/// @nodoc
abstract mixin class $AddWalletStateCopyWith<$Res>  {
  factory $AddWalletStateCopyWith(AddWalletState value, $Res Function(AddWalletState) _then) = _$AddWalletStateCopyWithImpl;
@useResult
$Res call({
 WalletPreviewState preview, List<WalletNetwork> selected, AddWalletSubmission submission
});


$WalletPreviewStateCopyWith<$Res> get preview;$AddWalletSubmissionCopyWith<$Res> get submission;

}
/// @nodoc
class _$AddWalletStateCopyWithImpl<$Res>
    implements $AddWalletStateCopyWith<$Res> {
  _$AddWalletStateCopyWithImpl(this._self, this._then);

  final AddWalletState _self;
  final $Res Function(AddWalletState) _then;

/// Create a copy of AddWalletState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? preview = null,Object? selected = null,Object? submission = null,}) {
  return _then(AddWalletState(
preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as WalletPreviewState,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as List<WalletNetwork>,submission: null == submission ? _self.submission : submission // ignore: cast_nullable_to_non_nullable
as AddWalletSubmission,
  ));
}
/// Create a copy of AddWalletState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletPreviewStateCopyWith<$Res> get preview {
  
  return $WalletPreviewStateCopyWith<$Res>(_self.preview, (value) {
    return _then(_self.copyWith(preview: value));
  });
}/// Create a copy of AddWalletState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddWalletSubmissionCopyWith<$Res> get submission {
  
  return $AddWalletSubmissionCopyWith<$Res>(_self.submission, (value) {
    return _then(_self.copyWith(submission: value));
  });
}
}


/// Adds pattern-matching-related methods to [AddWalletState].
extension AddWalletStatePatterns on AddWalletState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddWalletState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddWalletState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddWalletState value)  $default,){
final _that = this;
switch (_that) {
case _AddWalletState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddWalletState value)?  $default,){
final _that = this;
switch (_that) {
case _AddWalletState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WalletPreviewState preview,  List<WalletNetwork> selected,  AddWalletSubmission submission)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddWalletState() when $default != null:
return $default(_that.preview,_that.selected,_that.submission);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WalletPreviewState preview,  List<WalletNetwork> selected,  AddWalletSubmission submission)  $default,) {final _that = this;
switch (_that) {
case _AddWalletState():
return $default(_that.preview,_that.selected,_that.submission);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WalletPreviewState preview,  List<WalletNetwork> selected,  AddWalletSubmission submission)?  $default,) {final _that = this;
switch (_that) {
case _AddWalletState() when $default != null:
return $default(_that.preview,_that.selected,_that.submission);case _:
  return null;

}
}

}

/// @nodoc


class _AddWalletState implements AddWalletState {
  const _AddWalletState({this.preview = const WalletPreviewState.idle(),  List<WalletNetwork> selected = const <WalletNetwork>[], this.submission = const AddWalletSubmission.idle()}): _selected = selected;
  

@override@JsonKey() final  WalletPreviewState preview;
/// The networks the wallet will read, in catalogue order.
 final  List<WalletNetwork> _selected;
/// The networks the wallet will read, in catalogue order.
@override@JsonKey() List<WalletNetwork> get selected {
  if (_selected is EqualUnmodifiableListView) return _selected;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selected);
}

@override@JsonKey() final  AddWalletSubmission submission;

/// Create a copy of AddWalletState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddWalletStateCopyWith<_AddWalletState> get copyWith => __$AddWalletStateCopyWithImpl<_AddWalletState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddWalletState&&(identical(other.preview, preview) || other.preview == preview)&&const DeepCollectionEquality().equals(other.selected, _selected)&&(identical(other.submission, submission) || other.submission == submission));
}


@override
int get hashCode {
    return Object.hash(runtimeType,preview,const DeepCollectionEquality().hash(_selected),submission);
}

@override
String toString() {
    return 'AddWalletState(preview: $preview, selected: $selected, submission: $submission)';
}


}

/// @nodoc
abstract mixin class _$AddWalletStateCopyWith<$Res> implements $AddWalletStateCopyWith<$Res> {
  factory _$AddWalletStateCopyWith(_AddWalletState value, $Res Function(_AddWalletState) _then) = __$AddWalletStateCopyWithImpl;
@override @useResult
$Res call({
 WalletPreviewState preview, List<WalletNetwork> selected, AddWalletSubmission submission
});


@override $WalletPreviewStateCopyWith<$Res> get preview;@override $AddWalletSubmissionCopyWith<$Res> get submission;

}
/// @nodoc
class __$AddWalletStateCopyWithImpl<$Res>
    implements _$AddWalletStateCopyWith<$Res> {
  __$AddWalletStateCopyWithImpl(this._self, this._then);

  final _AddWalletState _self;
  final $Res Function(_AddWalletState) _then;

/// Create a copy of AddWalletState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? preview = null,Object? selected = null,Object? submission = null,}) {
  return _then(_AddWalletState(
preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as WalletPreviewState,selected: null == selected ? _self._selected : selected // ignore: cast_nullable_to_non_nullable
as List<WalletNetwork>,submission: null == submission ? _self.submission : submission // ignore: cast_nullable_to_non_nullable
as AddWalletSubmission,
  ));
}

/// Create a copy of AddWalletState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletPreviewStateCopyWith<$Res> get preview {
  
  return $WalletPreviewStateCopyWith<$Res>(_self.preview, (value) {
    return _then(_self.copyWith(preview: value));
  });
}/// Create a copy of AddWalletState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddWalletSubmissionCopyWith<$Res> get submission {
  
  return $AddWalletSubmissionCopyWith<$Res>(_self.submission, (value) {
    return _then(_self.copyWith(submission: value));
  });
}
}

// dart format on
