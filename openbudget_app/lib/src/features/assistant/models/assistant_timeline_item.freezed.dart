// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assistant_timeline_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AssistantTimelineItem {

 DateTime get createdAt;
/// Create a copy of AssistantTimelineItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssistantTimelineItemCopyWith<AssistantTimelineItem> get copyWith => _$AssistantTimelineItemCopyWithImpl<AssistantTimelineItem>(this as AssistantTimelineItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AssistantTimelineItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantTimelineItem&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as AssistantTimelineItem;
  return Object.hash(runtimeType,_this.createdAt);
}

@override
String toString() {
  final _this = this as AssistantTimelineItem;
  return 'AssistantTimelineItem(createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $AssistantTimelineItemCopyWith<$Res>  {
  factory $AssistantTimelineItemCopyWith(AssistantTimelineItem value, $Res Function(AssistantTimelineItem) _then) = _$AssistantTimelineItemCopyWithImpl;
@useResult
$Res call({
 DateTime createdAt
});




}
/// @nodoc
class _$AssistantTimelineItemCopyWithImpl<$Res>
    implements $AssistantTimelineItemCopyWith<$Res> {
  _$AssistantTimelineItemCopyWithImpl(this._self, this._then);

  final AssistantTimelineItem _self;
  final $Res Function(AssistantTimelineItem) _then;

/// Create a copy of AssistantTimelineItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? createdAt = null,}) {
  return _then(_self.copyWith(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AssistantTimelineItem].
extension AssistantTimelineItemPatterns on AssistantTimelineItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AssistantUserMessage value)?  user,TResult Function( AssistantAssistantMessage value)?  assistant,TResult Function( AssistantToolCall value)?  tool,TResult Function( AssistantProposalItem value)?  proposal,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AssistantUserMessage() when user != null:
return user(_that);case AssistantAssistantMessage() when assistant != null:
return assistant(_that);case AssistantToolCall() when tool != null:
return tool(_that);case AssistantProposalItem() when proposal != null:
return proposal(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AssistantUserMessage value)  user,required TResult Function( AssistantAssistantMessage value)  assistant,required TResult Function( AssistantToolCall value)  tool,required TResult Function( AssistantProposalItem value)  proposal,}){
final _that = this;
switch (_that) {
case AssistantUserMessage():
return user(_that);case AssistantAssistantMessage():
return assistant(_that);case AssistantToolCall():
return tool(_that);case AssistantProposalItem():
return proposal(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AssistantUserMessage value)?  user,TResult? Function( AssistantAssistantMessage value)?  assistant,TResult? Function( AssistantToolCall value)?  tool,TResult? Function( AssistantProposalItem value)?  proposal,}){
final _that = this;
switch (_that) {
case AssistantUserMessage() when user != null:
return user(_that);case AssistantAssistantMessage() when assistant != null:
return assistant(_that);case AssistantToolCall() when tool != null:
return tool(_that);case AssistantProposalItem() when proposal != null:
return proposal(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String text,  DateTime createdAt)?  user,TResult Function( String text,  DateTime createdAt)?  assistant,TResult Function( String toolName,  DateTime createdAt)?  tool,TResult Function( AssistantProposalCard proposal,  DateTime createdAt)?  proposal,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AssistantUserMessage() when user != null:
return user(_that.text,_that.createdAt);case AssistantAssistantMessage() when assistant != null:
return assistant(_that.text,_that.createdAt);case AssistantToolCall() when tool != null:
return tool(_that.toolName,_that.createdAt);case AssistantProposalItem() when proposal != null:
return proposal(_that.proposal,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String text,  DateTime createdAt)  user,required TResult Function( String text,  DateTime createdAt)  assistant,required TResult Function( String toolName,  DateTime createdAt)  tool,required TResult Function( AssistantProposalCard proposal,  DateTime createdAt)  proposal,}) {final _that = this;
switch (_that) {
case AssistantUserMessage():
return user(_that.text,_that.createdAt);case AssistantAssistantMessage():
return assistant(_that.text,_that.createdAt);case AssistantToolCall():
return tool(_that.toolName,_that.createdAt);case AssistantProposalItem():
return proposal(_that.proposal,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String text,  DateTime createdAt)?  user,TResult? Function( String text,  DateTime createdAt)?  assistant,TResult? Function( String toolName,  DateTime createdAt)?  tool,TResult? Function( AssistantProposalCard proposal,  DateTime createdAt)?  proposal,}) {final _that = this;
switch (_that) {
case AssistantUserMessage() when user != null:
return user(_that.text,_that.createdAt);case AssistantAssistantMessage() when assistant != null:
return assistant(_that.text,_that.createdAt);case AssistantToolCall() when tool != null:
return tool(_that.toolName,_that.createdAt);case AssistantProposalItem() when proposal != null:
return proposal(_that.proposal,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class AssistantUserMessage implements AssistantTimelineItem {
  const AssistantUserMessage({required this.text, required this.createdAt});
  

 final  String text;
@override final  DateTime createdAt;

/// Create a copy of AssistantTimelineItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssistantUserMessageCopyWith<AssistantUserMessage> get copyWith => _$AssistantUserMessageCopyWithImpl<AssistantUserMessage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantUserMessage&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,text,createdAt);
}

@override
String toString() {
    return 'AssistantTimelineItem.user(text: $text, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AssistantUserMessageCopyWith<$Res> implements $AssistantTimelineItemCopyWith<$Res> {
  factory $AssistantUserMessageCopyWith(AssistantUserMessage value, $Res Function(AssistantUserMessage) _then) = _$AssistantUserMessageCopyWithImpl;
@override @useResult
$Res call({
 String text, DateTime createdAt
});




}
/// @nodoc
class _$AssistantUserMessageCopyWithImpl<$Res>
    implements $AssistantUserMessageCopyWith<$Res> {
  _$AssistantUserMessageCopyWithImpl(this._self, this._then);

  final AssistantUserMessage _self;
  final $Res Function(AssistantUserMessage) _then;

/// Create a copy of AssistantTimelineItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? createdAt = null,}) {
  return _then(AssistantUserMessage(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class AssistantAssistantMessage implements AssistantTimelineItem {
  const AssistantAssistantMessage({required this.text, required this.createdAt});
  

 final  String text;
@override final  DateTime createdAt;

/// Create a copy of AssistantTimelineItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssistantAssistantMessageCopyWith<AssistantAssistantMessage> get copyWith => _$AssistantAssistantMessageCopyWithImpl<AssistantAssistantMessage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantAssistantMessage&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,text,createdAt);
}

@override
String toString() {
    return 'AssistantTimelineItem.assistant(text: $text, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AssistantAssistantMessageCopyWith<$Res> implements $AssistantTimelineItemCopyWith<$Res> {
  factory $AssistantAssistantMessageCopyWith(AssistantAssistantMessage value, $Res Function(AssistantAssistantMessage) _then) = _$AssistantAssistantMessageCopyWithImpl;
@override @useResult
$Res call({
 String text, DateTime createdAt
});




}
/// @nodoc
class _$AssistantAssistantMessageCopyWithImpl<$Res>
    implements $AssistantAssistantMessageCopyWith<$Res> {
  _$AssistantAssistantMessageCopyWithImpl(this._self, this._then);

  final AssistantAssistantMessage _self;
  final $Res Function(AssistantAssistantMessage) _then;

/// Create a copy of AssistantTimelineItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? createdAt = null,}) {
  return _then(AssistantAssistantMessage(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class AssistantToolCall implements AssistantTimelineItem {
  const AssistantToolCall({required this.toolName, required this.createdAt});
  

 final  String toolName;
@override final  DateTime createdAt;

/// Create a copy of AssistantTimelineItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssistantToolCallCopyWith<AssistantToolCall> get copyWith => _$AssistantToolCallCopyWithImpl<AssistantToolCall>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantToolCall&&(identical(other.toolName, toolName) || other.toolName == toolName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,toolName,createdAt);
}

@override
String toString() {
    return 'AssistantTimelineItem.tool(toolName: $toolName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AssistantToolCallCopyWith<$Res> implements $AssistantTimelineItemCopyWith<$Res> {
  factory $AssistantToolCallCopyWith(AssistantToolCall value, $Res Function(AssistantToolCall) _then) = _$AssistantToolCallCopyWithImpl;
@override @useResult
$Res call({
 String toolName, DateTime createdAt
});




}
/// @nodoc
class _$AssistantToolCallCopyWithImpl<$Res>
    implements $AssistantToolCallCopyWith<$Res> {
  _$AssistantToolCallCopyWithImpl(this._self, this._then);

  final AssistantToolCall _self;
  final $Res Function(AssistantToolCall) _then;

/// Create a copy of AssistantTimelineItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? toolName = null,Object? createdAt = null,}) {
  return _then(AssistantToolCall(
toolName: null == toolName ? _self.toolName : toolName // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class AssistantProposalItem implements AssistantTimelineItem {
  const AssistantProposalItem({required this.proposal, required this.createdAt});
  

 final  AssistantProposalCard proposal;
@override final  DateTime createdAt;

/// Create a copy of AssistantTimelineItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssistantProposalItemCopyWith<AssistantProposalItem> get copyWith => _$AssistantProposalItemCopyWithImpl<AssistantProposalItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantProposalItem&&(identical(other.proposal, proposal) || other.proposal == proposal)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,proposal,createdAt);
}

@override
String toString() {
    return 'AssistantTimelineItem.proposal(proposal: $proposal, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AssistantProposalItemCopyWith<$Res> implements $AssistantTimelineItemCopyWith<$Res> {
  factory $AssistantProposalItemCopyWith(AssistantProposalItem value, $Res Function(AssistantProposalItem) _then) = _$AssistantProposalItemCopyWithImpl;
@override @useResult
$Res call({
 AssistantProposalCard proposal, DateTime createdAt
});


$AssistantProposalCardCopyWith<$Res> get proposal;

}
/// @nodoc
class _$AssistantProposalItemCopyWithImpl<$Res>
    implements $AssistantProposalItemCopyWith<$Res> {
  _$AssistantProposalItemCopyWithImpl(this._self, this._then);

  final AssistantProposalItem _self;
  final $Res Function(AssistantProposalItem) _then;

/// Create a copy of AssistantTimelineItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proposal = null,Object? createdAt = null,}) {
  return _then(AssistantProposalItem(
proposal: null == proposal ? _self.proposal : proposal // ignore: cast_nullable_to_non_nullable
as AssistantProposalCard,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of AssistantTimelineItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssistantProposalCardCopyWith<$Res> get proposal {
  
  return $AssistantProposalCardCopyWith<$Res>(_self.proposal, (value) {
    return _then(_self.copyWith(proposal: value));
  });
}
}

/// @nodoc
mixin _$AssistantProposalCard {

 String get id; String get summary; AgentProposalKind get kind; AgentProposalStatus get status; DateTime get createdAt;
/// Create a copy of AssistantProposalCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssistantProposalCardCopyWith<AssistantProposalCard> get copyWith => _$AssistantProposalCardCopyWithImpl<AssistantProposalCard>(this as AssistantProposalCard, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AssistantProposalCard;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssistantProposalCard&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as AssistantProposalCard;
  return Object.hash(runtimeType,_this.id,_this.summary,_this.kind,_this.status,_this.createdAt);
}

@override
String toString() {
  final _this = this as AssistantProposalCard;
  return 'AssistantProposalCard(id: ${_this.id}, summary: ${_this.summary}, kind: ${_this.kind}, status: ${_this.status}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $AssistantProposalCardCopyWith<$Res>  {
  factory $AssistantProposalCardCopyWith(AssistantProposalCard value, $Res Function(AssistantProposalCard) _then) = _$AssistantProposalCardCopyWithImpl;
@useResult
$Res call({
 String id, String summary, AgentProposalKind kind, AgentProposalStatus status, DateTime createdAt
});




}
/// @nodoc
class _$AssistantProposalCardCopyWithImpl<$Res>
    implements $AssistantProposalCardCopyWith<$Res> {
  _$AssistantProposalCardCopyWithImpl(this._self, this._then);

  final AssistantProposalCard _self;
  final $Res Function(AssistantProposalCard) _then;

/// Create a copy of AssistantProposalCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? summary = null,Object? kind = null,Object? status = null,Object? createdAt = null,}) {
  return _then(AssistantProposalCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as AgentProposalKind,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AgentProposalStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AssistantProposalCard].
extension AssistantProposalCardPatterns on AssistantProposalCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssistantProposalCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssistantProposalCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssistantProposalCard value)  $default,){
final _that = this;
switch (_that) {
case _AssistantProposalCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssistantProposalCard value)?  $default,){
final _that = this;
switch (_that) {
case _AssistantProposalCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String summary,  AgentProposalKind kind,  AgentProposalStatus status,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssistantProposalCard() when $default != null:
return $default(_that.id,_that.summary,_that.kind,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String summary,  AgentProposalKind kind,  AgentProposalStatus status,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AssistantProposalCard():
return $default(_that.id,_that.summary,_that.kind,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String summary,  AgentProposalKind kind,  AgentProposalStatus status,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AssistantProposalCard() when $default != null:
return $default(_that.id,_that.summary,_that.kind,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _AssistantProposalCard implements AssistantProposalCard {
  const _AssistantProposalCard({required this.id, required this.summary, required this.kind, required this.status, required this.createdAt});
  

@override final  String id;
@override final  String summary;
@override final  AgentProposalKind kind;
@override final  AgentProposalStatus status;
@override final  DateTime createdAt;

/// Create a copy of AssistantProposalCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssistantProposalCardCopyWith<_AssistantProposalCard> get copyWith => __$AssistantProposalCardCopyWithImpl<_AssistantProposalCard>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssistantProposalCard&&(identical(other.id, id) || other.id == id)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,summary,kind,status,createdAt);
}

@override
String toString() {
    return 'AssistantProposalCard(id: $id, summary: $summary, kind: $kind, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AssistantProposalCardCopyWith<$Res> implements $AssistantProposalCardCopyWith<$Res> {
  factory _$AssistantProposalCardCopyWith(_AssistantProposalCard value, $Res Function(_AssistantProposalCard) _then) = __$AssistantProposalCardCopyWithImpl;
@override @useResult
$Res call({
 String id, String summary, AgentProposalKind kind, AgentProposalStatus status, DateTime createdAt
});




}
/// @nodoc
class __$AssistantProposalCardCopyWithImpl<$Res>
    implements _$AssistantProposalCardCopyWith<$Res> {
  __$AssistantProposalCardCopyWithImpl(this._self, this._then);

  final _AssistantProposalCard _self;
  final $Res Function(_AssistantProposalCard) _then;

/// Create a copy of AssistantProposalCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? summary = null,Object? kind = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_AssistantProposalCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as AgentProposalKind,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AgentProposalStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
