import 'package:json_annotation/json_annotation.dart';
import 'package:mind_cows/src/core/supabase/table_interface.dart';
import 'package:mind_cows/src/features/game/data/model/game_status.dart';
import 'package:mind_cows/src/features/player/data/model/player.dart';
import 'package:mind_cows/src/features/player/data/model/player_number.dart';

part 'game.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Game with TableInterface {
  Game({
    @JsonKey(includeToJson: false) required this.id,
    required this.status,
    @JsonKey(includeToJson: false) this.playerNumber1,
    @JsonKey(includeToJson: false) this.playerNumber2,
    this.winner,
  });

  factory Game.empty() => Game(
        id: 0,
        status: GameStatus.empty(),
      );

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
  final int id;
  final GameStatus status;
  final PlayerNumber? playerNumber1;
  final PlayerNumber? playerNumber2;
  final Player? winner;

  @override
  String columns() => '''
        id, status(${status.columns()}),
        player_number1(${playerNumber1?.columns()}), player_number2(${playerNumber2?.columns()}),
        winner(${winner?.columns()})
      ''';

  @override
  String tableName() => 'game';
}

extension GameX on Game {
  bool get isSearching => status.status == StatusEnum.searching;
  bool get isInSelectingSecretsNumbers =>
      status.status == StatusEnum.selectingSecretNumbers;
  bool get isInProgress => status.status == StatusEnum.inProgress;
  bool get isFinished => status.status == StatusEnum.finished;

  PlayerNumber getRivalPlayerNumber(Player player) {
    if (playerNumber1?.player.id == player.id) {
      return playerNumber2!;
    } else {
      return playerNumber1!;
    }
  }

  PlayerNumber getOwnPlayerNumber(Player player) {
    if (playerNumber1?.player.id == player.id) {
      return playerNumber1!;
    } else {
      return playerNumber2!;
    }
  }

  Game copyWith({
    int? id,
    GameStatus? status,
    PlayerNumber? playerNumber1,
    PlayerNumber? playerNumber2,
    Player? winner,
  }) {
    return Game(
      id: id ?? this.id,
      status: status ?? this.status,
      playerNumber1: playerNumber1 ?? this.playerNumber1,
      playerNumber2: playerNumber2 ?? this.playerNumber2,
      winner: winner ?? this.winner,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.id,
      'player_number1': playerNumber1?.id,
      'player_number2': playerNumber2?.id,
      'winner': winner?.id,
    };
  }
}
