import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:my_app/resources/resources.dart';
import 'package:my_app/src/core/ui/extensions.dart';
import 'package:my_app/src/features/home/cubit/game_cubit.dart';
import 'package:my_app/src/features/home/widgets/header_section.dart';
import 'package:sized_context/sized_context.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool headerCollapsed = false;
  @override
  Widget build(BuildContext context) {
    final headerSection = context.heightPx * .8;
    final headerSectionCollapsed = context.heightPx * .15;

    return Scaffold(
      body: BlocBuilder<GameCubit, GameState>(
        builder: (context, state) {
          if (state.status.isPlaying) {
            headerCollapsed = true;
          }
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
                AnimatedContainer(
                  duration: 500.milliseconds,
                  height:
                      headerCollapsed ? headerSection : headerSectionCollapsed,
                  child: Column(
                    children: [
                      AnimatedSwitcher(
                        duration: 300.milliseconds,
                        child: headerCollapsed
                            ? null
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () => context
                                        .read<GameCubit>()
                                        .searchForGame(),
                                    child: Image.asset(
                                      AppImages.playButton,
                                      height: 80,
                                      width: 80,
                                    ),
                                  ),
                                  if (state.status.isSearching) ...[
                                    const Gutter(),
                                    const CircularProgressIndicator.adaptive(),
                                  ],
                                ],
                              ),
                      ),
                    ],
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
