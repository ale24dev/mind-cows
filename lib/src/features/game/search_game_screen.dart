import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:my_app/resources/resources.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/core/utils/widgets/generic_button.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/player/cubit/player_cubit.dart';
import 'package:my_app/src/router/router.dart';
import 'package:sized_context/sized_context.dart';

class SearchGameScreen extends StatefulWidget {
  const SearchGameScreen({super.key});

  @override
  State<SearchGameScreen> createState() => _SearchGameScreenState();
}

class _SearchGameScreenState extends State<SearchGameScreen> {
  @override
  void initState() {
    context.read<GameCubit>().findOrCreateGame();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GameCubit, GameState>(
        builder: (context, state) {
          if (state.isCancel) {
            WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
              context.pop();
            });
          }
          if (state.isGameStarted) {
            WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
              context.goNamed(AppRoute.game.name);
            });
          }
          return SizedBox(
            width: context.widthPx,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Searching for players',
                  textAlign: TextAlign.center,
                  style: AppTextStyle().bodyLarge.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                LottieBuilder.asset(
                  AppImages.bullSearchGame,
                  height: context.heightPx * .3,
                ),
                const GutterLarge(),
                GenericButton(
                  width: context.widthPx * .5,
                  widget: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle().body.copyWith(color: Colors.white),
                    ),
                  ),
                  onPressed: () {
                    context.read<GameCubit>().cancelSearchGame(
                          context.read<PlayerCubit>().state.player!,
                        );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
