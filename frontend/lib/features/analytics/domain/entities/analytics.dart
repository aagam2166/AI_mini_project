import 'package:equatable/equatable.dart';

class Analytics extends Equatable {
  final double costBaseline;
  final double costOptimized;
  final double peakBeforeKw;
  final double peakAfterKw;
  final List<double> weeklyCosts;

  const Analytics({
    required this.costBaseline,
    required this.costOptimized,
    required this.peakBeforeKw,
    required this.peakAfterKw,
    required this.weeklyCosts,
  });

  @override
  List<Object?> get props => [costBaseline, costOptimized, peakBeforeKw, peakAfterKw, weeklyCosts];
}
