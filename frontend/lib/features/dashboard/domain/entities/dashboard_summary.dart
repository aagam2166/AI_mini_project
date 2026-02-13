import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  final double todaysCost;
  final double baselineCost;
  final double savingsPercent;
  final double peakLoadKw;

  const DashboardSummary({
    required this.todaysCost,
    required this.baselineCost,
    required this.savingsPercent,
    required this.peakLoadKw,
  });

  @override
  List<Object?> get props => [todaysCost, baselineCost, savingsPercent, peakLoadKw];
}
