import 'package:flutter/material.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/features/player/data/model/player_number.dart';

class GameTurnWidget extends StatelessWidget {
  const GameTurnWidget({
    required this.ownPlayerNumber,
    super.key,
  });

  final PlayerNumber ownPlayerNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ownPlayerNumber.isTurn ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Text(
          ownPlayerNumber.isTurn ? 'Your turn' : 'Rival turn',
          style: AppTextStyle().body.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
