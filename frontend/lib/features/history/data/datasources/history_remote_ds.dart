import '../../../../core/network/api_client.dart';
import '../models/history_item_model.dart';

class HistoryRemoteDs {
  final ApiClient api;
  HistoryRemoteDs(this.api);

  Future<List<HistoryItemModel>> get() async {
    final res = await api.get<List<dynamic>>("/history");
    final data = (res.data ?? []);
    return data.map((e) => HistoryItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
