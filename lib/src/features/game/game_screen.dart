import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/resources/resources.dart';
import 'package:my_app/src/core/extensions/list.dart';
import 'package:my_app/src/core/ui/extensions.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/core/utils/object_extensions.dart';
import 'package:my_app/src/core/utils/utils.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/game/data/model/game.dart';
import 'package:my_app/src/features/game/utils/game_utils.dart';
import 'package:my_app/src/features/home/widgets/game_section.dart';
import 'package:my_app/src/features/home/widgets/select_secret_number.dart';
import 'package:my_app/src/features/home/widgets/versus_section.dart';
import 'package:my_app/src/features/player/cubit/player_cubit.dart';
import 'package:my_app/src/features/player/data/model/player.dart';
import 'package:my_app/src/features/player/data/model/player_number.dart';
import 'package:my_app/src/features/player/data/player_repository.dart';
import 'package:my_app/src/router/router.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  BuildContext? _dialogContext;
  bool _isDialogOpen = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: BlocConsumer<GameCubit, GameState>(
        listener: (context, state) {
          if (state.lastRivalResult.isNotNull) {
            context.genericMessage(
              widget: RichText(
                text: TextSpan(
                  style: AppTextStyle()
                      .body
                      .copyWith(color: colorScheme.onSurface),
                  children: [
                    TextSpan(text: context.l10n.yourOpponentHasScored),
                    TextSpan(
                      text: Utils.attemptResult(
                        context,
                        state.lastRivalResult!.$1,
                        state.lastRivalResult!.$2,
                      ),
                      style: AppTextStyle().body.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
            );
            context.read<GameCubit>().removeLastRivalResult();
          }
        },
        builder: (context, state) {
          if (!state.isLoading && state.game.isNotNull) {
            _gameStatusChanged(state);
          }
          if (state.game.isNull) {
            return const CircularProgressIndicator.adaptive();
          }
          return Column(
            children: [
              VersusSection(game: state.game!),
              Expanded(child: GameSection(gameState: state)),
            ],
          );
        },
      ),
    );
  }

  void _gameStatusChanged(GameState state) {
    final game = state.game;
    final player = context.read<PlayerCubit>().state.player!;
    final ownPlayerNumber = game!.getOwnPlayerNumber(player);
    final rivalPlayerNumber = game.getRivalPlayerNumber(player);
    if (state.isInSelectingSecretsNumbers &&
        ownPlayerNumber.number == null &&
        !state.selectSecretNumberShowed) {
      WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
        (_) {
          context.read<GameCubit>().selectSecretNumberShowed(true);
          showAdaptiveDialog<void>(
            context: context,
            builder: (context) => SelectSecretNumber(
              playerNumber: ownPlayerNumber,
              onSelect: () {
                Navigator.pop(context);
                context.read<GameCubit>().getLastGame();
              },
            ),
          );
        },
      );
    } else if (state.isInSelectingSecretsNumbers &&
        ownPlayerNumber.number.isNotNull &&
        rivalPlayerNumber.number.isNull &&
        state.selectSecretNumberShowed) {
      _showWaitingForRival();
    }

    if (state.game!.isFinished) {
      WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
        _showWinner(game, player, rivalPlayerNumber);
      });
    }

    if (state.isGameInProgress &&
        _isDialogOpen &&
        (_dialogContext?.mounted ?? false)) {
      WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
        Navigator.pop(_dialogContext!);
      });
    }
  }

  void _showWaitingForRival() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAdaptiveDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Builder(
            builder: (dialogContext) {
              _dialogContext = dialogContext;
              _isDialogOpen = true;
              return AlertDialog.adaptive(
                title: Text(context.l10n.waitingForRival),
                content: Text(context.l10n.waitingForRivalDescription),
              );
            },
          );
        },
      );
    });
  }

  void _showWinner(Game game, Player player, PlayerNumber rival) {
    final winner = game.winner;
    final isWinner = winner?.id == player.id;
    final title =
        isWinner ? context.l10n.congratulations : context.l10n.youLose;
    final imageResult = isWinner ? AppImages.winGame : AppImages.loseGame;
    final resultPoints = GameUtils.calculateResultPoints(
      wonCurrentGame: isWinner,
      minimumAttempts: context.read<GameCubit>().state.listAttempts.length,
    );

    if (mounted) {
      showAdaptiveDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog.adaptive(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isWinner)
                  Text.rich(
                    TextSpan(
                      text: context.l10n.theSecretNumberWas,
                      style: AppTextStyle().body.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                      children: <TextSpan>[
                        TextSpan(
                          text: rival.number!.parseNumberListToString,
                          style: AppTextStyle().body.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                  ),
                LottieBuilder.asset(
                  imageResult,
                  height: isWinner ? 160 : 130,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AppImages.gamePoints, height: 20),
                    const GutterTiny(),
                    Text(
                      '${isWinner ? '+' : ''}$resultPoints',
                      style: AppTextStyle().body.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.goNamed(AppRoute.home.name);
                  context.read<GameCubit>().refresh();
                },
                child: Text(context.l10n.accept),
              ),
            ],
          );
        },
      );
      //   WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      //     (_) => showAdaptiveDialog<void>(
      //       barrierDismissible: false,
      //       context: context,
      //       builder: (context) {
      //         return AlertDialog.adaptive(
      //           title: Text(title),
      //           content: Column(
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               if (!isWinner)
      //                 Text.rich(
      //                   TextSpan(
      //                     text: context.l10n.theSecretNumberWas,
      //                     style: AppTextStyle().body.copyWith(
      //                           color: Theme.of(context).colorScheme.onSurface,
      //                         ),
      //                     children: <TextSpan>[
      //                       TextSpan(
      //                         text: rival.number!.parseNumberListToString,
      //                         style: AppTextStyle().body.copyWith(
      //                               fontWeight: FontWeight.bold,
      //                               color:
      //                                   Theme.of(context).colorScheme.onSurface,
      //                             ),
      //                       ),
      //                     ],
      //                   ),
      //                 ),
      //               LottieBuilder.asset(
      //                 imageResult,
      //                 height: isWinner ? 160 : 130,
      //               ),
      //               Row(
      //                 mainAxisAlignment: MainAxisAlignment.center,
      //                 children: [
      //                   Image.asset(AppImages.gamePoints, height: 20),
      //                   const GutterTiny(),
      //                   Text(
      //                     '${isWinner ? '+' : ''}$resultPoints',
      //                     style: AppTextStyle().body.copyWith(
      //                           fontWeight: FontWeight.bold,
      //                           color: Theme.of(context).colorScheme.onSurface,
      //                         ),
      //                   ),
      //                 ],
      //               ),
      //             ],
      //           ),
      //           actions: [
      //             TextButton(
      //               onPressed: () {
      //                 Navigator.pop(context);
      //                 context.goNamed(AppRoute.home.name);
      //                 context.read<GameCubit>().refresh();
      //               },
      //               child: Text(context.l10n.accept),
      //             ),
      //           ],
      //         );
      //       },
      //     ),
      //   );
    }
  }
}
