import 'package:flutter_bloc/flutter_bloc.dart';
import 'appliances_event.dart';
import 'appliances_state.dart';

import '../../domain/usecases/get_appliances.dart';
import '../../domain/usecases/add_appliance.dart';
import '../../domain/usecases/update_appliance.dart';
import '../../domain/usecases/delete_appliance.dart';

class AppliancesBloc extends Bloc<AppliancesEvent, AppliancesState> {
  final GetAppliances getAppliances;
  final AddAppliance addAppliance;
  final UpdateAppliance updateAppliance;
  final DeleteAppliance deleteAppliance;

  AppliancesBloc({
    required this.getAppliances,
    required this.addAppliance,
    required this.updateAppliance,
    required this.deleteAppliance,
  }) : super(AppliancesState.initial()) {
    on<AppliancesLoadRequested>(_onLoad);
    on<ApplianceAddRequested>(_onAdd);
    on<ApplianceToggleRequested>(_onToggle);
    on<ApplianceDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(AppliancesLoadRequested e, Emitter<AppliancesState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final items = await getAppliances();
      emit(state.copyWith(loading: false, appliances: items));
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }

  Future<void> _onAdd(ApplianceAddRequested e, Emitter<AppliancesState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await addAppliance(
        name: e.name,
        powerW: e.powerW,
        durationMin: e.durationMin,
        earliestMin: e.earliestMin,
        latestMin: e.latestMin,
        enabled: true,
      );
      final items = await getAppliances();
      emit(state.copyWith(loading: false, appliances: items));
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }

  Future<void> _onToggle(ApplianceToggleRequested e, Emitter<AppliancesState> emit) async {
    try {
      await updateAppliance(e.id, {"enabled": e.enabled});
      final items = await getAppliances();
      emit(state.copyWith(appliances: items));
    } catch (err) {
      emit(state.copyWith(error: err.toString()));
    }
  }

  Future<void> _onDelete(ApplianceDeleteRequested e, Emitter<AppliancesState> emit) async {
    try {
      await deleteAppliance(e.id);
      final items = await getAppliances();
      emit(state.copyWith(appliances: items));
    } catch (err) {
      emit(state.copyWith(error: err.toString()));
    }
  }
}
