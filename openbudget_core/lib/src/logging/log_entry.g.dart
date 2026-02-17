// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LogEntry _$LogEntryFromJson(Map<String, dynamic> json) => _LogEntry(
  timestamp: DateTime.parse(json['timestamp'] as String),
  level: json['level'] as String,
  source: json['source'] as String,
  message: json['message'] as String,
  loggerName: json['loggerName'] as String,
  error: json['error'] as String?,
  stackTrace: json['stackTrace'] as String?,
);

Map<String, dynamic> _$LogEntryToJson(_LogEntry instance) => <String, dynamic>{
  'timestamp': instance.timestamp.toIso8601String(),
  'level': instance.level,
  'source': instance.source,
  'message': instance.message,
  'loggerName': instance.loggerName,
  'error': instance.error,
  'stackTrace': instance.stackTrace,
};
