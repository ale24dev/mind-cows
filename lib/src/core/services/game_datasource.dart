import 'package:fpdart/fpdart.dart';
import 'package:my_app/src/core/exceptions.dart';
import 'package:my_app/src/features/game/data/model/attempt.dart';
import 'package:my_app/src/features/game/data/model/game.dart';
import 'package:my_app/src/features/game/data/model/game_status.dart';
import 'package:my_app/src/features/player/data/model/player.dart';

abstract class GameDataSource {
  Future<Either<AppException?, Game?>> findOrCreateGame(Player player);

  Future<Either<AppException?, List<GameStatus>?>> getAllGameStatus();

  Future<Either<AppException?, Game?>> getCurrentGame(Player player);

  Future<Either<AppException?, List<Attempt>?>> getAttemptsInGameByPlayer(
    Game game,
    Player player,
  );
}
