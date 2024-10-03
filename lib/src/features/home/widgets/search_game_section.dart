// ignore_for_file: inference_failure_on_function_invocation

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/src/core/ui/theme.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/features/auth/cubit/auth_cubit.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/router/router.dart';
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
          EdgeInsets.symmetric(vertical: 40, horizontal: context.widthPx * .05),
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
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showLogoutConfirmationDialog(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.logout),
                        const GutterTiny(),
                        Text(
                          'Exit',
                          style: AppTextStyle().body.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ],
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
                              'Play',
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
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: AppTextStyle().textButton.copyWith(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthCubit>().logout();
              },
              child: Text(
                'Logout',
                style: AppTextStyle()
                    .textButton
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }
}
