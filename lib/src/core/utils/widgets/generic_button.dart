import 'package:flutter/material.dart';
import 'package:mind_cows/src/core/ui/colors.dart';

class GenericButton extends StatelessWidget {
  const GenericButton({
    required this.widget,
    super.key,
    this.onPressed,
    this.style,
    this.width,
    this.color,
    this.loading = false,
  });

  final Widget widget;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final double? width;
  final Color? color;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed?.call,
        style: style ??
            ElevatedButton.styleFrom(
              backgroundColor: color ?? AppColor.primary,
            ),
        child: Container(
          child: loading ? const CircularProgressIndicator.adaptive() : widget,
        ),
      ),
    );
  }
}
