import '../entities/appliance.dart';
import '../repositories/appliances_repo.dart';

class GetAppliances {
  final AppliancesRepo repo;
  GetAppliances(this.repo);
  Future<List<Appliance>> call() => repo.getAll();
}
