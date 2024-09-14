import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/src/core/utils/object_extensions.dart';
import 'package:my_app/src/features/game/data/game_repository.dart';
import 'package:my_app/src/features/game/data/model/attempt.dart';
import 'package:my_app/src/features/game/data/model/game.dart';
import 'package:my_app/src/features/game/data/model/game_status.dart';
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

            getCurrentGame();
          },
        )
        .subscribe();
  }

  Future<void> getCurrentGame() async {
    emit(state.copyWith(stateStatus: GameStateStatus.loading));
    final result = await _gameRepository.getCurrentGame(state.player!);

    final game = result.fold(
      (error) {
        emit(state.copyWith(stateStatus: GameStateStatus.error));
        return null;
      },
      (response) => response,
    );

    if (game == null) {
      return;
    }

    emit(state.copyWith(stateStatus: GameStateStatus.success, game: game));

    await Future.delayed(Duration.zero, () {
      if (game.isInProgress) {
        getAttemptsInGameByPlayer(game, state.player!);
      }
    });
  }

  Future<void> findOrCreateGame(
    Player player,
  ) async {
    emit(state.copyWith(stateStatus: GameStateStatus.loading));
    await _gameRepository.findOrCreateGame(player).then((value) {
      value.fold(
        (error) => emit(state.copyWith(stateStatus: GameStateStatus.error)),
        (game) {
          emit(
            state.copyWith(stateStatus: GameStateStatus.success, game: game),
          );
        },
      );
    });
  }

  Future<void> getAttemptsInGameByPlayer(Game game, Player player) async {
    emit(state.copyWith(stateStatus: GameStateStatus.loading));
    await _gameRepository.getAttemptsInGameByPlayer(game, player).then((value) {
      value.fold(
        (error) => emit(state.copyWith(stateStatus: GameStateStatus.error)),
        (attempts) {
          emit(
            state.copyWith(
              stateStatus: GameStateStatus.success,
              listAttempts: attempts ?? [],
            ),
          );
        },
      );
    });
  }

  Future<void> insertAttempt(Attempt attempt) async {
    emit(state.copyWith(stateStatus: GameStateStatus.loading));
    await _gameRepository
        .insertAttempt(attempt.copyWith(player: state.player, game: state.game))
        .then((value) {
      value.fold(
        (error) => emit(state.copyWith(stateStatus: GameStateStatus.error)),
        (gameStatus) {
          emit(
            state.copyWith(stateStatus: GameStateStatus.success),
          );
        },
      );
    });
    await getAttemptsInGameByPlayer(state.game!, state.player!);
  }

  void setGameStatus(List<GameStatus> listGameStatus) {
    emit(state.copyWith(listGameStatus: listGameStatus));
  }

  void setUserPlayer(Player player) {
    emit(state.copyWith(player: player));
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
}
