import 'package:flutter/material.dart';

class GenericTextField extends StatefulWidget {
  const GenericTextField({
    required this.labelText,
    super.key,
    this.textInputType,
    this.textInputAction = TextInputAction.next,
    this.obscureText,
    this.controller,
    this.errorText,
    this.maxLines,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.height,
    this.onChanged,
    this.enable = true,
    this.autofocus = false,
  });

  final String labelText;
  final bool enable;
  final double? height;
  final TextInputType? textInputType;
  final TextInputAction textInputAction;
  final bool? obscureText;
  final TextEditingController? controller;
  final String? errorText;
  final int? maxLines;
  final bool autofocus;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final FormFieldValidator<String>? validator;
  final Function(String)? onChanged;

  @override
  State<GenericTextField> createState() => _GenericTextFieldState();
}

class _GenericTextFieldState extends State<GenericTextField> {
  // * Flag to know if password is visible or not
  late bool showPassword;

  @override
  void initState() {
    showPassword = widget.obscureText ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const sizeWidget = 60.0;

    return SizedBox(
      height: widget.height ?? sizeWidget,
      child: widget.maxLines != null
          ? formFieldWithMaxLines(context)
          : formField(context),
    );
  }

  TextFormField formFieldWithMaxLines(BuildContext context) {
    return TextFormField(
      maxLines: widget.maxLines,
      enabled: widget.enable,
      keyboardType: widget.textInputType ?? TextInputType.text,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      obscureText: showPassword,
      controller: widget.controller,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        // fillColor: AppColor.textFieldDark,
        fillColor: Theme.of(context).cardColor,
        labelText: widget.labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText == null
            ? null
            : IconButton(
                onPressed: () {
                  setState(() {
                    showPassword = !showPassword;
                  });
                },
                icon: showPassword
                    ? const Icon(Icons.remove_red_eye)
                    : const Icon(Icons.visibility_off),
              ),
        errorText: widget.errorText,
      ),
    );
  }

  TextFormField formField(BuildContext context) {
    return TextFormField(
      // maxLines: widget.maxLines,
      enabled: widget.enable,
      keyboardType: widget.textInputType ?? TextInputType.text,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      obscureText: showPassword,
      controller: widget.controller,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        // fillColor: AppColor.textFieldDark,
        fillColor: Theme.of(context).cardColor,
        labelText: widget.labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText == null
            ? null
            : IconButton(
                onPressed: () {
                  setState(() {
                    showPassword = !showPassword;
                  });
                },
                icon: showPassword
                    ? const Icon(Icons.remove_red_eye)
                    : const Icon(Icons.visibility_off),
              ),
        errorText: widget.errorText,
      ),
    );
  }
}

extension GenericTextFieldX on GenericTextField {
  Widget requiredField() {
    return Stack(
      children: [
        this,
        const Positioned(
          top: 5,
          right: 5,
          child: Text(
            '*',
            style: TextStyle(color: Colors.red, fontSize: 22),
          ),
        ),
      ],
    );
  }
}

extension TextFieldX on TextField {
  Widget requiredField() {
    return Stack(
      children: [
        this,
        const Positioned(
          top: 5,
          right: 5,
          child: Text(
            '*',
            style: TextStyle(color: Colors.red, fontSize: 22),
          ),
        ),
      ],
    );
  }
}

extension TextFormFieldX on TextFormField {
  Widget requiredField() {
    return Stack(
      children: [
        this,
        const Positioned(
          top: 5,
          right: 5,
          child: Text(
            '*',
            style: TextStyle(color: Colors.red, fontSize: 22),
          ),
        ),
      ],
    );
  }
}
