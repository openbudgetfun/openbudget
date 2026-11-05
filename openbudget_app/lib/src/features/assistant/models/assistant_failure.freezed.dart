// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assistant_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AssistantFailure {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AssistantFailure()';
}


}

/// @nodoc
class $AssistantFailureCopyWith<$Res>  {
$AssistantFailureCopyWith(AssistantFailure _, $Res Function(AssistantFailure) __);
}


/// Adds pattern-matching-related methods to [AssistantFailure].
extension AssistantFailurePatterns on AssistantFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AssistantEntitlementRequired value)?  entitlementRequired,TResult Function( AssistantAllowanceExhausted value)?  allowanceExhausted,TResult Function( AssistantProviderUnavailable value)?  providerUnavailable,TResult Function( AssistantValidationFailure value)?  validation,TResult Function( AssistantNetworkFailure value)?  network,TResult Function( AssistantUnknownFailure value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AssistantEntitlementRequired() when entitlementRequired != null:
return entitlementRequired(_that);case AssistantAllowanceExhausted() when allowanceExhausted != null:
return allowanceExhausted(_that);case AssistantProviderUnavailable() when providerUnavailable != null:
return providerUnavailable(_that);case AssistantValidationFailure() when validation != null:
return validation(_that);case AssistantNetworkFailure() when network != null:
return network(_that);case AssistantUnknownFailure() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AssistantEntitlementRequired value)  entitlementRequired,required TResult Function( AssistantAllowanceExhausted value)  allowanceExhausted,required TResult Function( AssistantProviderUnavailable value)  providerUnavailable,required TResult Function( AssistantValidationFailure value)  validation,required TResult Function( AssistantNetworkFailure value)  network,required TResult Function( AssistantUnknownFailure value)  unknown,}){
final _that = this;
switch (_that) {
case AssistantEntitlementRequired():
return entitlementRequired(_that);case AssistantAllowanceExhausted():
return allowanceExhausted(_that);case AssistantProviderUnavailable():
return providerUnavailable(_that);case AssistantValidationFailure():
return validation(_that);case AssistantNetworkFailure():
return network(_that);case AssistantUnknownFailure():
return unknown(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AssistantEntitlementRequired value)?  entitlementRequired,TResult? Function( AssistantAllowanceExhausted value)?  allowanceExhausted,TResult? Function( AssistantProviderUnavailable value)?  providerUnavailable,TResult? Function( AssistantValidationFailure value)?  validation,TResult? Function( AssistantNetworkFailure value)?  network,TResult? Function( AssistantUnknownFailure value)?  unknown,}){
final _that = this;
switch (_that) {
case AssistantEntitlementRequired() when entitlementRequired != null:
return entitlementRequired(_that);case AssistantAllowanceExhausted() when allowanceExhausted != null:
return allowanceExhausted(_that);case AssistantProviderUnavailable() when providerUnavailable != null:
return providerUnavailable(_that);case AssistantValidationFailure() when validation != null:
return validation(_that);case AssistantNetworkFailure() when network != null:
return network(_that);case AssistantUnknownFailure() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  entitlementRequired,TResult Function()?  allowanceExhausted,TResult Function()?  providerUnavailable,TResult Function( String message)?  validation,TResult Function()?  network,TResult Function()?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AssistantEntitlementRequired() when entitlementRequired != null:
return entitlementRequired();case AssistantAllowanceExhausted() when allowanceExhausted != null:
return allowanceExhausted();case AssistantProviderUnavailable() when providerUnavailable != null:
return providerUnavailable();case AssistantValidationFailure() when validation != null:
return validation(_that.message);case AssistantNetworkFailure() when network != null:
return network();case AssistantUnknownFailure() when unknown != null:
return unknown();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  entitlementRequired,required TResult Function()  allowanceExhausted,required TResult Function()  providerUnavailable,required TResult Function( String message)  validation,required TResult Function()  network,required TResult Function()  unknown,}) {final _that = this;
switch (_that) {
case AssistantEntitlementRequired():
return entitlementRequired();case AssistantAllowanceExhausted():
return allowanceExhausted();case AssistantProviderUnavailable():
return providerUnavailable();case AssistantValidationFailure():
return validation(_that.message);case AssistantNetworkFailure():
return network();case AssistantUnknownFailure():
return unknown();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  entitlementRequired,TResult? Function()?  allowanceExhausted,TResult? Function()?  providerUnavailable,TResult? Function( String message)?  validation,TResult? Function()?  network,TResult? Function()?  unknown,}) {final _that = this;
switch (_that) {
case AssistantEntitlementRequired() when entitlementRequired != null:
return entitlementRequired();case AssistantAllowanceExhausted() when allowanceExhausted != null:
return allowanceExhausted();case AssistantProviderUnavailable() when providerUnavailable != null:
return providerUnavailable();case AssistantValidationFailure() when validation != null:
return validation(_that.message);case AssistantNetworkFailure() when network != null:
return network();case AssistantUnknownFailure() when unknown != null:
return unknown();case _:
  return null;

}
}

}

/// @nodoc


class AssistantEntitlementRequired implements AssistantFailure {
  const AssistantEntitlementRequired();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantEntitlementRequired);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AssistantFailure.entitlementRequired()';
}


}




/// @nodoc


class AssistantAllowanceExhausted implements AssistantFailure {
  const AssistantAllowanceExhausted();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantAllowanceExhausted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AssistantFailure.allowanceExhausted()';
}


}




/// @nodoc


class AssistantProviderUnavailable implements AssistantFailure {
  const AssistantProviderUnavailable();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantProviderUnavailable);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AssistantFailure.providerUnavailable()';
}


}




/// @nodoc


class AssistantValidationFailure implements AssistantFailure {
  const AssistantValidationFailure({required this.message});
  

 final  String message;

/// Create a copy of AssistantFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssistantValidationFailureCopyWith<AssistantValidationFailure> get copyWith => _$AssistantValidationFailureCopyWithImpl<AssistantValidationFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantValidationFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'AssistantFailure.validation(message: $message)';
}


}

/// @nodoc
abstract mixin class $AssistantValidationFailureCopyWith<$Res> implements $AssistantFailureCopyWith<$Res> {
  factory $AssistantValidationFailureCopyWith(AssistantValidationFailure value, $Res Function(AssistantValidationFailure) _then) = _$AssistantValidationFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$AssistantValidationFailureCopyWithImpl<$Res>
    implements $AssistantValidationFailureCopyWith<$Res> {
  _$AssistantValidationFailureCopyWithImpl(this._self, this._then);

  final AssistantValidationFailure _self;
  final $Res Function(AssistantValidationFailure) _then;

/// Create a copy of AssistantFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(AssistantValidationFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AssistantNetworkFailure implements AssistantFailure {
  const AssistantNetworkFailure();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantNetworkFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AssistantFailure.network()';
}


}




/// @nodoc


class AssistantUnknownFailure implements AssistantFailure {
  const AssistantUnknownFailure();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantUnknownFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AssistantFailure.unknown()';
}


}




// dart format on
