import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/src/core/extensions/string.dart';
import 'package:my_app/src/core/utils/object_extensions.dart';
import 'package:my_app/src/features/game/game_screen.dart';
import 'package:my_app/src/features/player/cubit/player_cubit.dart';
import 'package:my_app/src/features/player/data/model/player.dart';
import 'package:my_app/src/features/game/data/model/game.dart';
import 'package:my_app/src/features/game/widgets/game_turn_widget.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/core/ui/device.dart';
import 'package:my_app/src/features/home/widgets/play_number_card.dart';
import 'package:my_app/src/features/home/widgets/otp_fields.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/game/data/model/attempt.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:my_app/src/core/utils/utils.dart';

class GameSection extends StatefulWidget {
  const GameSection({required this.game, super.key});

  final Game game;

  @override
  State<GameSection> createState() => _GameSectionState();
}

class _GameSectionState extends State<GameSection> {
  late Player player;
  late Player rival;
  late int timeLeft;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    player = context.read<PlayerCubit>().state.player!;
    rival = widget.game.getRivalPlayerNumber(player).player;
    final ownPlayerNumber = widget.game.getOwnPlayerNumber(player);
    timeLeft = ownPlayerNumber.timeLeft;
    if (ownPlayerNumber.isTurn) {
      startTimer(rival);
    }
  }

  void startTimer(Player playerWinner) {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ownPlayerNumber = widget.game.getOwnPlayerNumber(player);

    if (ownPlayerNumber.isTurn && timer == null) {
      startTimer(rival);
    } else if (!ownPlayerNumber.isTurn && timer != null) {
      stopTimer();
    }

    return Padding(
      padding: context.responsiveContentPadding,
      child: Column(
        children: [
          const Gutter(),
          GameTurnWidget(ownPlayerNumber: ownPlayerNumber),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Time left: ', style: AppTextStyle().body),
              Text(
                '${(timeLeft ~/ 60).toString().padLeft(2, '0')}:${(timeLeft % 60).toString().padLeft(2, '0')}',
              ),
            ],
          ),
          const Expanded(child: _PlayList()),
          const Gutter(),
          _SendNumberSection(
            game: widget.game,
            canSendNumber: ownPlayerNumber.isTurn,
          ),
          const GutterLarge(),
        ],
      ),
    );
  }
}

class _PlayList extends StatelessWidget {
  const _PlayList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Text(
          'Previous attempts'.toUpperCase(),
          style: AppTextStyle().body.copyWith(fontWeight: FontWeight.w600),
        ),
        const GutterSmall(),
        BlocBuilder<GameCubit, GameState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.isError) {
              // log('Error');
            }
            return Column(
              children: state.listAttempts.isEmpty
                  ? [const Text('No attempts')]
                  : state.listAttempts.asMap().entries.map((entry) {
                      final index = state.listAttempts.length - entry.key;
                      final value = entry.value;
                      return PlayNumberCard(attempt: value, index: index);
                    }).toList(),
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
                      const SnackBar(
                        content: Text('Introduce a valid number'),
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
