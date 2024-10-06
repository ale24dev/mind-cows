import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/resources/resources.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/core/utils/object_extensions.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/player/cubit/player_cubit.dart';
import 'package:my_app/src/features/splash/cubit/app_cubit.dart';
import 'package:my_app/src/router/router.dart';
import 'package:sized_context/sized_context.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Completer<void> _appInitCompleter = Completer<void>();
  final Completer<void> _profileDataCompleter = Completer<void>();

  @override
  void initState() {
    super.initState();
    context.read<AppCubit>().initialize();
    _waitForInitialization();
  }

  Future<void> _waitForInitialization() async {
    await Future.wait([
      _appInitCompleter.future,
      _profileDataCompleter.future,
    ]);
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
      context.goNamed(AppRoute.home.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameCubit = context.read<GameCubit>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: MultiBlocListener(
        listeners: [
          BlocListener<AppCubit, AppState>(
            listener: (context, state) {
              if (state.isSuccess && state.initialized) {
                context.read<GameCubit>().setGameStatus(state.gameStatus);
                if (!_appInitCompleter.isCompleted) {
                  _appInitCompleter.complete();
                }
              }
              if (state.isError) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(context.l10n.error),
                    content: Text(context.l10n.anErrorOccurred),
                    actions: [
                      TextButton(
                        onPressed: () {
                          context.read<AppCubit>().initialize();
                          Navigator.of(context).pop();
                        },
                        child: Text(context.l10n.retry),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          BlocListener<PlayerCubit, PlayerState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == PlayerStatus.success) {
                if (gameCubit.state.player == null) {
                  context.read<GameCubit>().setUserPlayer(state.player!);
                }

                if (gameCubit.state.game.isNull) {
                  if (!_profileDataCompleter.isCompleted) {
                    _profileDataCompleter.complete();
                  }
                }
              }
            },
          ),
        ],
        child: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            if (state.isLoading) {
              return SizedBox(
                width: context.widthPx,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LottieBuilder.asset(
                      AppImages.appLoading,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    const GutterSmall(),
                    Text(
                      context.l10n.loading,
                      style: AppTextStyle().body.copyWith(color: Colors.black),
                    ),
                  ],
                ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
