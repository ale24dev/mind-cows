part of 'game_cubit.dart';

enum GameStateStatus { intial, loading, success, error, cancel }

@freezed
class GameState with _$GameState {
  const factory GameState({
    final Game? game,
    @Default(GameStateStatus.intial) final GameStateStatus stateStatus,
    @Default([]) final List<GameStatus> listGameStatus,
    @Default([]) final List<Attempt> listAttempts,
    Player? player,
  }) = _GameState;
  const GameState._();

  bool get isLoading => stateStatus == GameStateStatus.loading;
  bool get isSuccess => stateStatus == GameStateStatus.success;
  bool get isError => stateStatus == GameStateStatus.error;
  bool get isCancel => stateStatus == GameStateStatus.cancel;


  bool get isGameSearching => game.isNotNull && game!.isSearching;
  bool get isGameInProgress => game.isNotNull && game!.isInProgress;
  bool get isGameFinished => game.isNotNull && game!.isFinished;
}