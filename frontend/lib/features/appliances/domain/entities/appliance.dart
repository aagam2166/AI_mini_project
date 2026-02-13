import 'package:equatable/equatable.dart';

class Appliance extends Equatable {
  final int id;
  final String name;
  final int powerW;
  final int durationMin;
  final int earliestMin;
  final int latestMin;
  final bool enabled;

  const Appliance({
    required this.id,
    required this.name,
    required this.powerW,
    required this.durationMin,
    required this.earliestMin,
    required this.latestMin,
    required this.enabled,
  });

  @override
  List<Object?> get props => [id, name, powerW, durationMin, earliestMin, latestMin, enabled];
}
