// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rules.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Rules _$RulesFromJson(Map<String, dynamic> json) {
  return _Rules.fromJson(json);
}

/// @nodoc
mixin _$Rules {
  int get id => throw _privateConstructorUsedError;
  String get rules => throw _privateConstructorUsedError;
  LanguageEnum get language => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RulesCopyWith<Rules> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RulesCopyWith<$Res> {
  factory $RulesCopyWith(Rules value, $Res Function(Rules) then) =
      _$RulesCopyWithImpl<$Res, Rules>;
  @useResult
  $Res call(
      {int id,
      String rules,
      LanguageEnum language,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$RulesCopyWithImpl<$Res, $Val extends Rules>
    implements $RulesCopyWith<$Res> {
  _$RulesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rules = null,
    Object? language = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      rules: null == rules
          ? _value.rules
          : rules // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as LanguageEnum,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RulesImplCopyWith<$Res> implements $RulesCopyWith<$Res> {
  factory _$$RulesImplCopyWith(
          _$RulesImpl value, $Res Function(_$RulesImpl) then) =
      __$$RulesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String rules,
      LanguageEnum language,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$RulesImplCopyWithImpl<$Res>
    extends _$RulesCopyWithImpl<$Res, _$RulesImpl>
    implements _$$RulesImplCopyWith<$Res> {
  __$$RulesImplCopyWithImpl(
      _$RulesImpl _value, $Res Function(_$RulesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rules = null,
    Object? language = null,
    Object? updatedAt = null,
  }) {
    return _then(_$RulesImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      rules: null == rules
          ? _value.rules
          : rules // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as LanguageEnum,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RulesImpl implements _Rules {
  const _$RulesImpl(
      {required this.id,
      required this.rules,
      required this.language,
      @JsonKey(name: 'updated_at') required this.updatedAt});

  factory _$RulesImpl.fromJson(Map<String, dynamic> json) =>
      _$$RulesImplFromJson(json);

  @override
  final int id;
  @override
  final String rules;
  @override
  final LanguageEnum language;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Rules(id: $id, rules: $rules, language: $language, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RulesImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rules, rules) || other.rules == rules) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, rules, language, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RulesImplCopyWith<_$RulesImpl> get copyWith =>
      __$$RulesImplCopyWithImpl<_$RulesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RulesImplToJson(
      this,
    );
  }
}

abstract class _Rules implements Rules {
  const factory _Rules(
          {required final int id,
          required final String rules,
          required final LanguageEnum language,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt}) =
      _$RulesImpl;

  factory _Rules.fromJson(Map<String, dynamic> json) = _$RulesImpl.fromJson;

  @override
  int get id;
  @override
  String get rules;
  @override
  LanguageEnum get language;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$RulesImplCopyWith<_$RulesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
