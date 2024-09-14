// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ranking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ranking _$RankingFromJson(Map<String, dynamic> json) => Ranking(
      id: (json['id'] as num).toInt(),
      gamesWon: (json['gamesWon'] as num).toInt(),
      gamesLost: (json['gamesLost'] as num).toInt(),
      minimumAttempts: (json['minimumAttempts'] as num).toInt(),
      player: Player.fromJson(json['player'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RankingToJson(Ranking instance) => <String, dynamic>{
      'id': instance.id,
      'gamesWon': instance.gamesWon,
      'gamesLost': instance.gamesLost,
      'minimumAttempts': instance.minimumAttempts,
      'player': instance.player.toJson(),
    };
