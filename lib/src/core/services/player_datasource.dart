import 'package:fpdart/fpdart.dart';
import 'package:mind_cows/src/core/exceptions.dart';
import 'package:mind_cows/src/features/player/data/model/player.dart';
import 'package:mind_cows/src/features/player/data/model/player_number.dart';
import 'package:mind_cows/src/features/player/domain/player_number_realtime.dart';

abstract class PlayerDatasource {
  Future<Either<AppException, Player?>> getPlayerById(String id);

  Future<Either<AppException?, PlayerNumber?>> createPlayerNumber(
    Player player,
    List<int> number,
  );

  Future<Either<AppException?, PlayerNumber?>> updatePlayerNumber(
    PlayerNumber playerNumber,
  );

  void listenPlayerNumberChanges(
    String playerId,
    void Function(PlayerNumberRealtime) callback,
  );

  Future<Either<AppException?, Player?>> setProfileImage(
    Player player,
    String imageUrl,
  );
}
