import 'package:flutter/material.dart';
import 'package:my_app/src/core/ui/typography.dart';

class BottomSnackbar extends StatelessWidget {
  const BottomSnackbar({
    this.message,
    super.key,
    this.backgroundColor,
    this.widget,
    this.height = 40,
    this.textColor = Colors.white,
  });

  final Color? backgroundColor;
  final String? message;
  final Widget? widget;
  final double? height;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: backgroundColor ?? colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Align(
          child: SizedBox(
            child: widget ??
                Text(
                  message!,
                  style: AppTextStyle().body.copyWith(
                        fontSize: 12,
                        color: textColor ?? Colors.white,
                      ),
                  textAlign: TextAlign.center,
                ),
          ),
        ),
      ),
    );
  }
}
