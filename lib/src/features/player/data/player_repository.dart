import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/src/core/exceptions.dart';
import 'package:my_app/src/core/extensions/list.dart';
import 'package:my_app/src/core/interceptor.dart';
import 'package:my_app/src/core/services/player_datasource.dart';
import 'package:my_app/src/features/player/data/model/player.dart';
import 'package:my_app/src/features/player/data/model/player_number.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@singleton
class PlayerRepository extends PlayerDatasource {
  PlayerRepository(this._supabaseServiceImpl, this._client);

  final SupabaseServiceImpl _supabaseServiceImpl;
  final SupabaseClient _client;

  @override
  Future<Either<AppException, Player?>> getPlayerById(String id) async {
    /// Only to gets the columns and name of the table.
    final playerEmpty = Player.empty();
    return _supabaseServiceImpl.query<Player>(
      table: playerEmpty.tableName(),
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
      table: playerNumber.tableName(),
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
}
