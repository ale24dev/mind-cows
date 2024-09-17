import 'package:my_app/src/core/supabase/table_interface.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:my_app/src/core/utils/object_extensions.dart';

part 'game_status.g.dart';

List<GameStatus> gameStatusFromJson(List<dynamic> str) =>
    str.map((x) => GameStatus.fromJson(x as Json)).toList();

@JsonSerializable(explicitToJson: true)
class GameStatus with TableInterface {
  GameStatus({
    required this.id,
    required this.status,
  });

  factory GameStatus.empty() => GameStatus(
        id: 0,
        status: StatusEnum.searching,
      );

  factory GameStatus.fromJson(Map<String, dynamic> json) =>
      _$GameStatusFromJson(json);
  final int id;
  final StatusEnum status;

  Map<String, dynamic> toJson() => _$GameStatusToJson(this);

  @override
  String columns() => 'id, status';

  @override
  String tableName() => 'game_status';
}

enum StatusEnum {
  @JsonValue('searching')
  searching,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('finished')
  finished,
  @JsonValue('selecting_secret_numbers')
  selectingSecretNumbers,
}
