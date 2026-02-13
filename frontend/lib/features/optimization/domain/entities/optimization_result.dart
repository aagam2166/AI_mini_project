// lib/features/optimization/domain/entities/optimization_result.dart
import 'package:equatable/equatable.dart';
import 'schedule_item.dart';

class OptimizationResult extends Equatable {
  final int runId;
  final String algorithm;
  final String objective;
  final double totalCost;
  final double peakKw;
  final int runtimeMs;
  final double baselineCost;
  final double baselinePeakKw;
  final List<ScheduleItem> schedule;

  const OptimizationResult({
    required this.runId,
    required this.algorithm,
    required this.objective,
    required this.totalCost,
    required this.peakKw,
    required this.runtimeMs,
    required this.baselineCost,
    required this.baselinePeakKw,
    required this.schedule,
  });

  @override
  List<Object?> get props => [runId, algorithm, objective, totalCost, peakKw, runtimeMs, baselineCost, baselinePeakKw, schedule];
}
