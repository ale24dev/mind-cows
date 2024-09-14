import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_app/src/core/supabase/table_interface.dart';
import 'package:my_app/src/features/game/domain/game.dart';
import 'package:my_app/src/features/player/domain/player.dart';

part 'attempt.g.dart';

@JsonSerializable(explicitToJson: true)
class Attempt with TableInterface {
  Attempt({
    required this.id,
    required this.game,
    required this.bulls,
    required this.cows,
    required this.number,
    required this.player,
  });

  factory Attempt.fromJson(Map<String, dynamic> json) =>
      _$AttemptFromJson(json);
  final String id;
  final Game game;
  final int bulls;
  final int cows;
  final String number;
  final Player player;

  Map<String, dynamic> toJson() => _$AttemptToJson(this);

  @override
  String columns() => 'id, game, bulls, cows, number, player';

  @override
  String tableName() => 'attempt';
}
