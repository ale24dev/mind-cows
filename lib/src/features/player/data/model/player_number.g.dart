// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_number.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerNumber _$PlayerNumberFromJson(Map<String, dynamic> json) => PlayerNumber(
      id: (json['id'] as num).toInt(),
      player: Player.fromJson(json['player'] as Map<String, dynamic>),
      isTurn: json['is_turn'] as bool,
      timeLeft: (json['time_left'] as num).toInt(),
      startedTime: json['started_time'] == null
          ? null
          : DateTime.parse(json['started_time'] as String),
      finishTime: json['finish_time'] == null
          ? null
          : DateTime.parse(json['finish_time'] as String),
      number: (json['number'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$PlayerNumberToJson(PlayerNumber instance) =>
    <String, dynamic>{
      'id': instance.id,
      'player': instance.player.toJson(),
      'is_turn': instance.isTurn,
      'time_left': instance.timeLeft,
      'started_time': instance.startedTime?.toIso8601String(),
      'finish_time': instance.finishTime?.toIso8601String(),
      'number': instance.number,
    };
