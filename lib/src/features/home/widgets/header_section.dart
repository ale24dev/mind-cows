import 'package:flutter/material.dart';
import 'package:mind_cows/src/core/ui/extensions.dart';
import 'package:mind_cows/src/features/ranking/leaderboard.dart';
import 'package:mind_cows/src/features/home/widgets/versus_section.dart';
import 'package:sized_context/sized_context.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({
    required this.height,
    super.key,
    this.isCollapsed = false,
  });

  final double height;

  final bool isCollapsed;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: 200.milliseconds,
      height: height,
      width: context.widthPx,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: AnimatedSwitcher(
        duration: 500.milliseconds,
        child: const LeaderboardWidget(),
      ),
    );
  }
}
