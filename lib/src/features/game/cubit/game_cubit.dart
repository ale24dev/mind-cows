import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/src/features/game/data/game_repository.dart';
import 'package:my_app/src/features/game/domain/game.dart';
import 'package:my_app/src/features/game/domain/game_status.dart';
import 'package:my_app/src/features/player/data/model/player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'game_state.dart';
part 'game_cubit.freezed.dart';

@injectable
class GameCubit extends Cubit<GameState> {
  GameCubit(
    this._client,
    this._gameRepository,
  ) : super(const GameState()) {
    log('Initializing GameCubit...');
    _listenGame();
  }

  final SupabaseClient _client;

  final GameRepository _gameRepository;

  void _listenGame() {
    final game = Game.empty();
    final myChannel = _client.channel('games_channel');

    myChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: game.tableName(),
          callback: (payload) {
            log('GameCubit: Database change detected');

            final newGameStatusId = payload.newRecord['status'] as int;

            _handleGameStatusChange(
              newGameStatusId,
              state.listGameStatus,
            );
          },
        )
        .subscribe();
  }

  Future<void> getCurrentGame(Player player) async {
    final result = await _gameRepository.getCurrentGame(player);

    final game = result.fold(
      (error) {
        emit(state.copyWith(status: GameStateStatus.error));
        return null;
      },
      (response) => response,
    );

    if (game == null) {
      return;
    }

    emit(state.copyWith(status: GameStateStatus.inProgress, game: game));
  }

  Future<void> findOrCreateGame(
    Player player,
  ) async {
    await _gameRepository.findOrCreateGame(player).then((value) {
      value.fold(
        (error) => emit(state.copyWith(status: GameStateStatus.error)),
        (game) {
          emit(state.copyWith(status: GameStateStatus.searching, game: game));
        },
      );
    });
  }

  void setGameStatus(List<GameStatus> listGameStatus) {
    emit(state.copyWith(listGameStatus: listGameStatus));
  }

  void refresh() {
    emit(const GameState());
  }

  GameStatus getGameStatusByStatus(
    List<GameStatus> listGameStatus,
    StatusEnum status,
  ) {
    return listGameStatus.firstWhere((element) => element.status == status);
  }

  void _handleGameStatusChange(
    int newGameStatusId,
    List<GameStatus> listGameStatus,
  ) {
    final gameStatus = listGameStatus.firstWhere(
      (element) => element.id == newGameStatusId,
    );
    switch (gameStatus.status) {
      case StatusEnum.searching:
        emit(
          state.copyWith(
            status: GameStateStatus.searching,
          ),
        );
      case StatusEnum.inProgress:
        emit(
          state.copyWith(
            status: GameStateStatus.inProgress,
          ),
        );
      case StatusEnum.finished:
        emit(
          state.copyWith(
            status: GameStateStatus.finished,
          ),
        );
    }
  }
}
