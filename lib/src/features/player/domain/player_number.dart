import 'package:my_app/src/core/supabase/table_interface.dart';
import 'package:my_app/src/features/player/domain/player.dart';

class PlayerNumber extends TableInterface {
  PlayerNumber({
    required this.id,
    required this.player,
    required this.number,
  });
  final int id;
  final Player player;
  final List<int> number;

  @override
  String columns() => 'id, player(${player.columns()}), number';

  @override
  String tableName() => 'player_number';
}
