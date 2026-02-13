import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/analytics.dart';
import '../../domain/usecases/get_analytics.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetAnalytics getAnalytics;
  AnalyticsBloc({required this.getAnalytics}) : super(AnalyticsState.initial()) {
    on<AnalyticsLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(AnalyticsLoadRequested e, Emitter<AnalyticsState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final a = await getAnalytics();
      emit(state.copyWith(loading: false, analytics: a));
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }
}
