// lib/features/optimization/data/repositories/optimization_repo_impl.dart
import '../../domain/entities/optimization_result.dart';
import '../../domain/repositories/optimization_repo.dart';
import '../datasources/optimization_remote_ds.dart';

class OptimizationRepoImpl implements OptimizationRepo {
  final OptimizationRemoteDs remote;
  OptimizationRepoImpl(this.remote);

  @override
  Future<OptimizationResult> run({required int powerLimitW}) => remote.run(powerLimitW);
}
