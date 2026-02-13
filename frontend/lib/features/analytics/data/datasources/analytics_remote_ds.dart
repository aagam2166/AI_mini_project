import '../../../../core/network/api_client.dart';
import '../models/analytics_model.dart';

class AnalyticsRemoteDs {
  final ApiClient api;
  AnalyticsRemoteDs(this.api);

  Future<AnalyticsModel> get() async {
    final res = await api.get<Map<String, dynamic>>("/analytics");
    return AnalyticsModel.fromJson(res.data!);
  }
}
