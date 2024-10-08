// ignore_for_file: void_checks

import 'dart:developer';

import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mind_cows/src/core/exceptions.dart';
import 'package:mind_cows/src/core/extensions/list.dart';
import 'package:mind_cows/src/core/interceptor.dart';
import 'package:mind_cows/src/core/services/player_datasource.dart';
import 'package:mind_cows/src/core/supabase/query_supabase.dart';
import 'package:mind_cows/src/features/player/data/model/player.dart';
import 'package:mind_cows/src/features/player/data/model/player_number.dart';
import 'package:mind_cows/src/features/player/domain/player_number_realtime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef PlayerNumberCallbackData = (
  bool isTurn,
  int timeLeft,
  DateTime? startedTime
);

@singleton
class PlayerRepository extends PlayerDatasource {
  PlayerRepository(this._supabaseServiceImpl, this._client);

  final SupabaseServiceImpl _supabaseServiceImpl;
  final SupabaseClient _client;

  @override
  void listenPlayerNumberChanges(
    String playerId,
    void Function(PlayerNumberRealtime) callback,
  ) {
    final myChannel = _client.channel('player_number_channel');
    log('Game Database Changes Listen On');

    myChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'player_number',
          callback: (payload) {
            log('PlayerCubit: Database change detected');

            if (playerId != payload.newRecord['player']) return;
            log(payload.toString());

            return callback(PlayerNumberRealtime.fromJson(payload.newRecord));
          },
        )
        .subscribe();
  }

  @override
  Future<Either<AppException, Player?>> getPlayerById(String id) async {
    /// Only to gets the columns and name of the table.
    final playerEmpty = Player.empty();
    return _supabaseServiceImpl.query<Player>(
      table: 'getPlayerById',
      request: () => _client
          .from('player')
          .select(playerEmpty.columns())
          .eq('id', id)
          .single(),
      queryOption: QueryOption.select,
      fromJsonParse: Player.fromJson,
    );
  }

  @override
  Future<Either<AppException?, PlayerNumber?>> createPlayerNumber(
    Player player,
    List<int> number,
  ) {
    final playerNumber =
        PlayerNumber.empty().copyWith(player: player, number: number);
    return _supabaseServiceImpl.query<PlayerNumber>(
      table: playerNumber.tableName(),
      request: () => _client
          .from(playerNumber.tableName())
          .insert(playerNumber.toJson())
          .select(playerNumber.columns())
          .single(),
      queryOption: QueryOption.insert,
      fromJsonParse: PlayerNumber.fromJson,
    );
  }

  @override
  Future<Either<AppException?, PlayerNumber?>> updatePlayerNumber(
    PlayerNumber playerNumber,
  ) {
    return _supabaseServiceImpl.query<PlayerNumber>(
      table: 'update_player_number',
      request: () => _client.rpc(
        'update_player_number',
        params: {
          'player_number_id': playerNumber.id,
          'new_number_text': playerNumber.number?.parseNumberListToString ?? '',
        },
      ),
      queryOption: QueryOption.update,
      responseNullable: true,
      fromJsonParse: PlayerNumber.fromJson,
    );
  }

  @override
  Future<Either<AppException?, Player?>> setProfileImage(
    Player player,
    String imageUrl,
  ) {
    return _supabaseServiceImpl.query<Player>(
      table: 'setProfileImage',
      request: () => _client
          .from('player')
          .update({'avatar_url': imageUrl})
          .eq('id', player.id)
          .select(QuerySupabase.player)
          .single(),
      queryOption: QueryOption.update,
      responseNullable: true,
      fromJsonParse: Player.fromJson,
    );
  }
}
