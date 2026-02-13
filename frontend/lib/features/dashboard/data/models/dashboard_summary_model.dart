import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.todaysCost,
    required super.baselineCost,
    required super.savingsPercent,
    required super.peakLoadKw,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> j) {
    return DashboardSummaryModel(
      todaysCost: (j['todays_cost'] as num).toDouble(),
      baselineCost: (j['baseline_cost'] as num).toDouble(),
      savingsPercent: (j['savings_percent'] as num).toDouble(),
      peakLoadKw: (j['peak_load_kw'] as num).toDouble(),
    );
  }
}
