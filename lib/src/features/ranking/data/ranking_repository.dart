import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/src/core/exceptions.dart';
import 'package:my_app/src/core/interceptor.dart';
import 'package:my_app/src/core/services/ranking_datasource.dart';
import 'package:my_app/src/core/supabase/query_supabase.dart';
import 'package:my_app/src/features/ranking/data/model/ranking.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@singleton
class RankingRepository extends RankingDatasource {
  RankingRepository(this._supabaseServiceImpl, this._client);

  final SupabaseServiceImpl _supabaseServiceImpl;
  final SupabaseClient _client;
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
}
