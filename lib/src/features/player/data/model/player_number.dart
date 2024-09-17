import 'package:json_annotation/json_annotation.dart';
import 'package:my_app/src/core/supabase/table_interface.dart';
import 'package:my_app/src/features/player/data/model/player.dart';

part 'player_number.g.dart';

@JsonSerializable(explicitToJson: true)
class PlayerNumber with TableInterface {
  PlayerNumber({
    required this.id,
    required this.player,
    this.number,
  });

  factory PlayerNumber.empty() => PlayerNumber(
        id: 0,
        player: Player.empty(),
        number: [],
      );

  factory PlayerNumber.fromJson(Map<String, dynamic> json) =>
      _$PlayerNumberFromJson(json);
  final int id;
  final Player player;
  final List<int>? number;

  @override
  String columns() => 'id, player(${player.columns()}), number';

  @override
  String tableName() => 'player_number';
}

extension PlayerNumberX on PlayerNumber {
  bool get haveNumber => number != null && number!.isNotEmpty;

  PlayerNumber copyWith({
    int? id,
    Player? player,
    List<int>? number,
  }) {
    return PlayerNumber(
      id: id ?? this.id,
      player: player ?? this.player,
      number: number ?? this.number,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'player': player.id,
      'number': number,
    };
  }
}
