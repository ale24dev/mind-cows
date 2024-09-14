// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/src/core/exceptions.dart';
import 'package:my_app/src/core/interceptor.dart';
import 'package:my_app/src/core/services/game_datasource.dart';
import 'package:my_app/src/core/supabase/query_supabase.dart';
import 'package:my_app/src/features/game/data/model/attempt.dart';
import 'package:my_app/src/features/game/data/model/game.dart';
import 'package:my_app/src/features/game/data/model/game_status.dart';
import 'package:my_app/src/features/player/data/model/player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@singleton
class GameRepository extends GameDataSource {
  GameRepository(this._supabaseServiceImpl, this._client);

  final SupabaseServiceImpl _supabaseServiceImpl;
  final SupabaseClient _client;

  final gameStatus = GameStatus.empty();
  @override
  Future<Either<AppException?, Game?>> findOrCreateGame(Player player) {
    return _supabaseServiceImpl.query<Game>(
      table: 'RPC create_game',
      request: () =>
          _client.rpc('create_game', params: {'player_id': player.id}),
      queryOption: QueryOption.insert,
      fromJsonParse: Game.fromJson,
    );
  }

  @override
  Future<Either<AppException?, List<GameStatus>?>> getAllGameStatus() {
    return _supabaseServiceImpl.query<List<GameStatus>>(
      table: gameStatus.tableName(),
      request: () =>
          _client.from(gameStatus.tableName()).select(gameStatus.columns()),
      queryOption: QueryOption.select,
      fromJsonParse: gameStatusFromJson,
    );
  }

  @override
  Future<Either<AppException?, Game?>> getCurrentGame(Player player) {
    return _supabaseServiceImpl.query<Game>(
      table: 'game',
      request: () =>
          _client.rpc('get_current_game', params: {'player_id': player.id}),
      queryOption: QueryOption.select,
      fromJsonParse: Game.fromJson,
      responseNullable: true,
    );
  }

  @override
  Future<Either<AppException?, List<Attempt>?>> getAttemptsInGameByPlayer(
    Game game,
    Player player,
  ) {
    return _supabaseServiceImpl.query<List<Attempt>>(
      table: 'attempt',
      request: () =>
          _client.from('attempt').select(QuerySupabase.attempt).match({
        'game': game.id,
        'player': player.id,
      }).order('id', ascending: false),
      queryOption: QueryOption.select,
      fromJsonParse: attemptsFromJson,
    );
  }

  @override
  Future<Either<AppException?, void>> insertAttempt(Attempt attempt) {
    return _supabaseServiceImpl.query<void>(
      table: 'attempt',
      request: () => _client.functions.invoke(
        'create-new-attempt',
        body: {
          'gameId': attempt.game.id,
          'playerId': attempt.player.id,
          'p_number': attempt.number,
        },
      ),
      queryOption: QueryOption.select,
      responseNullable: true,
    );
  }
}
