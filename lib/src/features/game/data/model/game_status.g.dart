// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameStatus _$GameStatusFromJson(Map<String, dynamic> json) => GameStatus(
      id: (json['id'] as num).toInt(),
      status: $enumDecode(_$StatusEnumEnumMap, json['status']),
    );

Map<String, dynamic> _$GameStatusToJson(GameStatus instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$StatusEnumEnumMap[instance.status]!,
    };

const _$StatusEnumEnumMap = {
  StatusEnum.searching: 'searching',
  StatusEnum.inProgress: 'in_progress',
  StatusEnum.finished: 'finished',
  StatusEnum.selectingSecretNumbers: 'selecting_secret_numbers',
};
