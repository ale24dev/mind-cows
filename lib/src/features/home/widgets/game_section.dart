import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/src/core/extensions/string.dart';
import 'package:my_app/src/core/ui/device.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/core/utils/utils.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/game/data/model/attempt.dart';
import 'package:my_app/src/features/game/data/model/game.dart';
import 'package:my_app/src/features/game/domain/mocks/attempt_mock.dart';
import 'package:my_app/src/features/game/widgets/game_turn_widget.dart';
import 'package:my_app/src/features/home/widgets/otp_fields.dart';
import 'package:my_app/src/features/home/widgets/play_number_card.dart';
import 'package:my_app/src/features/player/cubit/player_cubit.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GameSection extends HookWidget {
  const GameSection({required this.gameState, super.key});

  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    final player = context.read<PlayerCubit>().state.player!;
    final game = gameState.game!;
    // final rival = game.getRivalPlayerNumber(player).player;
    final ownPlayerNumber = game.getOwnPlayerNumber(player);

    final initialTimeLeft = useState<int>(
      calculateInitialTimeLeft(
        ownPlayerNumber.startedTime,
        ownPlayerNumber.finishTime,
      ),
    );

    final isFirstRender = useState<bool>(true);

    useEffect(
      () {
        Timer? timer;
        if (gameState.isGameInProgress && ownPlayerNumber.isTurn) {
          if (isFirstRender.value) {
            initialTimeLeft.value = calculateInitialTimeLeft(
              ownPlayerNumber.startedTime,
              ownPlayerNumber.finishTime,
            );
            isFirstRender.value = false;
          }
          timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (initialTimeLeft.value > 0) {
              initialTimeLeft.value--;
            } else {
              timer.cancel();
            }
          });
        }
        return timer?.cancel;
      },
      [gameState.isGameInProgress, ownPlayerNumber.isTurn],
    );

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: context.responsiveContentPadding,
      child: Column(
        children: [
          const Gutter(),
          GameTurnWidget(ownPlayerNumber: ownPlayerNumber),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                context.l10n.timeLeft,
                style: AppTextStyle().body.copyWith(
                      color: colorScheme.onSurface,
                    ),
              ),
              Text(
                '${(initialTimeLeft.value ~/ 60).toString().padLeft(2, '0')}:${(initialTimeLeft.value % 60).toString().padLeft(2, '0')}',
                style: AppTextStyle().body.copyWith(
                      color: colorScheme.onSurface,
                    ),
              ),
            ],
          ),
          const Expanded(child: _PlayList()),
          const Gutter(),
          _SendNumberSection(
            game: game,
            canSendNumber: ownPlayerNumber.isTurn,
          ),
          const GutterLarge(),
        ],
      ),
    );
  }

  int calculateInitialTimeLeft(DateTime? startedTime, DateTime? finishedTime) {
    // Retorna 0 si no hay tiempo para calcular
    if (startedTime == null || finishedTime == null) {
      return 0;
    }

    // Obtén el tiempo actual del servidor
    final currentTime = gameState.serverTime ??
        DateTime.now(); // Usa el servidor, o la hora local como respaldo

    // Asegúrate de que ambas horas están en UTC
    final currentTimeUtc = currentTime.toUtc();
    final finishedTimeUtc = finishedTime.toUtc();

    // Lógica para verificar si el tiempo actual ha pasado el tiempo final
    if (currentTimeUtc.isAfter(finishedTimeUtc)) {
      return 0; // Retorna 0 si el tiempo ha pasado
    }

    // Calcula la diferencia en segundos
    final timeLeft = finishedTimeUtc.difference(currentTimeUtc).inSeconds;

    return timeLeft;
  }
}

class _PlayList extends StatelessWidget {
  const _PlayList();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Text(
          context.l10n.previousAttempts.toUpperCase(),
          style: AppTextStyle().body.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
        ),
        const GutterSmall(),
        BlocBuilder<GameCubit, GameState>(
          builder: (context, state) {
            if (state.isError) {
              // log('Error');
            }

            final attempts = state.isLoading
                ? getAttemptsMock(state.listAttempts.length + 1)
                : state.listAttempts;
            return Skeletonizer(
              enabled: state.isLoading,
              child: Column(
                children: attempts.isEmpty
                    ? [
                        Center(
                          child: Text(
                            context.l10n.noAttempts,
                            style: AppTextStyle().body.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                          ),
                        ),
                      ]
                    : attempts.asMap().entries.map((entry) {
                        final index = attempts.length - entry.key;
                        final value = entry.value;
                        return PlayNumberCard(attempt: value, index: index);
                      }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SendNumberSection extends StatefulWidget {
  const _SendNumberSection({required this.game, required this.canSendNumber});

  final Game game;
  final bool canSendNumber;

  @override
  __SendNumberSectionState createState() => __SendNumberSectionState();
}

class __SendNumberSectionState extends State<_SendNumberSection> {
  final GlobalKey<OTPFieldsState> otpFieldsKey = GlobalKey<OTPFieldsState>();
  String otpValue = '';

  void _onChanged(String otp) {
    setState(() {
      otpValue = otp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const IconButton(
          onPressed: null,
          icon: Icon(Icons.send, color: Colors.transparent),
        ),
        OTPFields(
          key: otpFieldsKey,
          allowRepetitions: false,
          onChanged: _onChanged,
        ),
        IconButton(
          onPressed: !widget.canSendNumber
              ? null
              : () {
                  final isValidNumber = Utils.isValidPlayerNumber(otpValue);
                  if (!isValidNumber) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.introduceValidNumber),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  context.read<GameCubit>().insertAttempt(
                        Attempt.empty()
                            .copyWith(number: otpValue.parseOptToNumberValue),
                      );
                  otpFieldsKey.currentState?.clearFields();
                },
          icon: Icon(
            Icons.send,
            color: widget.canSendNumber
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(.4),
          ),
        ),
      ],
    );
  }
}
