// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mind_cows/src/core/di/dependency_injection.dart';
import 'package:mind_cows/src/core/utils/object_extensions.dart';
import 'package:mind_cows/src/features/game/cubit/game_cubit.dart';
import 'package:mind_cows/src/features/home/widgets/user_header_info.dart';
import 'package:mind_cows/src/features/ranking/cubit/ranking_cubit.dart';
import 'package:mind_cows/src/features/ranking/leaderboard.dart';
import 'package:mind_cows/src/features/home/widgets/search_game_section.dart';
import 'package:mind_cows/src/router/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    getIt.get<SupabaseClient>().auth.onAuthStateChange.listen((authSupState) {
      final route = switch (authSupState.event) {
        AuthChangeEvent.initialSession =>
          authSupState.session.isNull ? AppRoute.auth.name : AppRoute.home.name,
        AuthChangeEvent.signedIn => AppRoute.home.name,
        AuthChangeEvent.signedOut => AppRoute.auth.name,
        _ => null
      };
      if (mounted) {
        if (route != null) context.goNamed(route);

        if (authSupState.event == AuthChangeEvent.signedOut) {
          context.read<GameCubit>().dispose();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
