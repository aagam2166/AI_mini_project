import '../repositories/appliances_repo.dart';

class DeleteAppliance {
  final AppliancesRepo repo;
  DeleteAppliance(this.repo);

  Future<void> call(int id) => repo.delete(id);
}
