class PlayerNumberRealtime {
  PlayerNumberRealtime({
    required this.isTurn,
    // required this.timeLeft,
    required this.startedTime,
    required this.finishTime,
  });

  factory PlayerNumberRealtime.fromJson(Map<String, dynamic> json) {
    return PlayerNumberRealtime(
      isTurn: json['is_turn'] as bool,
      startedTime: json['started_time'] == null
          ? DateTime.now()
          : DateTime.parse(json['started_time'] as String),
      finishTime: json['finish_time'] == null
          ? DateTime.now()
          : DateTime.parse(json['finish_time'] as String),
    );
  }

  final bool isTurn;
  // final int timeLeft;
  final DateTime startedTime;
  final DateTime finishTime;
}
