abstract class GameUtils {
  static int calculateResultPoints({
    required bool wonCurrentGame,
    required int minimumAttempts,
  }) {
    var pointsForCurrentGame = 0;

    // If the player won the current game, they earn 3 points
    if (wonCurrentGame) {
      pointsForCurrentGame += 3;

      // Calculate additional points for minimum attempts, if applicable
      if (minimumAttempts > 0) {
        pointsForCurrentGame += 100 ~/ (minimumAttempts + 5);
      }
    } else {
      // If the player lost, subtract 3 points
      pointsForCurrentGame -= 3;
    }

    return pointsForCurrentGame;
  }
}
