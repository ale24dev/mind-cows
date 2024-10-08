import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mind_cows/l10n/l10n.dart';
import 'package:mind_cows/src/core/supabase/table_interface.dart';
import 'package:mind_cows/src/core/utils/object_extensions.dart';
import 'package:mind_cows/src/features/auth/views/auth_screen.dart';
import 'package:mind_cows/src/features/game/data/model/game.dart';
import 'package:mind_cows/src/features/player/data/model/player.dart';

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

  factory Attempt.empty() => Attempt(
        id: 0,
        game: Game.empty(),
        bulls: 0,
        cows: 0,
        number: [],
        player: Player.empty(),
      );

  factory Attempt.fromJson(Map<String, dynamic> json) =>
      _$AttemptFromJson(json);
  final int id;
  final Game game;
  final int bulls;
  final int cows;
  final List<int> number;
  final Player player;

  @override
  String columns() => 'id, game, bulls, cows, number, player';

  @override
  String tableName() => 'attempt';
}

extension AttemptX on Attempt {
  String attemptResult(BuildContext context, {int? cows, int? bulls}) {
    return '${context.l10n.cowPlay}${cows ?? this.cows}  ${context.l10n.bullPlay}${bulls ?? this.bulls}';
  }

  Attempt copyWith({
    int? id,
    Game? game,
    int? bulls,
    int? cows,
    List<int>? number,
    Player? player,
  }) =>
      Attempt(
        id: id ?? this.id,
        game: game ?? this.game,
        bulls: bulls ?? this.bulls,
        cows: cows ?? this.cows,
        number: number ?? this.number,
        player: player ?? this.player,
      );

  Map<String, dynamic> toJson() => {
        'game': game.id,
        'player': player.id,
        'number': number,
      };
}
