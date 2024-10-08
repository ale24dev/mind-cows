import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/src/core/extensions/string.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/core/utils/utils.dart';
import 'package:my_app/src/core/utils/widgets/generic_button.dart';
import 'package:my_app/src/features/home/widgets/otp_fields.dart';
import 'package:my_app/src/features/player/cubit/player_cubit.dart';
import 'package:my_app/src/features/player/data/model/player_number.dart';

class SelectSecretNumber extends HookWidget {
  const SelectSecretNumber({
    required this.onSelect,
    required this.playerNumber,
    super.key,
  });

  final VoidCallback onSelect;
  final PlayerNumber playerNumber;

  @override
  Widget build(BuildContext context) {
    final secretNumber = useState('');
    final start = useState(60);
    final timer = useRef<Timer?>(null);

    final isValidNumber = useState(false);

    void onChangedNumber(String newSecretNumber) {
      secretNumber.value = newSecretNumber;

      isValidNumber.value = Utils.isValidPlayerNumber(newSecretNumber);
      log(isValidNumber.value.toString());
    }

    void startTimer() {
      timer.value = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (start.value == 0) {
          timer.cancel();
        } else {
          start.value--;
        }
      });
    }

    useEffect(
      () {
        startTimer();
        return () {
          timer.value?.cancel();
        };
      },
      [],
    );

    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(
        context.l10n.selectSecretNumber,
        style:
            AppTextStyle().dialogTitle.copyWith(color: colorScheme.onSurface),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OTPFields(
            onChanged: onChangedNumber,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.timeRemaining(start.value),
            style: AppTextStyle().body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: start.value <= 10 ? Colors.red : colorScheme.onSurface,
                ),
          ),
          const GutterSmall(),
          Text(
            textAlign: TextAlign.center,
            context.l10n.note,
            style:
                AppTextStyle().body.copyWith(color: Colors.red, fontSize: 12),
          ),
          const GutterSmall(),
          GenericButton(
            loading: context.read<PlayerCubit>().state.isLoading,
            width: double.infinity,
            widget: Text(
              context.l10n.send,
              style: AppTextStyle().body.copyWith(color: Colors.white),
            ),
            onPressed: !isValidNumber.value
                ? null
                : () async {
                    await context.read<PlayerCubit>().updatePlayerNumber(
                          playerNumber.copyWith(
                            number: secretNumber.value.parseOptToNumberValue,
                          ),
                        );
                    onSelect();
                  },
          ),
        ],
      ),
    );
  }
}
