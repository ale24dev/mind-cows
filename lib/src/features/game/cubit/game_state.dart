part of 'game_cubit.dart';

enum GameStateStatus { initial, searching, inProgress, finished, error, cancel }

@freezed
class GameState with _$GameState {
  const factory GameState({
    final Game? game,
    @Default(GameStateStatus.initial) final GameStateStatus status,
    @Default([]) final List<GameStatus> listGameStatus,
  }) = _GameState;
  const GameState._();

  bool get isSearching => status == GameStateStatus.searching;
  bool get isInProgress => status == GameStateStatus.inProgress;
  bool get isFinished => status == GameStateStatus.finished;
  bool get isError => status == GameStateStatus.error;
  bool get isCancel => status == GameStateStatus.cancel;
}
