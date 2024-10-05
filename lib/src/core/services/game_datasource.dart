import 'package:fpdart/fpdart.dart';
import 'package:my_app/src/core/exceptions.dart';
import 'package:my_app/src/features/game/data/game_repository.dart';
import 'package:my_app/src/features/game/data/model/attempt.dart';
import 'package:my_app/src/features/game/data/model/game.dart';
import 'package:my_app/src/features/game/data/model/game_status.dart';
import 'package:my_app/src/features/player/data/model/player.dart';

abstract class GameDataSource {
  Future<Either<AppException?, Game?>> findOrCreateGame(Player player);

  Future<Either<AppException?, bool?>> cancelSearchGame(Player player);

  Future<Either<AppException?, List<GameStatus>?>> getAllGameStatus();

  Future<Either<AppException?, Game?>> getLastGame(Player player);

  Future<Either<AppException?, List<Attempt>?>> getAttemptsInGameByPlayer(
    Game game,
    Player player,
  );

  Future<Either<AppException?, void>> insertAttempt(Attempt attempt);

  Future<Either<AppException?, DateTime?>> getServerTime();

  Future<Either<AppException?, void>> surrenderGame(
    Game game,
    Player player,
  );

  void listenAttempts(
    Game game,
    Player player,
    void Function(AttemptCallbackData) callback,
  );
}
