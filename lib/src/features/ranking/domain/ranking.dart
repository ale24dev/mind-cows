import 'package:json_annotation/json_annotation.dart';
import 'package:my_app/src/core/supabase/table_interface.dart';
import 'package:my_app/src/features/player/domain/player.dart';

part 'ranking.g.dart';

@JsonSerializable(explicitToJson: true)
class Ranking with TableInterface {
  Ranking({
    required this.id,
    required this.gamesWon,
    required this.gamesLost,
    required this.minimumAttempts,
    required this.player,
  });

  factory Ranking.fromJson(Map<String, dynamic> json) => _$RankingFromJson(json);

  final int id;
  final int gamesWon;
  final int gamesLost;
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