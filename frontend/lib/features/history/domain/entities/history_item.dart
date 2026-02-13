import 'package:equatable/equatable.dart';

class HistoryItem extends Equatable {
  final int id;
  final DateTime createdAt;
  final double totalCost;
  final double peakKw;
  final double savingsPercent;

  const HistoryItem({
    required this.id,
    required this.createdAt,
    required this.totalCost,
    required this.peakKw,
    required this.savingsPercent,
  });

  @override
  List<Object?> get props => [id, createdAt, totalCost, peakKw, savingsPercent];
}
