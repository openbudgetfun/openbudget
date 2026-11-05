/// Small defensive helpers for reading third-party webhook JSON.
library;

Map<String, Object?>? asJsonMap(Object? value) {
  if (value is! Map) return null;
  return {
    for (final entry in value.entries)
      if (entry.key is String) entry.key as String: entry.value,
  };
}

String? asJsonString(Object? value) {
  if (value is String && value.isNotEmpty) return value;
  return null;
}

int? asJsonInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

DateTime? asUnixDateTime(Object? value) {
  final seconds = asJsonInt(value);
  if (seconds == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
}

bool isUuid(String? value) {
  if (value == null) return false;
  return RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  ).hasMatch(value);
}
