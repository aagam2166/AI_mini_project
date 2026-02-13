import '../entities/appliance.dart';
import '../repositories/appliances_repo.dart';

class AddAppliance {
  final AppliancesRepo repo;
  AddAppliance(this.repo);

  Future<Appliance> call({
    required String name,
    required int powerW,
    required int durationMin,
    required int earliestMin,
    required int latestMin,
    required bool enabled,
  }) {
    return repo.add(
      name: name,
      powerW: powerW,
      durationMin: durationMin,
      earliestMin: earliestMin,
      latestMin: latestMin,
      enabled: enabled,
    );
  }
}
