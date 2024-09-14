// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GameState {
  Game? get game => throw _privateConstructorUsedError;
  GameStateStatus get status => throw _privateConstructorUsedError;
  List<GameStatus> get listGameStatus => throw _privateConstructorUsedError;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameStateCopyWith<GameState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameStateCopyWith<$Res> {
  factory $GameStateCopyWith(GameState value, $Res Function(GameState) then) =
      _$GameStateCopyWithImpl<$Res, GameState>;
  @useResult
  $Res call(
      {Game? game, GameStateStatus status, List<GameStatus> listGameStatus});
}

/// @nodoc
class _$GameStateCopyWithImpl<$Res, $Val extends GameState>
    implements $GameStateCopyWith<$Res> {
  _$GameStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? game = freezed,
    Object? status = null,
    Object? listGameStatus = null,
  }) {
    return _then(_value.copyWith(
      game: freezed == game
          ? _value.game
          : game // ignore: cast_nullable_to_non_nullable
              as Game?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GameStateStatus,
      listGameStatus: null == listGameStatus
          ? _value.listGameStatus
          : listGameStatus // ignore: cast_nullable_to_non_nullable
              as List<GameStatus>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GameStateImplCopyWith<$Res>
    implements $GameStateCopyWith<$Res> {
  factory _$$GameStateImplCopyWith(
          _$GameStateImpl value, $Res Function(_$GameStateImpl) then) =
      __$$GameStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Game? game, GameStateStatus status, List<GameStatus> listGameStatus});
}

/// @nodoc
class __$$GameStateImplCopyWithImpl<$Res>
    extends _$GameStateCopyWithImpl<$Res, _$GameStateImpl>
    implements _$$GameStateImplCopyWith<$Res> {
  __$$GameStateImplCopyWithImpl(
      _$GameStateImpl _value, $Res Function(_$GameStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? game = freezed,
    Object? status = null,
    Object? listGameStatus = null,
  }) {
    return _then(_$GameStateImpl(
      game: freezed == game
          ? _value.game
          : game // ignore: cast_nullable_to_non_nullable
              as Game?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GameStateStatus,
      listGameStatus: null == listGameStatus
          ? _value._listGameStatus
          : listGameStatus // ignore: cast_nullable_to_non_nullable
              as List<GameStatus>,
    ));
  }
}

/// @nodoc

class _$GameStateImpl extends _GameState {
  const _$GameStateImpl(
      {this.game,
      this.status = GameStateStatus.initial,
      final List<GameStatus> listGameStatus = const []})
      : _listGameStatus = listGameStatus,
        super._();

  @override
  final Game? game;
  @override
  @JsonKey()
  final GameStateStatus status;
  final List<GameStatus> _listGameStatus;
  @override
  @JsonKey()
  List<GameStatus> get listGameStatus {
    if (_listGameStatus is EqualUnmodifiableListView) return _listGameStatus;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_listGameStatus);
  }

  @override
  String toString() {
    return 'GameState(game: $game, status: $status, listGameStatus: $listGameStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameStateImpl &&
            (identical(other.game, game) || other.game == game) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._listGameStatus, _listGameStatus));
  }

  @override
  int get hashCode => Object.hash(runtimeType, game, status,
      const DeepCollectionEquality().hash(_listGameStatus));

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      __$$GameStateImplCopyWithImpl<_$GameStateImpl>(this, _$identity);
}

abstract class _GameState extends GameState {
  const factory _GameState(
      {final Game? game,
      final GameStateStatus status,
      final List<GameStatus> listGameStatus}) = _$GameStateImpl;
  const _GameState._() : super._();

  @override
  Game? get game;
  @override
  GameStateStatus get status;
  @override
  List<GameStatus> get listGameStatus;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
