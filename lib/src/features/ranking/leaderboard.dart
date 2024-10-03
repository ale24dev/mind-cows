import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/features/ranking/cubit/ranking_cubit.dart';
import 'package:my_app/src/features/ranking/mocks/ranking_mocks.dart';
import 'package:my_app/src/features/ranking/widgets/rank_card.dart';
import 'package:my_app/src/features/ranking/widgets/top_three_players.dart';
import 'package:sized_context/sized_context.dart';
import 'package:skeletonizer/skeletonizer.dart';

class LeaderboardWidget extends StatefulWidget {
  const LeaderboardWidget({
    super.key,
  });

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocConsumer<RankingCubit, RankingState>(
      listener: (context, state) {
        if (state.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error'),
            ),
          );
        }
      },
      builder: (context, state) {
        final rankings = state.isLoading ? rankingMock : state.ranking;
        return Column(
          children: [
            const GutterLarge(),
            Text(
              'Leaderboard',
              style: AppTextStyle().bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 35,
                    fontFamily: AppTextStyle.secondaryFontFamily,
                  ),
            ),
            const GutterSmall(),
            Skeletonizer(
              enabled: state.isLoading,
              child: TopThreePlayers(rankings),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.widthPx * .1),
                child: Stack(
                  children: [
                    Skeletonizer(
                      enabled: state.isLoading,
                      child: ListView.builder(
                        itemCount: rankings.length,
                        itemBuilder: (context, index) {
                          final ranking = rankings[index];
                          if (index <= 2) return const SizedBox.shrink();
                          return RankCard(
                            colorScheme: colorScheme,
                            ranking: ranking,
                          );
                        },
                      ),
                    ),
                    IgnorePointer(
                      child: Opacity(
                        opacity: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                colorScheme.primary.withOpacity(.05),
                                colorScheme.primary,
                              ],
                              stops: const [
                                0.5,
                                1,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
