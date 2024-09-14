import 'package:fpdart/fpdart.dart';
import 'package:my_app/src/core/exceptions.dart';
import 'package:my_app/src/features/game/domain/game.dart';
import 'package:my_app/src/features/game/domain/game_status.dart';
import 'package:my_app/src/features/player/data/model/player.dart';

abstract class GameDataSource {
  Future<Either<AppException?, Game?>> createGameRoom(Game game);

  Future<Either<AppException?, List<GameStatus>?>> getAllGameStatus();

  Future<Either<AppException?, Game?>> getCurrentGame(Player player);
}
