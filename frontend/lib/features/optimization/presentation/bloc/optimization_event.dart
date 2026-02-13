// lib/features/optimization/presentation/bloc/optimization_event.dart
part of 'optimization_bloc.dart';

abstract class OptimizationEvent extends Equatable {
  const OptimizationEvent();
  @override
  List<Object?> get props => [];
}

class OptimizationRequested extends OptimizationEvent {
  final int powerLimitW;
  const OptimizationRequested(this.powerLimitW);
  @override
  List<Object?> get props => [powerLimitW];
}
