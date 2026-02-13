// lib/features/preferences/presentation/bloc/preferences_event.dart
part of 'preferences_bloc.dart';

abstract class PreferencesEvent extends Equatable {
  const PreferencesEvent();
  @override
  List<Object?> get props => [];
}

class PreferencesLoadRequested extends PreferencesEvent {}

class PreferencesChanged extends PreferencesEvent {
  final Preferences prefs;
  const PreferencesChanged(this.prefs);
  @override
  List<Object?> get props => [prefs];
}

class PreferencesSaveRequested extends PreferencesEvent {}
