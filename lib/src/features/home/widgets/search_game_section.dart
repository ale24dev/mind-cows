import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/resources/resources.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/player/cubit/player_cubit.dart';
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
    return BlocBuilder<GameCubit, GameState>(
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
              child: Image.asset(
                AppImages.playButton,
                height: 80,
                width: 80,
              ),
            ),
            // if (state.isGameSearching) ...[
            //   const Gutter(),
            //   const CircularProgressIndicator.adaptive(),
            // ],
          ],
        );
      },
    );
  }
}
