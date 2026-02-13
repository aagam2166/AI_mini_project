part of 'analytics_bloc.dart';

class AnalyticsState extends Equatable {
  final bool loading;
  final Analytics? analytics;
  final String? error;

  const AnalyticsState({required this.loading, required this.analytics, required this.error});

  factory AnalyticsState.initial() => const AnalyticsState(loading: false, analytics: null, error: null);

  AnalyticsState copyWith({bool? loading, Analytics? analytics, String? error}) {
    return AnalyticsState(
      loading: loading ?? this.loading,
      analytics: analytics ?? this.analytics,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, analytics, error];
}
