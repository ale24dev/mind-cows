import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mind_cows/src/core/supabase/table_interface.dart';

part 'player.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Player extends Equatable with TableInterface {
  Player({
    required this.id,
    required this.username,
    required this.avatarUrl,
  });

  factory Player.empty() => Player(id: '', username: '', avatarUrl: '');

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  final String id;
  final String username;
  final String avatarUrl;

  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  @override
  String tableName() => 'players';

  @override
  String columns() => 'id, username, avatar_url';

  @override
  // TODO: implement props
  List<Object?> get props => [id, username, avatarUrl];
}
