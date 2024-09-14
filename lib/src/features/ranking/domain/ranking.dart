import 'package:my_app/src/core/supabase/table_interface.dart';
import 'package:my_app/src/features/player/domain/player.dart';

class Ranking extends TableInterface {
  Ranking({
    required this.id,
    required this.gamesWon,
    required this.gamesLost,
    required this.minimumAttempts,
    required this.player,
  });
  final int id;
  final int gamesWon;
  final int gamesLost;
  final int minimumAttempts;
  final Player player;

  @override
  String columns() => '''
      id, games_won, games_lost, minimum_attempts, player(${player.columns()})
      ''';

  @override
  String tableName() => 'ranking';
}
