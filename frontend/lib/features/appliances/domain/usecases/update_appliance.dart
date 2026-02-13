import '../entities/appliance.dart';
import '../repositories/appliances_repo.dart';

class UpdateAppliance {
  final AppliancesRepo repo;
  UpdateAppliance(this.repo);

  Future<Appliance> call(int id, Map<String, dynamic> patch) => repo.update(id, patch);
}
