import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/home/widgets/user_header_info.dart';
import 'package:my_app/src/features/ranking/cubit/ranking_cubit.dart';
import 'package:my_app/src/features/ranking/leaderboard.dart';
import 'package:my_app/src/features/home/widgets/search_game_section.dart';
import 'package:my_app/src/router/router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    context.read<GameCubit>().getLastGame();
    context.read<RankingCubit>().loadRanking();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log('HOME PAGE');
    return Scaffold(
      body: BlocBuilder<GameCubit, GameState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (state.isGameSearching) {
            WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
              (_) => context.goNamed(AppRoute.searchGame.name),
            );
          }
          return Column(
            children: [
              const UserHeaderInfo(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(50),
                    ),
                  ),
                  child: const LeaderboardWidget(),
                ),
              ),
              const SearchGameSection(),
            ],
          );
        },
      ),
    );
  }
}
