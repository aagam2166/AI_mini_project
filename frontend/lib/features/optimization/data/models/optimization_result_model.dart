// lib/features/optimization/data/models/optimization_result_model.dart
import '../../domain/entities/optimization_result.dart';
import '../../domain/entities/schedule_item.dart';

class ScheduleItemModel extends ScheduleItem {
  const ScheduleItemModel({
    required super.applianceId,
    required super.applianceName,
    required super.startMin,
    required super.endMin,
    required super.powerW,
    required super.cost,
  });

  factory ScheduleItemModel.fromJson(Map<String, dynamic> j) => ScheduleItemModel(
        applianceId: j['appliance_id'],
        applianceName: j['appliance_name'],
        startMin: j['start_min'],
        endMin: j['end_min'],
        powerW: j['power_w'],
        cost: (j['cost'] as num).toDouble(),
      );
}

class OptimizationResultModel extends OptimizationResult {
  const OptimizationResultModel({
    required super.runId,
    required super.algorithm,
    required super.objective,
    required super.totalCost,
    required super.peakKw,
    required super.runtimeMs,
    required super.baselineCost,
    required super.baselinePeakKw,
    required super.schedule,
  });

  factory OptimizationResultModel.fromJson(Map<String, dynamic> j) {
    final sch = (j['schedule'] as List).map((e) => ScheduleItemModel.fromJson(e)).toList();
    return OptimizationResultModel(
      runId: j['run_id'],
      algorithm: j['algorithm'],
      objective: j['objective'],
      totalCost: (j['total_cost'] as num).toDouble(),
      peakKw: (j['peak_kw'] as num).toDouble(),
      runtimeMs: j['runtime_ms'],
      baselineCost: (j['baseline_cost'] as num).toDouble(),
      baselinePeakKw: (j['baseline_peak_kw'] as num).toDouble(),
      schedule: sch,
    );
  }
}
