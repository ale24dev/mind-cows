import 'package:my_app/src/core/supabase/table_interface.dart';

class Player extends TableInterface {
  Player({
    required this.id,
    required this.username,
    required this.avatarUrl,
  });
  final String id;
  final String username;
  final String avatarUrl;

  @override
  String tableName() => 'players';

  @override
  String columns() => 'id, username, avatar_url';
}
