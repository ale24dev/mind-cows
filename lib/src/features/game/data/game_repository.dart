// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:developer';

import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/src/core/exceptions.dart';
import 'package:my_app/src/core/interceptor.dart';
import 'package:my_app/src/core/services/game_datasource.dart';
import 'package:my_app/src/core/supabase/query_supabase.dart';
import 'package:my_app/src/features/game/domain/game.dart';
import 'package:my_app/src/features/game/domain/game_status.dart';
import 'package:my_app/src/features/player/data/model/player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@singleton
class GameRepository extends GameDataSource {
  GameRepository(this._supabaseServiceImpl, this._client);

  final SupabaseServiceImpl _supabaseServiceImpl;
  final SupabaseClient _client;

  final gameStatus = GameStatus.empty();
  @override
  Future<Either<AppException?, Game?>> createGameRoom(Game game) {
    log(game.toJson().toString());
    log(game.columns());
    return _supabaseServiceImpl.query<Game>(
      table: game.tableName(),
      request: () => _client
          .from(game.tableName())
          .insert(game.toJson())
          .select(QuerySupabase.game)
          .single(),
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
    );
  }
}
