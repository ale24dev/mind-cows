import 'package:fpdart/fpdart.dart';
import 'package:my_app/src/core/exceptions.dart';
import 'package:my_app/src/features/ranking/data/model/ranking.dart';

abstract class RankingDatasource {
  Future<Either<AppException?, List<Ranking>?>> getRanking();

  void listenRanking(
    void Function() callback,
  );
}
