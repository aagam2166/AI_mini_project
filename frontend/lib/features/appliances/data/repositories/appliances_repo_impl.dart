import '../../domain/entities/appliance.dart';
import '../../domain/repositories/appliances_repo.dart';
import '../datasources/appliances_remote_ds.dart';
import '../models/appliance_model.dart';

class AppliancesRepoImpl implements AppliancesRepo {
  final AppliancesRemoteDs remote;
  AppliancesRepoImpl(this.remote);

  @override
  Future<List<Appliance>> getAll() => remote.getAll();

  @override
  Future<Appliance> add({
    required String name,
    required int powerW,
    required int durationMin,
    required int earliestMin,
    required int latestMin,
    required bool enabled,
  }) {
    return remote.add(ApplianceModel(
      id: 0,
      name: name,
      powerW: powerW,
      durationMin: durationMin,
      earliestMin: earliestMin,
      latestMin: latestMin,
      enabled: enabled,
    ));
  }

  @override
  Future<void> delete(int id) => remote.delete(id);

  @override
  Future<Appliance> update(int id, Map<String, dynamic> patch) => remote.update(id, patch);
}
