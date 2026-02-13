// lib/features/preferences/presentation/bloc/preferences_state.dart
part of 'preferences_bloc.dart';

class PreferencesState extends Equatable {
  final bool loading;
  final bool saving;
  final Preferences? prefs;
  final String? error;

  const PreferencesState({
    required this.loading,
    required this.saving,
    required this.prefs,
    required this.error,
  });

  factory PreferencesState.initial() => const PreferencesState(
        loading: false,
        saving: false,
        prefs: null,
        error: null,
      );

  PreferencesState copyWith({
    bool? loading,
    bool? saving,
    Preferences? prefs,
    String? error,
  }) {
    return PreferencesState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      prefs: prefs ?? this.prefs,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, saving, prefs, error];
}
