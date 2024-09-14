import 'package:my_app/src/core/supabase/table_interface.dart';

class GameStatus extends TableInterface {
  GameStatus({
    required this.id,
    required this.status,
  });

  final int id;
  final String status;

  @override
  String columns() => 'id, status';

  @override
  String tableName() => 'game_status';
}
