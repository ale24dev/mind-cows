import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/src/core/utils/object_extensions.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/game/data/model/game.dart';
import 'package:my_app/src/features/home/widgets/game_section.dart';
import 'package:my_app/src/features/home/widgets/select_secret_number.dart';
import 'package:my_app/src/features/home/widgets/versus_section.dart';
import 'package:my_app/src/features/player/cubit/player_cubit.dart';
import 'package:my_app/src/features/player/data/model/player.dart';
import 'package:my_app/src/features/player/data/model/player_number.dart';
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
    return Scaffold(
      body: BlocBuilder<GameCubit, GameState>(
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
              Expanded(child: GameSection(game: state.game!)),
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
        ownPlayerNumber.number.isNull &&
        rivalPlayerNumber.number.isNull &&
        !state.selectSecretNumberShowed) {
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
              return const AlertDialog.adaptive(
                title: Text('Waiting for rival'),
                content:
                    Text('Please wait for your rival to add the secret number'),
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
    final title = isWinner ? 'Congratulations!' : 'Better luck next time!';
    final content = isWinner
        ? 'You won against ${rival.player.username}!'
        : 'You lost against ${rival.player.username}!';

    if (mounted) {
      WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
        (_) => showAdaptiveDialog<void>(
          context: context,
          builder: (context) {
            return AlertDialog.adaptive(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.goNamed(AppRoute.home.name);
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        ),
      );
    }
  }
}
