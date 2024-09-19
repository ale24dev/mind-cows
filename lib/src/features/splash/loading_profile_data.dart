import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/src/core/utils/object_extensions.dart';
import 'package:my_app/src/features/auth/data/auth_repository.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/player/cubit/player_cubit.dart';
import 'package:my_app/src/router/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoadingProfileData extends StatefulWidget {
  const LoadingProfileData({super.key});

  @override
  State<LoadingProfileData> createState() => _LoadingProfileDataState();
}

class _LoadingProfileDataState extends State<LoadingProfileData> {
  @override
  Widget build(BuildContext context) {
    final gameCubit = context.watch<GameCubit>();
    log('LOADING PROFILE DATA');
    return Scaffold(
      body: BlocListener<PlayerCubit, PlayerState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          log('PlayerCubit: ${state.status}');

          if (state.status == PlayerStatus.success) {
            if (gameCubit.state.player == null) {
              context.read<GameCubit>().setUserPlayer(state.player!);
            }

            if (gameCubit.state.game.isNull) {
              WidgetsFlutterBinding.ensureInitialized()
                  .addPostFrameCallback((_) {
                context.goNamed(AppRoute.home.name);
              });
            }
          }
        },
        child: const Center(
          child: Text('Initializating profile data...'),
        ),
      ),
    );
  }
}
