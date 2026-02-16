// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credit_card_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreditCardPaymentInfo {

 Account get account; int get spentCents; int get paymentCents;
/// Create a copy of CreditCardPaymentInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditCardPaymentInfoCopyWith<CreditCardPaymentInfo> get copyWith => _$CreditCardPaymentInfoCopyWithImpl<CreditCardPaymentInfo>(this as CreditCardPaymentInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditCardPaymentInfo&&(identical(other.account, account) || other.account == account)&&(identical(other.spentCents, spentCents) || other.spentCents == spentCents)&&(identical(other.paymentCents, paymentCents) || other.paymentCents == paymentCents));
}


@override
int get hashCode => Object.hash(runtimeType,account,spentCents,paymentCents);

@override
String toString() {
  return 'CreditCardPaymentInfo(account: $account, spentCents: $spentCents, paymentCents: $paymentCents)';
}


}

/// @nodoc
abstract mixin class $CreditCardPaymentInfoCopyWith<$Res>  {
  factory $CreditCardPaymentInfoCopyWith(CreditCardPaymentInfo value, $Res Function(CreditCardPaymentInfo) _then) = _$CreditCardPaymentInfoCopyWithImpl;
@useResult
$Res call({
 Account account, int spentCents, int paymentCents
});




}
/// @nodoc
class _$CreditCardPaymentInfoCopyWithImpl<$Res>
    implements $CreditCardPaymentInfoCopyWith<$Res> {
  _$CreditCardPaymentInfoCopyWithImpl(this._self, this._then);

  final CreditCardPaymentInfo _self;
  final $Res Function(CreditCardPaymentInfo) _then;

/// Create a copy of CreditCardPaymentInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? account = null,Object? spentCents = null,Object? paymentCents = null,}) {
  return _then(_self.copyWith(
account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as Account,spentCents: null == spentCents ? _self.spentCents : spentCents // ignore: cast_nullable_to_non_nullable
as int,paymentCents: null == paymentCents ? _self.paymentCents : paymentCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CreditCardPaymentInfo].
extension CreditCardPaymentInfoPatterns on CreditCardPaymentInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreditCardPaymentInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreditCardPaymentInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreditCardPaymentInfo value)  $default,){
final _that = this;
switch (_that) {
case _CreditCardPaymentInfo():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreditCardPaymentInfo value)?  $default,){
final _that = this;
switch (_that) {
case _CreditCardPaymentInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Account account,  int spentCents,  int paymentCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditCardPaymentInfo() when $default != null:
return $default(_that.account,_that.spentCents,_that.paymentCents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Account account,  int spentCents,  int paymentCents)  $default,) {final _that = this;
switch (_that) {
case _CreditCardPaymentInfo():
return $default(_that.account,_that.spentCents,_that.paymentCents);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Account account,  int spentCents,  int paymentCents)?  $default,) {final _that = this;
switch (_that) {
case _CreditCardPaymentInfo() when $default != null:
return $default(_that.account,_that.spentCents,_that.paymentCents);case _:
  return null;

}
}

}

/// @nodoc


class _CreditCardPaymentInfo implements CreditCardPaymentInfo {
  const _CreditCardPaymentInfo({required this.account, required this.spentCents, required this.paymentCents});
  

@override final  Account account;
@override final  int spentCents;
@override final  int paymentCents;

/// Create a copy of CreditCardPaymentInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditCardPaymentInfoCopyWith<_CreditCardPaymentInfo> get copyWith => __$CreditCardPaymentInfoCopyWithImpl<_CreditCardPaymentInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditCardPaymentInfo&&(identical(other.account, account) || other.account == account)&&(identical(other.spentCents, spentCents) || other.spentCents == spentCents)&&(identical(other.paymentCents, paymentCents) || other.paymentCents == paymentCents));
}


@override
int get hashCode => Object.hash(runtimeType,account,spentCents,paymentCents);

@override
String toString() {
  return 'CreditCardPaymentInfo(account: $account, spentCents: $spentCents, paymentCents: $paymentCents)';
}


}

/// @nodoc
abstract mixin class _$CreditCardPaymentInfoCopyWith<$Res> implements $CreditCardPaymentInfoCopyWith<$Res> {
  factory _$CreditCardPaymentInfoCopyWith(_CreditCardPaymentInfo value, $Res Function(_CreditCardPaymentInfo) _then) = __$CreditCardPaymentInfoCopyWithImpl;
@override @useResult
$Res call({
 Account account, int spentCents, int paymentCents
});




}
/// @nodoc
class __$CreditCardPaymentInfoCopyWithImpl<$Res>
    implements _$CreditCardPaymentInfoCopyWith<$Res> {
  __$CreditCardPaymentInfoCopyWithImpl(this._self, this._then);

  final _CreditCardPaymentInfo _self;
  final $Res Function(_CreditCardPaymentInfo) _then;

/// Create a copy of CreditCardPaymentInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? account = null,Object? spentCents = null,Object? paymentCents = null,}) {
  return _then(_CreditCardPaymentInfo(
account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as Account,spentCents: null == spentCents ? _self.spentCents : spentCents // ignore: cast_nullable_to_non_nullable
as int,paymentCents: null == paymentCents ? _self.paymentCents : paymentCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
