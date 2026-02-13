// lib/features/optimization/domain/repositories/optimization_repo.dart
import '../entities/optimization_result.dart';

abstract class OptimizationRepo {
  Future<OptimizationResult> run({required int powerLimitW});
}
