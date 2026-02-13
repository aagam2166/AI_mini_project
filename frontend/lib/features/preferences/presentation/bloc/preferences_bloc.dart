// lib/features/preferences/presentation/bloc/preferences_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/preferences.dart';
import '../../domain/usecases/get_preferences.dart';
import '../../domain/usecases/update_preferences.dart';

part 'preferences_event.dart';
part 'preferences_state.dart';

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  final GetPreferences getPreferences;
  final UpdatePreferences updatePreferences;

  PreferencesBloc({required this.getPreferences, required this.updatePreferences})
      : super(PreferencesState.initial()) {
    on<PreferencesLoadRequested>(_onLoad);
    on<PreferencesChanged>(_onChanged);
    on<PreferencesSaveRequested>(_onSave);
  }

  Future<void> _onLoad(PreferencesLoadRequested e, Emitter<PreferencesState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final p = await getPreferences();
      emit(state.copyWith(loading: false, prefs: p));
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }

  void _onChanged(PreferencesChanged e, Emitter<PreferencesState> emit) {
    emit(state.copyWith(prefs: e.prefs));
  }

  Future<void> _onSave(PreferencesSaveRequested e, Emitter<PreferencesState> emit) async {
    if (state.prefs == null) return;
    emit(state.copyWith(saving: true, error: null));
    try {
      final saved = await updatePreferences(state.prefs!);
      emit(state.copyWith(saving: false, prefs: saved));
    } catch (err) {
      emit(state.copyWith(saving: false, error: err.toString()));
    }
  }
}
