// lib/features/preferences/data/datasources/preferences_remote_ds.dart
import '../../../../core/network/api_client.dart';
import '../models/preferences_model.dart';

class PreferencesRemoteDs {
  final ApiClient api;
  PreferencesRemoteDs(this.api);

  Future<PreferencesModel> get() async {
    final res = await api.get<Map<String, dynamic>>("/preferences");
    return PreferencesModel.fromJson(res.data!);
  }

  Future<PreferencesModel> update(PreferencesModel p) async {
    final res = await api.put<Map<String, dynamic>>("/preferences", data: p.toJson());
    return PreferencesModel.fromJson(res.data!);
  }
}
