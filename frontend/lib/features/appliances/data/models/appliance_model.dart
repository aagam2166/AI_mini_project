import '../../domain/entities/appliance.dart';

class ApplianceModel extends Appliance {
  const ApplianceModel({
    required super.id,
    required super.name,
    required super.powerW,
    required super.durationMin,
    required super.earliestMin,
    required super.latestMin,
    required super.enabled,
  });

  factory ApplianceModel.fromJson(Map<String, dynamic> j) {
    return ApplianceModel(
      id: j['id'],
      name: j['name'],
      powerW: j['power_w'],
      durationMin: j['duration_min'],
      earliestMin: j['earliest_min'],
      latestMin: j['latest_min'],
      enabled: j['enabled'],
    );
  }

  Map<String, dynamic> toCreateJson() => {
        "name": name,
        "power_w": powerW,
        "duration_min": durationMin,
        "earliest_min": earliestMin,
        "latest_min": latestMin,
        "enabled": enabled,
      };
}
