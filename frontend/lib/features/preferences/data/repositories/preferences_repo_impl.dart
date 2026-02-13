// lib/features/preferences/data/repositories/preferences_repo_impl.dart
import '../../domain/entities/preferences.dart';
import '../../domain/repositories/preferences_repo.dart';
import '../datasources/preferences_remote_ds.dart';
import '../models/preferences_model.dart';

class PreferencesRepoImpl implements PreferencesRepo {
  final PreferencesRemoteDs remote;
  PreferencesRepoImpl(this.remote);

  @override
  Future<Preferences> get() => remote.get();

  @override
  Future<Preferences> update(Preferences p) {
    final m = PreferencesModel(
      id: p.id,
      comfortLevel: p.comfortLevel,
      maxDelayMin: p.maxDelayMin,
      nightUsageAllowed: p.nightUsageAllowed,
      costSavingPriority: p.costSavingPriority,
    );
    return remote.update(m);
  }
}
