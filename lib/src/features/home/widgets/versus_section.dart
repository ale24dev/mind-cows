import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:my_app/src/core/services/game_datasource.dart';
import 'package:my_app/src/core/ui/colors.dart';
import 'package:my_app/src/core/ui/device.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/core/utils/widgets/cache_widget.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/game/data/model/game.dart';
import 'package:my_app/src/features/player/cubit/player_cubit.dart';

class VersusSection extends StatelessWidget {
  const VersusSection({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameCubit>().state;
    final rival =
        gameState.game!.getRival(context.read<PlayerCubit>().state.player!);
    if (gameState.isLoading) return const CircularProgressIndicator();
    return Padding(
      padding: context.responsiveContentPadding
          .copyWith(top: 50, left: 30, right: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CacheWidget(
            size: const Size(50, 50),
            imageUrl: rival.avatarUrl,
          ),
          const GutterSmall(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                rival.username,
                style: AppTextStyle().body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColor.titleText,
                    ),
              ),
              Text(
                'Rank: 1',
                style: AppTextStyle()
                    .body
                    .copyWith(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              _exitGame(context);
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _exitGame(BuildContext context) {
    return showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to exit the game?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                context.read<GameCubit>().refresh();
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
