// lib/features/optimization/domain/usecases/run_optimization.dart
import '../entities/optimization_result.dart';
import '../repositories/optimization_repo.dart';

class RunOptimization {
  final OptimizationRepo repo;
  RunOptimization(this.repo);

  Future<OptimizationResult> call({required int powerLimitW}) => repo.run(powerLimitW: powerLimitW);
}
