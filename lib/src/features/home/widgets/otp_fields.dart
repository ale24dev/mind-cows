import 'package:flutter/material.dart';
import 'package:mind_cows/src/core/ui/typography.dart';

class OTPFields extends StatefulWidget {
  const OTPFields({
    required this.onChanged,
    super.key,
    this.length = 4,
    this.fieldWidth = 40,
    this.fieldHeight,
    this.margin = const EdgeInsets.symmetric(horizontal: 2),
    this.allowRepetitions = true,
  });

  final int length;
  final void Function(String) onChanged;
  final double fieldWidth;
  final double? fieldHeight;
  final EdgeInsets margin;
  final bool allowRepetitions;

  @override
  OTPFieldsState createState() => OTPFieldsState();
}

class OTPFieldsState extends State<OTPFields> {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;
  late List<String> otpValues;
  late List<bool> isFilled;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(widget.length, (_) => TextEditingController());
    focusNodes = List.generate(widget.length, (_) => FocusNode());
    otpValues = List.generate(widget.length, (_) => '');
    isFilled = List.generate(widget.length, (_) => false);
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    for (final node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    setState(() {
      isFilled[index] = value.isNotEmpty;
    });

    if (value.isNotEmpty && index < widget.length - 1) {
      FocusScope.of(context).requestFocus(focusNodes[index + 1]);
    }

    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(focusNodes[index - 1]);
    }

    otpValues[index] = value;
    final otp = otpValues.join();

    widget.onChanged(otp);
  }

  void clearFields() {
    // Ocultar el teclado eliminando el foco de cualquier campo de texto activo
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      for (var i = 0; i < widget.length; i++) {
        controllers[i].clear();
        otpValues[i] = '';
        isFilled[i] = false;
      }
    });

    // Llevar el foco al primer campo de texto
    // FocusScope.of(context).requestFocus(focusNodes[0]);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        return Container(
          width: widget.fieldWidth,
          height: widget.fieldHeight,
          margin: widget.margin,
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            maxLength: 1,
            style: AppTextStyle().body.copyWith(
                  fontFamily: AppTextStyle.secondaryFontFamily,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              fillColor: colorScheme.surfaceContainer,
              counterText: '',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isFilled[index] ? colorScheme.onSurface : Colors.grey,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isFilled[index] ? colorScheme.onSurface : Colors.grey,
                ),
              ),
            ),
            onChanged: (value) => _onChanged(value, index),
          ),
        );
      }),
    );
  }
}
