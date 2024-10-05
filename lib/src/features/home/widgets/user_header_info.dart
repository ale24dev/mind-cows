import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/resources/resources.dart';
import 'package:my_app/src/core/ui/device.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/core/utils/widgets/cache_widget.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/home/widgets/user_points.dart';
import 'package:my_app/src/features/player/data/model/player.dart';
import 'package:my_app/src/features/ranking/cubit/ranking_cubit.dart';
import 'package:my_app/src/features/ranking/uitls/ranking_utils.dart';
import 'package:sized_context/sized_context.dart';

class UserHeaderInfo extends StatefulWidget {
  const UserHeaderInfo({
    super.key,
  });

  @override
  State<UserHeaderInfo> createState() => _UserHeaderInfoState();
}

class _UserHeaderInfoState extends State<UserHeaderInfo> {
  late Player player;

  @override
  Widget build(BuildContext context) {
    player = context.watch<GameCubit>().state.player!;
    return Container(
      width: context.widthPx,
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: context.responsiveContentPadding,
        child: Column(
          children: [
            SizedBox.square(dimension: context.heightPx * .1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CacheWidget(
                      size: const Size(60, 60),
                      imageUrl: player.avatarUrl,
                      fit: BoxFit.cover,
                    ),
                    const GutterSmall(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.username,
                          style: AppTextStyle()
                              .body
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        BlocBuilder<RankingCubit, RankingState>(
                          builder: (context, state) {
                            if (state.isLoading) {
                              return const CircularProgressIndicator.adaptive();
                            }

                            final ranking = RankingUtils.getRankingByPlayerId(
                              state.ranking,
                              player.id,
                            );
                            return Text(
                              '${context.l10n.rank}: ${ranking.position}',
                              style: AppTextStyle().body.copyWith(fontSize: 12),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                UserPoints(player: player),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
