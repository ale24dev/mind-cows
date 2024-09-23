import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:my_app/src/core/extensions/string.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/core/utils/utils.dart';
import 'package:my_app/src/core/utils/widgets/generic_button.dart';
import 'package:my_app/src/features/home/widgets/otp_fields.dart';
import 'package:my_app/src/features/player/cubit/player_cubit.dart';
import 'package:my_app/src/features/player/data/model/player_number.dart';

class SelectSecretNumber extends StatefulWidget {
  const SelectSecretNumber({
    required this.onSelect,
    required this.playerNumber,
    super.key,
  });

  final VoidCallback onSelect;
  final PlayerNumber playerNumber;

  @override
  State<SelectSecretNumber> createState() => _SelectSecretNumberState();
}

class _SelectSecretNumberState extends State<SelectSecretNumber> {
  String secretNumber = '';
  Timer? _timer;
  int _start = 60;

  void onChangedNumber(String secretNumber) {
    setState(() {
      this.secretNumber = secretNumber;
    });
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title:
          Text('Select your secret number', style: AppTextStyle().dialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OTPFields(
            onChanged: onChangedNumber,
          ),
          const SizedBox(height: 16),
          Text(
            'Time remaining: $_start seconds',
            style: AppTextStyle().body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _start <= 10 ? Colors.red : colorScheme.onSurface,
                ),
          ),
          const GutterSmall(),
          Text(
            textAlign: TextAlign.center,
            "Note: If you don't select a number in the time you will lose the game",
            style:
                AppTextStyle().body.copyWith(color: Colors.red, fontSize: 12),
          ),
          const GutterSmall(),
          GenericButton(
            loading: context.read<PlayerCubit>().state.isLoading,
            width: double.infinity,
            widget: Text(
              'Send',
              style: AppTextStyle().body.copyWith(color: Colors.white),
            ),
            onPressed: secretNumber.length != 4
                ? null
                : () async {
                    final isValidNumber =
                        Utils.isValidPlayerNumber(secretNumber);
                    if (!isValidNumber) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Introduce a valid number'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    await context.read<PlayerCubit>().updatePlayerNumber(
                          widget.playerNumber.copyWith(
                            number: secretNumber.parseOptToNumberValue,
                          ),
                        );
                    widget.onSelect();
                  },
          ),
        ],
      ),
    );
  }
}
