import 'package:flutter/material.dart';

class OTPFields extends StatefulWidget {
  const OTPFields({
    required this.onCompleted,
    required this.onChanged,
    super.key,
    this.length = 4,
    this.fieldWidth = 50,
    this.fieldHeight,
    this.margin = const EdgeInsets.symmetric(horizontal: 5),
    this.borderFilledColor = Colors.black,
    this.allowRepetitions = true,
  });

  final int length;
  final Function(String) onCompleted;
  final Function(String) onChanged;
  final double fieldWidth;
  final double? fieldHeight;
  final EdgeInsets margin;
  final Color borderFilledColor;
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

    if (otp.length == widget.length) {
      if (!widget.allowRepetitions && _hasRepetitions(otpValues)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Repeated numbers are not allowed'),
          ),
        );
      } else {
        widget.onCompleted(otp);
      }
    }
  }

  bool _hasRepetitions(List<String> values) {
    final uniqueValues = values.where((e) => e.isNotEmpty).toSet();
    return uniqueValues.length != values.where((e) => e.isNotEmpty).length;
  }

  void clearFields() {
    setState(() {
      for (var i = 0; i < widget.length; i++) {
        controllers[i].clear();
        otpValues[i] = '';
        isFilled[i] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color:
                      isFilled[index] ? widget.borderFilledColor : Colors.grey,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color:
                      isFilled[index] ? widget.borderFilledColor : Colors.grey,
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