import 'dart:async';
import 'dart:developer';

import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/src/core/exceptions.dart';
import 'package:my_app/src/core/interceptor.dart';
import 'package:my_app/src/core/services/ranking_datasource.dart';
import 'package:my_app/src/core/supabase/query_supabase.dart';
import 'package:my_app/src/core/ui/extensions.dart';
import 'package:my_app/src/features/ranking/data/model/ranking.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@singleton
class RankingRepository extends RankingDatasource {
  RankingRepository(this._supabaseServiceImpl, this._client);

  final SupabaseServiceImpl _supabaseServiceImpl;
  final SupabaseClient _client;
  Timer? _debounceTimer;

  @override
  Future<Either<AppException?, List<Ranking>?>> getRanking() async {
    return _supabaseServiceImpl.query<List<Ranking>>(
      table: 'ranking',
      request: () => _client
          .from('ranking')
          .select(QuerySupabase.ranking)
          .order('position', ascending: true),
      queryOption: QueryOption.select,
      fromJsonParse: rankingsFromJson,
    );
  }

  @override
  void listenRanking(
    void Function() callback,
  ) {
    final myChannel = _client.channel('ranking_channel');
    log('Ranking Database Changes Listen On');

    myChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'ranking',
          callback: (payload) {
            log('Ranking Database change detected');

            // Si no hay debounce activo, ejecuta inmediatamente
            if (_debounceTimer == null || !_debounceTimer!.isActive) {
              callback(); // Ejecuta el callback inmediatamente
            }

            // Cancelar el temporizador anterior si existe
            _debounceTimer?.cancel();

            // Iniciar un nuevo temporizador de debounce
            _debounceTimer = Timer(5.seconds, () {
              log('5 segundos de inactividad, reiniciando debounce');
              // Aquí puedes realizar acciones adicionales si es necesario.
            });
          },
        )
        .subscribe();
  }
}
