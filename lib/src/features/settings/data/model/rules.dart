import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_app/src/core/utils/object_extensions.dart';
import 'package:my_app/src/features/settings/cubit/settings_cubit.dart';

part 'rules.freezed.dart';
part 'rules.g.dart';

List<Rules> rulesFromJson(List<dynamic> str) =>
    str.map((x) => Rules.fromJson(x as Json)).toList();

@freezed
class Rules with _$Rules {
  const factory Rules({
    required int id,
    required String rules,
    required LanguageEnum language,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Rules;

  factory Rules.fromJson(Map<String, dynamic> json) => _$RulesFromJson(json);
}

enum LanguageEnum {
  @JsonValue('en')
  en,
  @JsonValue('es')
  es,
}
