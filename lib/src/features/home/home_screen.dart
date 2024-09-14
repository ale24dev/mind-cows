// ignore_for_file: avoid_bool_literals_in_conditional_expressions

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:my_app/resources/resources.dart';
import 'package:my_app/src/core/ui/device.dart';
import 'package:my_app/src/core/ui/extensions.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/home/widgets/game_section.dart';
import 'package:my_app/src/features/home/widgets/header_section.dart';
import 'package:my_app/src/features/player/cubit/player_cubit.dart';
import 'package:sized_context/sized_context.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool headerCollapsed = false;

  @override
  void initState() {
    context.read<GameCubit>().getCurrentGame();
    context.read<GameCubit>().stream.listen((state) {
      setState(() {
        headerCollapsed = state.isGameInProgress ? true : false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final headerSection = context.heightPx * .7;
    final headerSectionCollapsed = context.heightPx * .15;

    return Scaffold(
      body: BlocBuilder<GameCubit, GameState>(
        builder: (context, state) {
          return SizedBox(
            height: context.heightPx,
            width: context.widthPx,
            child: Column(
              children: [
                HeaderSection(
                  height:
                      headerCollapsed ? headerSectionCollapsed : headerSection,
                  isCollapsed: headerCollapsed,
                ),
                const GutterLarge(),
                Padding(
                  padding: context.responsiveContentPadding,
                  child: AnimatedContainer(
                    duration: 500.milliseconds,
                    height: headerCollapsed
                        ? headerSection
                        : headerSectionCollapsed,
                    child: Column(
                      children: [
                        AnimatedSwitcher(
                          duration: 300.milliseconds,
                          child: headerCollapsed
                              ? const GameSection()
                              : _SearchGameSection(state: state),
                        ),
                      ],
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

class _SearchGameSection extends StatelessWidget {
  const _SearchGameSection({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final player = context.read<PlayerCubit>().state.player!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => context.read<GameCubit>().findOrCreateGame(
                player,
              ),
          child: Image.asset(
            AppImages.playButton,
            height: 80,
            width: 80,
          ),
        ),
        if (state.isGameSearching) ...[
          const Gutter(),
          const CircularProgressIndicator.adaptive(),
        ],
      ],
    );
  }
}
