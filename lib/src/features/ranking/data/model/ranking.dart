import 'package:json_annotation/json_annotation.dart';
import 'package:mind_cows/src/core/supabase/table_interface.dart';
import 'package:mind_cows/src/core/utils/object_extensions.dart';
import 'package:mind_cows/src/features/player/data/model/player.dart';

part 'ranking.g.dart';

List<Ranking> rankingsFromJson(List<dynamic> str) =>
    str.map((x) => Ranking.fromJson(x as Json)).toList();

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Ranking with TableInterface {
  Ranking({
    required this.id,
    required this.position,
    required this.points,
    required this.gamesWon,
    required this.gamesLoss,
    required this.minimumAttempts,
    required this.player,
  });

  factory Ranking.fromJson(Map<String, dynamic> json) =>
      _$RankingFromJson(json);

  final int id;
  final int position;
  final int points;
  final int gamesWon;
  final int gamesLoss;
  final int minimumAttempts;
  final Player player;

  Map<String, dynamic> toJson() => _$RankingToJson(this);

  @override
  String columns() => '''
      id, games_won, games_lost, minimum_attempts, player(${player.columns()})
      ''';

  @override
  String tableName() => 'ranking';
}
