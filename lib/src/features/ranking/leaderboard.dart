import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/features/ranking/cubit/ranking_cubit.dart';
import 'package:my_app/src/features/ranking/widgets/rank_card.dart';
import 'package:my_app/src/features/ranking/widgets/top_three_players.dart';
import 'package:sized_context/sized_context.dart';

class LeaderboardWidget extends StatefulWidget {
  const LeaderboardWidget({
    super.key,
  });

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  @override
  void initState() {
    context.read<RankingCubit>().loadRanking();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<RankingCubit, RankingState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (state.isError) {
          return const Center(child: Text('Error'));
        }
        return Column(
          children: [
            const GutterLarge(),
            Text(
              'Leaderboard',
              style: AppTextStyle()
                  .bodyLarge
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            TopThreePlayers(state.ranking),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.widthPx * .1),
                child: Stack(
                  children: [
                    ListView.builder(
                      itemCount: state.ranking.length,
                      itemBuilder: (context, index) {
                        final ranking = state.ranking[index];
                        if (index <= 2) return const SizedBox.shrink();
                        return RankCard(
                          colorScheme: colorScheme,
                          ranking: ranking,
                        );
                      },
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
