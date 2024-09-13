import 'package:my_app/src/core/supabase/table_interface.dart';
import 'package:my_app/src/features/game/domain/game_status.dart';
import 'package:my_app/src/features/player/domain/player.dart';
import 'package:my_app/src/features/player/domain/player_number.dart';

class Game extends TableInterface {
  Game({
    required this.id,
    required this.status,
    required this.playerNumber1,
    required this.playerNumber2,
    this.winner,
  });
  final int id;
  final GameStatus status;
  final PlayerNumber playerNumber1;
  final PlayerNumber playerNumber2;
  final Player? winner;

  @override
  String columns() => '''
        id, status(${status.columns()}),
        player_number1(${playerNumber1.columns()}), player_number2(${playerNumber2.columns()}),
        winner(${winner?.columns()})
      ''';

  @override
  String tableName() => 'game';
}
