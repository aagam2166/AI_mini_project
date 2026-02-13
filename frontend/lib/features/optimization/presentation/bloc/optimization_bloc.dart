// lib/features/optimization/presentation/bloc/optimization_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/optimization_result.dart';
import '../../domain/usecases/run_optimization.dart';

part 'optimization_event.dart';
part 'optimization_state.dart';

class OptimizationBloc extends Bloc<OptimizationEvent, OptimizationState> {
  final RunOptimization runOptimization;

  OptimizationBloc({required this.runOptimization}) : super(OptimizationState.initial()) {
    on<OptimizationRequested>(_onRun);
  }

  Future<void> _onRun(OptimizationRequested e, Emitter<OptimizationState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final res = await runOptimization(powerLimitW: e.powerLimitW);
      emit(state.copyWith(loading: false, result: res));
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }
}
