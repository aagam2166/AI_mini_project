// lib/features/preferences/domain/usecases/get_preferences.dart
import '../entities/preferences.dart';
import '../repositories/preferences_repo.dart';

class GetPreferences {
  final PreferencesRepo repo;
  GetPreferences(this.repo);
  Future<Preferences> call() => repo.get();
}
