import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/src/core/ui/device.dart';
import 'package:my_app/src/features/settings/data/model/rules.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({required this.rules, super.key});

  final Rules rules;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.howToPlay)),
      body: Padding(
        padding: context.responsiveContentPadding,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Gutter(),
              Text(rules.rules),
              const Gutter(),
            ],
          ),
        ),
      ),
    );
  }
}
