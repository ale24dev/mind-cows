import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:my_app/src/core/extensions/string.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/game/data/model/attempt.dart';
import 'package:my_app/src/features/game/data/model/game.dart';
import 'package:my_app/src/features/home/widgets/otp_fields.dart';
import 'package:my_app/src/features/home/widgets/play_number_card.dart';
import 'package:sized_context/sized_context.dart';

class GameSection extends StatelessWidget {
  const GameSection({required this.game, super.key});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Time left: ', style: AppTextStyle().body),
            const Text('30'),
          ],
        ),
        const _PlayList(),
        const Gutter(),
        _SendNumberSection(game),
      ],
    );
  }
}

class _PlayList extends StatelessWidget {
  const _PlayList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.heightPx * .6,
      child: ListView(
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
      ),
    );
  }
}

class _SendNumberSection extends StatefulWidget {
  const _SendNumberSection(this.game);

  final Game game;

  @override
  __SendNumberSectionState createState() => __SendNumberSectionState();
}

class __SendNumberSectionState extends State<_SendNumberSection> {
  final GlobalKey<OTPFieldsState> otpFieldsKey = GlobalKey<OTPFieldsState>();
  String otpValue = '';

  void _onCompleted(String otp) {
    setState(() {
      otpValue = otp;
    });
  }

  void _onChanged(String otp) {
    setState(() {
      otpValue = otp;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          onCompleted: (otpValue) {
            _onCompleted(otpValue);
          },
          onChanged: _onChanged,
        ),
        IconButton(
          onPressed: () {
            context.read<GameCubit>().insertAttempt(
                  Attempt.empty()
                      .copyWith(number: otpValue.parseOptToNumberValue),
                );
            otpFieldsKey.currentState?.clearFields();
          },
          icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }
}
