import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/dashboard_summary.dart';
import '../../domain/usecases/get_dashboard.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboard getDashboard;
  DashboardBloc({required this.getDashboard}) : super(DashboardState.initial()) {
    on<DashboardLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(DashboardLoadRequested e, Emitter<DashboardState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final s = await getDashboard();
      emit(state.copyWith(loading: false, summary: s));
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }
}
