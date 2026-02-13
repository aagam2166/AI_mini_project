import 'package:equatable/equatable.dart';

abstract class AppliancesEvent extends Equatable {
  const AppliancesEvent();
  @override
  List<Object?> get props => [];
}

class AppliancesLoadRequested extends AppliancesEvent {}

class ApplianceAddRequested extends AppliancesEvent {
  final String name;
  final int powerW;
  final int durationMin;
  final int earliestMin;
  final int latestMin;

  const ApplianceAddRequested({
    required this.name,
    required this.powerW,
    required this.durationMin,
    required this.earliestMin,
    required this.latestMin,
  });

  @override
  List<Object?> get props => [name, powerW, durationMin, earliestMin, latestMin];
}

class ApplianceToggleRequested extends AppliancesEvent {
  final int id;
  final bool enabled;
  const ApplianceToggleRequested(this.id, this.enabled);

  @override
  List<Object?> get props => [id, enabled];
}

class ApplianceDeleteRequested extends AppliancesEvent {
  final int id;
  const ApplianceDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}
