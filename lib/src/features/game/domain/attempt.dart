import 'package:my_app/src/core/supabase/table_interface.dart';
import 'package:my_app/src/features/game/domain/game.dart';
import 'package:my_app/src/features/player/domain/player.dart';

class Attempt extends TableInterface {
  Attempt({
    required this.id,
    required this.game,
    required this.bulls,
    required this.cows,
    required this.number,
    required this.player,
  });
  final int id;
  final Game game;
  final int bulls;
  final int cows;
  final List<int> number;
  final Player player;

  @override
  String columns() => '''
      id, game(${game.columns()}), bulls, cows, number, player(${player.columns()})
      ''';

  @override
  String tableName() => 'attempt';
}
