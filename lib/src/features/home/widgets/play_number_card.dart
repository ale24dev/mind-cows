import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:my_app/src/core/ui/theme.dart';

class PlayNumberCard extends StatelessWidget {
  const PlayNumberCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
        children: [
          const Text('1'),
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
                      return _NumberPlay((index + 1).toString());
                    }),
                    const Gutter(),
                    const Text('1V'),
                    const Gutter(),
                    const Text('1T'),
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
