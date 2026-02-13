import '../entities/appliance.dart';

abstract class AppliancesRepo {
  Future<List<Appliance>> getAll();
  Future<Appliance> add({
    required String name,
    required int powerW,
    required int durationMin,
    required int earliestMin,
    required int latestMin,
    required bool enabled,
  });
  Future<Appliance> update(int id, Map<String, dynamic> patch);
  Future<void> delete(int id);
}
