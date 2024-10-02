// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:developer';

import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/src/core/di/dependency_injection.dart';
import 'package:my_app/src/core/exceptions.dart';
import 'package:my_app/src/core/interceptor.dart';
import 'package:my_app/src/core/services/game_datasource.dart';
import 'package:my_app/src/core/supabase/query_supabase.dart';
import 'package:my_app/src/features/game/data/model/attempt.dart';
import 'package:my_app/src/features/game/data/model/game.dart';
import 'package:my_app/src/features/game/data/model/game_status.dart';
import 'package:my_app/src/features/player/data/model/player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

@singleton
class GameRepository extends GameDataSource {
  GameRepository(this._supabaseServiceImpl, this._client);

  final SupabaseServiceImpl _supabaseServiceImpl;
  final SupabaseClient _client;

  late RealtimeChannel _room;

  final gameStatus = GameStatus.empty();
  @override
  Future<Either<AppException?, Game?>> findOrCreateGame(Player player) {
    return _supabaseServiceImpl.query<Game>(
      table: 'RPC create_game',
      request: () =>
          _client.rpc('find_or_create_game', params: {'player_id': player.id}),
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
  Future<Either<AppException?, Game?>> getLastGame(Player player) {
    return _supabaseServiceImpl.query<Game>(
      table: 'RPC get_last_game',
      request: () =>
          _client.rpc('get_last_game', params: {'player_id': player.id}),
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

  @override
  Future<Either<AppException?, bool?>> cancelSearchGame(Player player) {
    return _supabaseServiceImpl.query<bool>(
      table: 'RPC cancel_search_game',
      request: () =>
          _client.rpc('cancel_search_game', params: {'player_id': player.id}),
      queryOption: QueryOption.insert,
    );
  }

  @override
  void listenPresence(Game game) {
    _room = _client.channel('room_${game.id}');
    _room.onPresenceJoin((payload) {
      print('join: $payload');
    }).onPresenceLeave((payload) {
      print('leave: $payload');
    }).subscribe((status, error) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        _room.track({'uid': getIt.get<Uuid>().v4()});
      }
      print('status: $status');
      print('error: $error');
    });
  }

  @override
  Future<void> registerPresence(Game game, Player player) async {
    // final status2 = await _room.track({'uid': player.id});
    // log('presence: ${'room_${game.id}'} : $status2');
  }

  @override
  void dispose() {
    log('DIIIIISSSPPOOOOOSE');
    _room.unsubscribe();
  }
}
