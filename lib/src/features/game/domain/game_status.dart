import 'package:my_app/src/core/supabase/table_interface.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game_status.g.dart';

@JsonSerializable(explicitToJson: true)
class GameStatus with TableInterface {
  GameStatus({
    required this.id,
    required this.status,
  });

  factory GameStatus.fromJson(Map<String, dynamic> json) =>
      _$GameStatusFromJson(json);
  final int id;
  final String status;

  Map<String, dynamic> toJson() => _$GameStatusToJson(this);

  @override
  String columns() => 'id, status';

  @override
  String tableName() => 'game_status';
}
