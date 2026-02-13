import '../../../../core/network/api_client.dart';
import '../models/dashboard_summary_model.dart';

class DashboardRemoteDs {
  final ApiClient api;
  DashboardRemoteDs(this.api);

  Future<DashboardSummaryModel> getSummary() async {
    final res = await api.get<Map<String, dynamic>>("/dashboard");
    return DashboardSummaryModel.fromJson(res.data!);
  }
}
