part of 'game_cubit.dart';

enum GameStatus { initial, searching, playing, paused, ended }

extension GameStatusX on GameStatus {
  bool get isInitial => this == GameStatus.initial;
  bool get isSearching => this == GameStatus.searching;
  bool get isPlaying => this == GameStatus.playing;
  bool get isPaused => this == GameStatus.paused;
  bool get isEnded => this == GameStatus.ended;
}

@freezed
class GameState with _$GameState {
  const factory GameState({
    @Default(GameStatus.initial) final GameStatus status,
  }) = _GameState;
}
