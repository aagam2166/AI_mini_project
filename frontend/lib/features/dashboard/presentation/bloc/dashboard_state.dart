part of 'dashboard_bloc.dart';

class DashboardState extends Equatable {
  final bool loading;
  final DashboardSummary? summary;
  final String? error;

  const DashboardState({required this.loading, required this.summary, required this.error});

  factory DashboardState.initial() => const DashboardState(loading: false, summary: null, error: null);

  DashboardState copyWith({bool? loading, DashboardSummary? summary, String? error}) {
    return DashboardState(
      loading: loading ?? this.loading,
      summary: summary ?? this.summary,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, summary, error];
}
