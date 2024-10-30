import 'package:json_annotation/json_annotation.dart';
import 'package:mind_cows/src/core/supabase/table_interface.dart';
import 'package:mind_cows/src/features/player/data/model/player.dart';
import 'package:equatable/equatable.dart';

part 'player_number.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class PlayerNumber extends Equatable with TableInterface {
  PlayerNumber({
    required this.id,
    required this.player,
    required this.isTurn,
    required this.timeLeft,
    this.startedTime,
    this.finishTime,
    this.number,
  });

  factory PlayerNumber.empty() => PlayerNumber(
        id: 0,
        player: Player.empty(),
        startedTime: DateTime.now(),
        number: const [],
        isTurn: false,
        timeLeft: 0,
      );

  factory PlayerNumber.fromJson(Map<String, dynamic> json) =>
      _$PlayerNumberFromJson(json);
  final int id;
  final Player player;
  final bool isTurn;
  final int timeLeft;

  /// Started time of the turn
  final DateTime? startedTime;

  /// Finished time of the turn
  final DateTime? finishTime;
  final List<int>? number;

  @override
  String columns() => 'id, player(${player.columns()}), number';

  @override
  String tableName() => 'player_number';

  @override
  List<Object?> get props => [id, player, number];
}

extension PlayerNumberX on PlayerNumber {
  bool get haveNumber => number != null && number!.isNotEmpty;

  bool get canPlay => isTurn;

  PlayerNumber copyWith({
    int? id,
    Player? player,
    List<int>? number,
    bool? isTurn,
    int? timeLeft,
    DateTime? startedTime,
    DateTime? finishTime,
  }) {
    return PlayerNumber(
      id: id ?? this.id,
      player: player ?? this.player,
      number: number ?? this.number,
      isTurn: isTurn ?? this.isTurn,
      timeLeft: timeLeft ?? this.timeLeft,
      startedTime: startedTime ?? this.startedTime,
      finishTime: finishTime ?? this.finishTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'player': player.id,
      'number': number,
    };
  }
}
