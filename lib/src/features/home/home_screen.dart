// ignore_for_file: avoid_bool_literals_in_conditional_expressions, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:my_app/resources/resources.dart';
import 'package:my_app/src/core/ui/device.dart';
import 'package:my_app/src/core/ui/extensions.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/game/data/model/game.dart';
import 'package:my_app/src/features/game/data/model/game_status.dart';
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
  BuildContext? _dialogContext;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();

    context.read<GameCubit>().getCurrentGame();
    context.read<GameCubit>().stream.listen((state) {
      if (state.isInSelectingSecretsNumbers) {
        if (!_isDialogOpen) {
          _showWaitingForRival();
        }
      }
      if (state.isFinished) {
        _showWinner();
        context.read<GameCubit>().removeGame();
      }

      if (state.isGameInProgress) {
        if (_isDialogOpen && _dialogContext != null) {
          Navigator.of(_dialogContext!).pop();
          _dialogContext = null;
          _isDialogOpen = false;
        }
      }
      setState(() {
        headerCollapsed = state.isGameStarted ? true : false;
      });
    });
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

  void _showWinner() {
    final game = context.read<GameCubit>().state.game!;
    final player = context.read<PlayerCubit>().state.player!;
    final rival = game.getRival(player);
    final winner = game.winner;
    final isWinner = winner?.id == player.id;
    final title = isWinner ? 'Congratulations!' : 'Better luck next time!';
    final content = isWinner
        ? 'You won against ${rival.username}!'
        : 'You lost against ${rival.username}!';

    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      (_) => showAdaptiveDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog.adaptive(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
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
                              ? GameSection(game: state.game!)
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
