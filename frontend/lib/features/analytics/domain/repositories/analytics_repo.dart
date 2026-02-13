import '../entities/analytics.dart';

abstract class AnalyticsRepo {
  Future<Analytics> get();
}
