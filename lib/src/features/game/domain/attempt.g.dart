// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attempt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attempt _$AttemptFromJson(Map<String, dynamic> json) => Attempt(
      id: json['id'] as String,
      game: Game.fromJson(json['game'] as Map<String, dynamic>),
      bulls: (json['bulls'] as num).toInt(),
      cows: (json['cows'] as num).toInt(),
      number: json['number'] as String,
      player: Player.fromJson(json['player'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AttemptToJson(Attempt instance) => <String, dynamic>{
      'id': instance.id,
      'game': instance.game.toJson(),
      'bulls': instance.bulls,
      'cows': instance.cows,
      'number': instance.number,
      'player': instance.player.toJson(),
    };
