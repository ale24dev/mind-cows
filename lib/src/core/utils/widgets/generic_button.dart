import 'package:flutter/material.dart';
import 'package:my_app/src/core/constants.dart';
import 'package:my_app/src/core/ui/colors.dart';

class GenericButton extends StatelessWidget {
  const GenericButton({
    required this.widget, super.key,
     this.onPressed,
    this.style,
    this.width,
    this.color,
  });

  final Widget widget;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final double? width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Constants.BUTTON_HEIGHT,
      width: width,
      child: ElevatedButton(
          onPressed: onPressed?.call,
          style: style ??
              ElevatedButton.styleFrom(
                backgroundColor: color ?? AppColor.primary,
              ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(8),
            child: widget,
          ),),
    );
  }
}
