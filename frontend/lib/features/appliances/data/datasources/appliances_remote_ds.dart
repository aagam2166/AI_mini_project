import '../../../../core/network/api_client.dart';
import '../models/appliance_model.dart';

class AppliancesRemoteDs {
  final ApiClient api;
  AppliancesRemoteDs(this.api);

  Future<List<ApplianceModel>> getAll() async {
    final res = await api.get<List<dynamic>>("/appliances");
    final data = (res.data ?? []);
    return data.map((e) => ApplianceModel.fromJson(e as Map<String, dynamic>)).toList();
    }

  Future<ApplianceModel> add(ApplianceModel model) async {
    final res = await api.post<Map<String, dynamic>>("/appliances", data: model.toCreateJson());
    return ApplianceModel.fromJson(res.data!);
  }

  Future<ApplianceModel> update(int id, Map<String, dynamic> patch) async {
    final res = await api.patch<Map<String, dynamic>>("/appliances/$id", data: patch);
    return ApplianceModel.fromJson(res.data!);
  }

  Future<void> delete(int id) async {
    await api.delete("/appliances/$id");
  }
}
