import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:my_app/src/core/ui/theme.dart';
import 'package:my_app/src/features/game/data/model/attempt.dart';

class PlayNumberCard extends StatelessWidget {
  const PlayNumberCard({required this.attempt, required this.index, super.key});

  final Attempt attempt;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
        children: [
          Text(index.toString()),
          const GutterLarge(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: AppTheme.defaultShadow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(4, (index) {
                      return _NumberPlay(attempt.number[index].toString());
                    }),
                    const Gutter(),
                    Text('${attempt.cows}V'),
                    const Gutter(),
                    Text('${attempt.bulls}T'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberPlay extends StatelessWidget {
  const _NumberPlay(this.number);

  final String number;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(number),
        ),
      ),
    );
  }
}