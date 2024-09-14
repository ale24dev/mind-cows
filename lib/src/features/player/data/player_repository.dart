import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/src/core/exceptions.dart';
import 'package:my_app/src/core/interceptor.dart';
import 'package:my_app/src/core/services/player_datasource.dart';
import 'package:my_app/src/features/player/data/model/player.dart';
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
}
