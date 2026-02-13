// lib/features/preferences/domain/repositories/preferences_repo.dart
import '../entities/preferences.dart';

abstract class PreferencesRepo {
  Future<Preferences> get();
  Future<Preferences> update(Preferences p);
}
