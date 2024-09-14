import 'package:json_annotation/json_annotation.dart';
import 'package:my_app/src/core/supabase/table_interface.dart';
import 'package:my_app/src/features/player/domain/player.dart';

part 'player_number.g.dart';

@JsonSerializable(explicitToJson: true)
class PlayerNumber with TableInterface {

  PlayerNumber({
    required this.id,
    required this.player,
    required this.number,
  });

  factory PlayerNumber.fromJson(Map<String, dynamic> json) =>
      _$PlayerNumberFromJson(json);
  final int id;
  final Player player;
  final List<int> number;

  Map<String, dynamic> toJson() => _$PlayerNumberToJson(this);

  @override
  String columns() => 'id, player(${player.columns()}), number';

  @override
  String tableName() => 'player_number';
}