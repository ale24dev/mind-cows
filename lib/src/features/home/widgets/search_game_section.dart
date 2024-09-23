import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/resources/resources.dart';
import 'package:my_app/src/core/ui/theme.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/router/router.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: BlocBuilder<GameCubit, GameState>(
        builder: (context, state) {
          if (state.isGameStarted && !_hasNavigated) {
            _hasNavigated = true;
            WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
              (_) => context.goNamed(AppRoute.game.name),
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    child: Row(
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
            ],
          );
        },
      ),
    );
  }
}
