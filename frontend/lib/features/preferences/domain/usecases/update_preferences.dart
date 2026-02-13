// lib/features/preferences/domain/usecases/update_preferences.dart
import '../entities/preferences.dart';
import '../repositories/preferences_repo.dart';

class UpdatePreferences {
  final PreferencesRepo repo;
  UpdatePreferences(this.repo);
  Future<Preferences> call(Preferences p) => repo.update(p);
}
