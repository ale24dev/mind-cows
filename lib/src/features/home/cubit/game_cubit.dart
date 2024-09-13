import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'game_state.dart';
part 'game_cubit.freezed.dart';

@injectable
class GameCubit extends Cubit<GameState> {
  GameCubit() : super(const GameState());

  Future<void> searchForGame() async {
    emit(state.copyWith(status: GameStatus.searching));

    await Future.delayed(const Duration(seconds: 2), () {
      emit(state.copyWith(status: GameStatus.playing));
    });
  }

  void refresh() {
    emit(const GameState());
  }
}
