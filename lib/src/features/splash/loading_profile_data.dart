import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/resources/resources.dart';
import 'package:my_app/src/core/utils/object_extensions.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/player/cubit/player_cubit.dart';
import 'package:my_app/src/router/router.dart';

class LoadingProfileData extends StatefulWidget {
  const LoadingProfileData({super.key});

  @override
  State<LoadingProfileData> createState() => _LoadingProfileDataState();
}

class _LoadingProfileDataState extends State<LoadingProfileData> {
  @override
  Widget build(BuildContext context) {
    final gameCubit = context.read<GameCubit>();
    return Scaffold(
      body: BlocListener<PlayerCubit, PlayerState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == PlayerStatus.success) {
            if (gameCubit.state.player == null) {
              context.read<GameCubit>().setUserPlayer(state.player!);
            }

            // if (gameCubit.state.game.isNull) {
              WidgetsFlutterBinding.ensureInitialized()
                  .addPostFrameCallback((_) {
                context.goNamed(AppRoute.home.name);
              });
            // }
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LottieBuilder.asset(
                AppImages.appLoading,
                height: 100,
                fit: BoxFit.cover,
              ),
              const GutterSmall(),
              Text(context.l10n.loading),
            ],
          ),
        ),
      ),
    );
  }
}
