import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/home/widgets/otp_fields.dart';
import 'package:my_app/src/features/home/widgets/play_number_card.dart';
import 'package:sized_context/sized_context.dart';

class GameSection extends StatelessWidget {
  const GameSection({
    super.key,
  });

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
        const _SendNumberSection(),
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
                log('Error');
              }
              return Column(
                children: state.listAttempts.isEmpty
                    ? [const Text('No attempts')]
                    : state.listAttempts.asMap().entries.map((entry) {
                        final index = entry.key + 1;
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
  const _SendNumberSection();

  @override
  __SendNumberSectionState createState() => __SendNumberSectionState();
}

class __SendNumberSectionState extends State<_SendNumberSection> {
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
        ///This is to center the OTPFields
        const IconButton(
          onPressed: null,
          icon: Icon(Icons.send, color: Colors.transparent),
        ),
        OTPFields(
          allowRepetitions: false,
          onCompleted: _onCompleted,
          onChanged: _onChanged,
        ),
        IconButton(
          onPressed: () {
            log('OTP enviado: $otpValue');
          },
          icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }
}
