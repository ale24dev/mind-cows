import 'package:fpdart/fpdart.dart';
import 'package:mind_cows/src/core/exceptions.dart';
import 'package:mind_cows/src/features/ranking/data/model/ranking.dart';

abstract class RankingDatasource {
  Future<Either<AppException?, List<Ranking>?>> getRanking();

  void listenRanking(
    void Function() callback,
  );
}
