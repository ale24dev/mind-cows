// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) => Game(
      id: (json['id'] as num).toInt(),
      status: GameStatus.fromJson(json['status'] as Map<String, dynamic>),
      playerNumber1: json['playerNumber1'] == null
          ? null
          : PlayerNumber.fromJson(
              json['playerNumber1'] as Map<String, dynamic>),
      playerNumber2: json['playerNumber2'] == null
          ? null
          : PlayerNumber.fromJson(
              json['playerNumber2'] as Map<String, dynamic>),
      winner: json['winner'] == null
          ? null
          : Player.fromJson(json['winner'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
      'id': instance.id,
      'status': instance.status.toJson(),
      'playerNumber1': instance.playerNumber1?.toJson(),
      'playerNumber2': instance.playerNumber2?.toJson(),
      'winner': instance.winner?.toJson(),
    };
