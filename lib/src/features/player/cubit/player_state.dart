part of 'player_cubit.dart';

enum PlayerStatus { initial, loading, success, error }

@freezed
class PlayerState with _$PlayerState {
  const factory PlayerState({
    final Player? player,
    @Default(PlayerStatus.initial) final PlayerStatus status,
  }) = _PlayerState;
  const PlayerState._();

  bool get isLoading => status == PlayerStatus.loading;
  bool get isSuccess => status == PlayerStatus.success;
  bool get isError => status == PlayerStatus.error;
}
