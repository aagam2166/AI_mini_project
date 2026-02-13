// lib/features/preferences/data/models/preferences_model.dart
import '../../domain/entities/preferences.dart';

class PreferencesModel extends Preferences {
  const PreferencesModel({
    required super.id,
    required super.comfortLevel,
    required super.maxDelayMin,
    required super.nightUsageAllowed,
    required super.costSavingPriority,
  });

  factory PreferencesModel.fromJson(Map<String, dynamic> j) => PreferencesModel(
        id: j['id'],
        comfortLevel: (j['comfort_level'] as num).toDouble(),
        maxDelayMin: j['max_delay_min'],
        nightUsageAllowed: j['night_usage_allowed'],
        costSavingPriority: (j['cost_saving_priority'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "comfort_level": comfortLevel,
        "max_delay_min": maxDelayMin,
        "night_usage_allowed": nightUsageAllowed,
        "cost_saving_priority": costSavingPriority,
      };
}
