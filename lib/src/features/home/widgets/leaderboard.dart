import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:sized_context/sized_context.dart';

class LeaderboardWidget extends StatelessWidget {
  const LeaderboardWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Leaderboard',
          style: AppTextStyle().bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gutter(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const GutterTiny(),
                  Text(
                    'User ${index + 1}',
                    style: AppTextStyle().body,
                  ),
                ],
              ),
            ),
          ),
        ),
        ...List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              width: context.widthPx,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text((index + 1).toString()),
                      ),
                    ),
                    const GutterMedium(),
                    Text(
                      'data'.capitalize,
                      style: AppTextStyle().body.copyWith(color: Colors.white),
                    ),
                    const Spacer(),
                    Text(
                      '100',
                      style: AppTextStyle().body.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Gutter(),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
