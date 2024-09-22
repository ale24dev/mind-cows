// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ranking_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RankingState {
  List<Ranking> get ranking => throw _privateConstructorUsedError;
  RankingStateStatus get status => throw _privateConstructorUsedError;

  /// Create a copy of RankingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RankingStateCopyWith<RankingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RankingStateCopyWith<$Res> {
  factory $RankingStateCopyWith(
          RankingState value, $Res Function(RankingState) then) =
      _$RankingStateCopyWithImpl<$Res, RankingState>;
  @useResult
  $Res call({List<Ranking> ranking, RankingStateStatus status});
}

/// @nodoc
class _$RankingStateCopyWithImpl<$Res, $Val extends RankingState>
    implements $RankingStateCopyWith<$Res> {
  _$RankingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RankingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ranking = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      ranking: null == ranking
          ? _value.ranking
          : ranking // ignore: cast_nullable_to_non_nullable
              as List<Ranking>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RankingStateStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RankingStateImplCopyWith<$Res>
    implements $RankingStateCopyWith<$Res> {
  factory _$$RankingStateImplCopyWith(
          _$RankingStateImpl value, $Res Function(_$RankingStateImpl) then) =
      __$$RankingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Ranking> ranking, RankingStateStatus status});
}

/// @nodoc
class __$$RankingStateImplCopyWithImpl<$Res>
    extends _$RankingStateCopyWithImpl<$Res, _$RankingStateImpl>
    implements _$$RankingStateImplCopyWith<$Res> {
  __$$RankingStateImplCopyWithImpl(
      _$RankingStateImpl _value, $Res Function(_$RankingStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of RankingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ranking = null,
    Object? status = null,
  }) {
    return _then(_$RankingStateImpl(
      ranking: null == ranking
          ? _value._ranking
          : ranking // ignore: cast_nullable_to_non_nullable
              as List<Ranking>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RankingStateStatus,
    ));
  }
}

/// @nodoc

class _$RankingStateImpl extends _RankingState {
  const _$RankingStateImpl(
      {final List<Ranking> ranking = const [],
      this.status = RankingStateStatus.initial})
      : _ranking = ranking,
        super._();

  final List<Ranking> _ranking;
  @override
  @JsonKey()
  List<Ranking> get ranking {
    if (_ranking is EqualUnmodifiableListView) return _ranking;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ranking);
  }

  @override
  @JsonKey()
  final RankingStateStatus status;

  @override
  String toString() {
    return 'RankingState(ranking: $ranking, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RankingStateImpl &&
            const DeepCollectionEquality().equals(other._ranking, _ranking) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_ranking), status);

  /// Create a copy of RankingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RankingStateImplCopyWith<_$RankingStateImpl> get copyWith =>
      __$$RankingStateImplCopyWithImpl<_$RankingStateImpl>(this, _$identity);
}

abstract class _RankingState extends RankingState {
  const factory _RankingState(
      {final List<Ranking> ranking,
      final RankingStateStatus status}) = _$RankingStateImpl;
  const _RankingState._() : super._();

  @override
  List<Ranking> get ranking;
  @override
  RankingStateStatus get status;

  /// Create a copy of RankingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RankingStateImplCopyWith<_$RankingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
