// lib/features/optimization/presentation/bloc/optimization_state.dart
part of 'optimization_bloc.dart';

class OptimizationState extends Equatable {
  final bool loading;
  final OptimizationResult? result;
  final String? error;

  const OptimizationState({required this.loading, required this.result, required this.error});

  factory OptimizationState.initial() => const OptimizationState(loading: false, result: null, error: null);

  OptimizationState copyWith({bool? loading, OptimizationResult? result, String? error}) {
    return OptimizationState(
      loading: loading ?? this.loading,
      result: result ?? this.result,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, result, error];
}
