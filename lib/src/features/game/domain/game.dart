import 'package:json_annotation/json_annotation.dart';
import 'package:my_app/src/core/supabase/table_interface.dart';
import 'package:my_app/src/features/game/domain/game_status.dart';
import 'package:my_app/src/features/player/data/model/player.dart';
import 'package:my_app/src/features/player/data/model/player_number.dart';

part 'game.g.dart';

@JsonSerializable(explicitToJson: true)
class Game with TableInterface {

  Game({
    required this.id,
    required this.status,
    required this.playerNumber1,
    required this.playerNumber2,
    this.winner,
  });

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
  final int id;
  final GameStatus status;
  final PlayerNumber playerNumber1;
  final PlayerNumber playerNumber2;
  final Player? winner;

  Map<String, dynamic> toJson() => _$GameToJson(this);

  @override
  String columns() => '''
        id, status(${status.columns()}),
        player_number1(${playerNumber1.columns()}), player_number2(${playerNumber2.columns()}),
        winner(${winner?.columns()})
      ''';

  @override
  String tableName() => 'game';
}