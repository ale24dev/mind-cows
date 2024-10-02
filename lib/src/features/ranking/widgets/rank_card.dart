import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:my_app/src/core/ui/theme.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/features/ranking/data/model/ranking.dart';
import 'package:sized_context/sized_context.dart';

class RankCard extends StatelessWidget {
  const RankCard({
    required this.colorScheme,
    required this.ranking,
    super.key,
  });

  final ColorScheme colorScheme;
  final Ranking ranking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      child: Container(
        width: context.widthPx,
        decoration: BoxDecoration(
          color: isDarkTheme
              ? colorScheme.primary.darken(4)
              : colorScheme.secondary.withOpacity(.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Center(
                      child: Text(
                        ranking.position.toString(),
                        style: AppTextStyle().body.copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
              const GutterMedium(),
              Text(
                ranking.player.username,
                style: AppTextStyle().body.copyWith(
                      color: colorScheme.onSecondary,
                    ),
              ),
              const Spacer(),
              Text(
                ranking.points.toString(),
                style: AppTextStyle().body.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
              ),
              const Gutter(),
            ],
          ),
        ),
      ),
    );
  }
}
