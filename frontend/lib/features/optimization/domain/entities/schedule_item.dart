// lib/features/optimization/domain/entities/schedule_item.dart
import 'package:equatable/equatable.dart';

class ScheduleItem extends Equatable {
  final int applianceId;
  final String applianceName;
  final int startMin;
  final int endMin;
  final int powerW;
  final double cost;

  const ScheduleItem({
    required this.applianceId,
    required this.applianceName,
    required this.startMin,
    required this.endMin,
    required this.powerW,
    required this.cost,
  });

  @override
  List<Object?> get props => [applianceId, applianceName, startMin, endMin, powerW, cost];
}
