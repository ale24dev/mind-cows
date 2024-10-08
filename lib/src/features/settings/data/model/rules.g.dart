// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rules.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RulesImpl _$$RulesImplFromJson(Map<String, dynamic> json) => _$RulesImpl(
      id: (json['id'] as num).toInt(),
      rules: json['rules'] as String,
      language: $enumDecode(_$LanguageEnumEnumMap, json['language']),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$RulesImplToJson(_$RulesImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rules': instance.rules,
      'language': _$LanguageEnumEnumMap[instance.language]!,
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$LanguageEnumEnumMap = {
  LanguageEnum.en: 'en',
  LanguageEnum.es: 'es',
};
