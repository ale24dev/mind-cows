// ignore_for_file: avoid_bool_literals_in_conditional_expressions

import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/src/core/ui/extensions.dart';
import 'package:my_app/src/core/utils/object_extensions.dart';
import 'package:my_app/src/features/game/data/game_repository.dart';
import 'package:my_app/src/features/game/data/model/attempt.dart';
import 'package:my_app/src/features/game/data/model/game.dart';
import 'package:my_app/src/features/game/data/model/game_status.dart';
import 'package:my_app/src/features/player/data/model/player.dart';
import 'package:my_app/src/features/player/data/model/player_number.dart';
import 'package:my_app/src/features/player/data/player_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'game_state.dart';
part 'game_cubit.freezed.dart';

@injectable
class GameCubit extends Cubit<GameState> {
  GameCubit(
    this._client,
    this._gameRepository,
    this._playerRepository,
  ) : super(const GameState()) {
    _listenGame();
  }

  final SupabaseClient _client;

  final GameRepository _gameRepository;
  final PlayerRepository _playerRepository;

  void _listenPlayerNumberChanges() {
    _playerRepository.listenPlayerNumberChanges(state.player!.id,
        (callbackData) {
      final (isTurn, timeLeft) = callbackData;
      final ownPlayerNumber = state.game!
          .getOwnPlayerNumber(state.player!)
          .copyWith(isTurn: isTurn, timeLeft: timeLeft);

      final game = state.game!.copyWith(
        playerNumber1: state.game!.playerNumber1!.id == ownPlayerNumber.id
            ? ownPlayerNumber
            : state.game!.playerNumber1,
        playerNumber2: state.game!.playerNumber2!.id == ownPlayerNumber.id
            ? ownPlayerNumber
            : state.game!.playerNumber2,
      );
      emit(state.copyWith(game: game));
    });
  }

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

            if (state.game.isNull) return;

            try {
              final playerNumber1 = decodePlayerNumber(
                payload.newRecord['player_number1'] as int?,
              );
              final playerNumber2 = decodePlayerNumber(
                payload.newRecord['player_number2'] as int?,
              );

              if (checkIfPlayerIsInGame(playerNumber1, playerNumber2)) {
                getLastGame();
              }
            } catch (e) {
              log('Error decoding player numbers: $e');
            }
          },
        )
        .subscribe();
  }

  int? decodePlayerNumber(int? playerNumber) {
    return playerNumber;
  }

  Future<void> getLastGame() async {
    emit(state.copyWith(stateStatus: GameStateStatus.loading));
    final result = await _gameRepository.getLastGame(state.player!);

    final game = result.fold(
      (error) {
        emit(state.copyWith(stateStatus: GameStateStatus.error));
        return null;
      },
      (response) => response,
    );

    if (state.isError) {
      emit(state.copyWith(stateStatus: GameStateStatus.error));
      return;
    }

    if (game.isNull) {
      emit(
        state.copyWith(stateStatus: GameStateStatus.success),
      );
      return;
    }

    emit(state.copyWith(stateStatus: GameStateStatus.success, game: game));

    await Future.delayed(Duration.zero, () {
      if (game!.isInProgress) {
        getAttemptsInGameByPlayer(game, state.player!);
      }
    });
  }

  Future<void> findOrCreateGame() async {
    if (!state.isGameFinished) return;
    emit(
      state.copyWith(
        stateStatus: GameStateStatus.searchingGame,
        player: state.player,
      ),
    );
    await _gameRepository.findOrCreateGame(state.player!).then((value) {
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

  Future<bool> cancelSearchGame(Player player) async {
    emit(state.copyWith(stateStatus: GameStateStatus.loading));
    final result = await _gameRepository.cancelSearchGame(player);

    final success = result.fold(
      (error) {
        emit(state.copyWith(stateStatus: GameStateStatus.error));
        return false;
      },
      (response) => response,
    );

    if (state.isError) {
      emit(state.copyWith(stateStatus: GameStateStatus.error));
      return false;
    }

    emit(
      state.copyWith(
        stateStatus: GameStateStatus.cancel,
      ),
    );

    await Future.delayed(1.seconds, refresh);
    return success!;
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

  void selectSecretNumberShowed(bool showed) {
    emit(state.copyWith(selectSecretNumberShowed: showed));
  }

  void setGameStatus(List<GameStatus> listGameStatus) {
    emit(state.copyWith(listGameStatus: listGameStatus));
  }

  Future<void> setUserPlayer(Player player) async {
    emit(state.copyWith(player: player));

    _listenPlayerNumberChanges();
  }

  GameStatus getGameStatusById(
    List<GameStatus> listGameStatus,
    int status,
  ) {
    return listGameStatus.firstWhere((element) => element.id == status);
  }

  bool checkIfPlayerIsInGame(
    int? playerNumber1,
    int? playerNumber2,
  ) {
    return playerNumber1 == state.game!.playerNumber1?.id ||
        playerNumber2 == state.game!.playerNumber2?.id;
  }

  void refresh() {
    emit(
      const GameState().copyWith(
        player: state.player,
        listGameStatus: state.listGameStatus,
        game: null,
      ),
    );
  }

  void dispose() {
    emit(const GameState());
  }
}
