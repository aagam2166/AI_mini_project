// lib/features/optimization/data/datasources/optimization_remote_ds.dart
import '../../../../core/network/api_client.dart';
import '../models/optimization_result_model.dart';

class OptimizationRemoteDs {
  final ApiClient api;
  OptimizationRemoteDs(this.api);

  Future<OptimizationResultModel> run(int powerLimitW) async {
    final res = await api.post<Map<String, dynamic>>("/optimize", data: {
      "power_limit_w": powerLimitW,
      "day_minutes": 1440,
    });
    return OptimizationResultModel.fromJson(res.data!);
  }
}
