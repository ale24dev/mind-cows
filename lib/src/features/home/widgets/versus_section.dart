import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/src/core/ui/colors.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/core/utils/widgets/cache_widget.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/game/data/model/game.dart';
import 'package:my_app/src/features/player/cubit/player_cubit.dart';
import 'package:my_app/src/features/ranking/cubit/ranking_cubit.dart';
import 'package:my_app/src/features/ranking/data/model/ranking.dart';
import 'package:my_app/src/features/ranking/uitls/ranking_utils.dart';

class VersusSection extends StatelessWidget {
  const VersusSection({required this.game, super.key});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final playerState = context.read<PlayerCubit>().state;
    final rival = game.getRivalPlayerNumber(playerState.player!);

    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 70, 30, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CacheWidget(
              size: const Size(50, 50),
              imageUrl: rival.player.avatarUrl,
            ),
            const GutterSmall(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  rival.player.username,
                  style: AppTextStyle().body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColor.titleText,
                      ),
                ),
                BlocBuilder<RankingCubit, RankingState>(
                  builder: (context, state) {
                    if (state.ranking.isEmpty) return const Text('-');
                    final rivalRanking = RankingUtils.getRankingByPlayerId(
                      state.ranking,
                      rival.player.id,
                    );
                    return Text(
                      '${context.l10n.rank}: ${rivalRanking.position}',
                      style: AppTextStyle()
                          .body
                          .copyWith(fontSize: 12, color: Colors.black45),
                    );
                  },
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              color: Colors.black,
              onPressed: () {
                _exitGame(context);
              },
              icon: const Icon(Icons.exit_to_app),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _exitGame(BuildContext context) {
    return showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Text(context.l10n.areYouSure),
          content: Text(context.l10n.doYouWantToSurrender),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(context.l10n.no),
            ),
            TextButton(
              onPressed: () {
                context.read<GameCubit>().surrender();
                Navigator.of(context).pop();
              },
              child: Text(context.l10n.yes),
            ),
          ],
        );
      },
    );
  }
}
