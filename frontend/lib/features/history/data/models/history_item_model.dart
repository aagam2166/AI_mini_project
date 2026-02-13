import '../../domain/entities/history_item.dart';

class HistoryItemModel extends HistoryItem {
  const HistoryItemModel({
    required super.id,
    required super.createdAt,
    required super.totalCost,
    required super.peakKw,
    required super.savingsPercent,
  });

  factory HistoryItemModel.fromJson(Map<String, dynamic> j) {
    return HistoryItemModel(
      id: j['id'],
      createdAt: DateTime.parse(j['created_at']),
      totalCost: (j['total_cost'] as num).toDouble(),
      peakKw: (j['peak_kw'] as num).toDouble(),
      savingsPercent: (j['savings_percent'] as num).toDouble(),
    );
  }
}
