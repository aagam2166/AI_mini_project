import '../../domain/entities/analytics.dart';

class AnalyticsModel extends Analytics {
  const AnalyticsModel({
    required super.costBaseline,
    required super.costOptimized,
    required super.peakBeforeKw,
    required super.peakAfterKw,
    required super.weeklyCosts,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> j) {
    final weekly = (j['weekly_costs'] as List).map((e) => (e as num).toDouble()).toList();
    return AnalyticsModel(
      costBaseline: (j['cost_baseline'] as num).toDouble(),
      costOptimized: (j['cost_optimized'] as num).toDouble(),
      peakBeforeKw: (j['peak_before_kw'] as num).toDouble(),
      peakAfterKw: (j['peak_after_kw'] as num).toDouble(),
      weeklyCosts: weekly,
    );
  }
}
