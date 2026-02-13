import 'package:equatable/equatable.dart';
import '../../domain/entities/appliance.dart';

class AppliancesState extends Equatable {
  final bool loading;
  final List<Appliance> appliances;
  final String? error;

  const AppliancesState({
    required this.loading,
    required this.appliances,
    required this.error,
  });

  factory AppliancesState.initial() => const AppliancesState(
        loading: false,
        appliances: [],
        error: null,
      );

  AppliancesState copyWith({
    bool? loading,
    List<Appliance>? appliances,
    String? error,
  }) {
    return AppliancesState(
      loading: loading ?? this.loading,
      appliances: appliances ?? this.appliances,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, appliances, error];
}
