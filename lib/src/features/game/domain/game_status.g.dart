// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameStatus _$GameStatusFromJson(Map<String, dynamic> json) => GameStatus(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$GameStatusToJson(GameStatus instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
    };
