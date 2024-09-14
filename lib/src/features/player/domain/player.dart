import 'package:json_annotation/json_annotation.dart';
import 'package:my_app/src/core/supabase/table_interface.dart';

part 'player.g.dart';

@JsonSerializable(explicitToJson: true)
class Player with TableInterface {

  Player({
    required this.id,
    required this.username,
    required this.avatarUrl,
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  final String id;
  final String username;
  final String avatarUrl;

  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  @override
  String tableName() => 'players';

  @override
  String columns() => 'id, username, avatar_url';
}