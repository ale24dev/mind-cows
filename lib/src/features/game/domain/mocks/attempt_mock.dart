import 'package:my_app/src/features/game/data/model/attempt.dart';
import 'package:my_app/src/features/game/data/model/game.dart';
import 'package:my_app/src/features/game/data/model/game_status.dart';
import 'package:my_app/src/features/player/data/model/player.dart';

List<Attempt> getAttemptsMock(int quantity) {
  return List.generate(quantity, (index) {
    return Attempt(
      id: 0,
      game: Game(id: 0, status: GameStatus.empty()),
      bulls: 0,
      cows: 0,
      number: [1, 2, 3, 4],
      player: Player.empty(),
    );
  });
}
