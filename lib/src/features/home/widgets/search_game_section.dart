// ignore_for_file: inference_failure_on_function_invocation

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mind_cows/l10n/l10n.dart';
import 'package:mind_cows/src/core/ui/theme.dart';
import 'package:mind_cows/src/core/ui/typography.dart';
import 'package:mind_cows/src/features/auth/cubit/auth_cubit.dart';
import 'package:mind_cows/src/features/game/cubit/game_cubit.dart';
import 'package:mind_cows/src/router/router.dart';
import 'package:sized_context/sized_context.dart';

class SearchGameSection extends StatefulWidget {
  const SearchGameSection({super.key});

  @override
  State<SearchGameSection> createState() => _SearchGameSectionState();
}

class _SearchGameSectionState extends State<SearchGameSection> {
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: 35, horizontal: context.widthPx * .05),
      child: BlocBuilder<GameCubit, GameState>(
        builder: (context, state) {
          if (state.isGameStarted && !_hasNavigated) {
            _hasNavigated = true;
            WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
              (_) => context.goNamed(AppRoute.game.name),
            );
          }
          return SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Element created to center the play button
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.settings,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      context.goNamed(AppRoute.searchGame.name);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: AppTheme.defaultShadow,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_arrow, color: Colors.white),
                            const GutterTiny(),
                            Text(
                              context.l10n.play,
                              style: AppTextStyle()
                                  .textButton
                                  .copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => context.goNamed(AppRoute.settings.name),
                      child: const Icon(Icons.settings),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
