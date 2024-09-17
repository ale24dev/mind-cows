import 'package:fpdart/fpdart.dart';
import 'package:my_app/src/core/exceptions.dart';
import 'package:my_app/src/features/player/data/model/player.dart';
import 'package:my_app/src/features/player/data/model/player_number.dart';

abstract class PlayerDatasource {
  Future<Either<AppException, Player?>> getPlayerById(String id);

  Future<Either<AppException?, PlayerNumber?>> createPlayerNumber(
    Player player,
    List<int> number,
  );

  Future<Either<AppException?, PlayerNumber?>> updatePlayerNumber(
    PlayerNumber playerNumber,
  );
}
