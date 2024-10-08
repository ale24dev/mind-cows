import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:mind_cows/resources/resources.dart';
import 'package:mind_cows/src/core/ui/typography.dart';
import 'package:mind_cows/src/features/player/data/model/player.dart';
import 'package:mind_cows/src/features/ranking/cubit/ranking_cubit.dart';
import 'package:mind_cows/src/features/ranking/uitls/ranking_utils.dart';

class UserPoints extends StatelessWidget {
  const UserPoints({
    required this.player, super.key,
  });

  final Player player;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Image.asset(
              AppImages.gamePoints,
              height: 20,
            ),
            const GutterTiny(),
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
                  '${ranking.points}',
                  style:
                      AppTextStyle().body.copyWith(fontWeight: FontWeight.bold),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
