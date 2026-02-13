import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/usecases/get_history.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistory getHistory;
  HistoryBloc({required this.getHistory}) : super(HistoryState.initial()) {
    on<HistoryLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(HistoryLoadRequested e, Emitter<HistoryState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final items = await getHistory();
      emit(state.copyWith(loading: false, items: items));
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }
}
