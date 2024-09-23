// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ranking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ranking _$RankingFromJson(Map<String, dynamic> json) => Ranking(
      id: (json['id'] as num).toInt(),
      position: (json['position'] as num).toInt(),
      points: (json['points'] as num).toInt(),
      gamesWon: (json['games_won'] as num).toInt(),
      gamesLoss: (json['games_loss'] as num).toInt(),
      minimumAttempts: (json['minimum_attempts'] as num).toInt(),
      player: Player.fromJson(json['player'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RankingToJson(Ranking instance) => <String, dynamic>{
      'id': instance.id,
      'position': instance.position,
      'points': instance.points,
      'games_won': instance.gamesWon,
      'games_loss': instance.gamesLoss,
      'minimum_attempts': instance.minimumAttempts,
      'player': instance.player.toJson(),
    };
