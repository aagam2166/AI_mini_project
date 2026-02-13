// lib/features/preferences/domain/entities/preferences.dart
import 'package:equatable/equatable.dart';

class Preferences extends Equatable {
  final int id;
  final double comfortLevel;
  final int maxDelayMin;
  final bool nightUsageAllowed;
  final double costSavingPriority;

  const Preferences({
    required this.id,
    required this.comfortLevel,
    required this.maxDelayMin,
    required this.nightUsageAllowed,
    required this.costSavingPriority,
  });

  @override
  List<Object?> get props => [id, comfortLevel, maxDelayMin, nightUsageAllowed, costSavingPriority];
}
