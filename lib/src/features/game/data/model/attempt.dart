import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_app/src/core/supabase/table_interface.dart';
import 'package:my_app/src/core/utils/object_extensions.dart';
import 'package:my_app/src/features/game/data/model/game.dart';
import 'package:my_app/src/features/player/data/model/player.dart';

part 'attempt.g.dart';

List<Attempt> attemptsFromJson(List<dynamic> str) =>
    str.map((x) => Attempt.fromJson(x as Json)).toList();

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
  final int id;
  final Game game;
  final int bulls;
  final int cows;
  final List<int> number;
  final Player player;

  Map<String, dynamic> toJson() => _$AttemptToJson(this);

  @override
  String columns() => 'id, game, bulls, cows, number, player';

  @override
  String tableName() => 'attempt';
}
