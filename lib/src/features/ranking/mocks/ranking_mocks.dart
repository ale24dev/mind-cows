import 'package:mind_cows/src/features/player/data/model/player.dart';
import 'package:mind_cows/src/features/ranking/data/model/ranking.dart';

final rankingMock = List.generate(20, (index) {
  return Ranking(
    id: index,
    gamesLoss: index,
    gamesWon: index,
    minimumAttempts: index,
    position: index,
    player: Player(
      id: index.toString(),
      username: 'Player $index',
      avatarUrl: 'https://example.com/avatar$index.png',
    ),
    points: 80,
  );
});
