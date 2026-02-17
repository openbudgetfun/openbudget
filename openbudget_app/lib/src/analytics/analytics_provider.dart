import 'package:openbudget_app/src/analytics/analytics_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_provider.g.dart';

@Riverpod(keepAlive: true)
AnalyticsService analytics(Ref ref) {
  return AnalyticsService();
}
