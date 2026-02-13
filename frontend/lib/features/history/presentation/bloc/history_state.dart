part of 'history_bloc.dart';

class HistoryState extends Equatable {
  final bool loading;
  final List<HistoryItem> items;
  final String? error;

  const HistoryState({required this.loading, required this.items, required this.error});

  factory HistoryState.initial() => const HistoryState(loading: false, items: [], error: null);

  HistoryState copyWith({bool? loading, List<HistoryItem>? items, String? error}) {
    return HistoryState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, items, error];
}
