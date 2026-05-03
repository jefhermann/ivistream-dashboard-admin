import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'inputs.dart';

class BasicInput extends StatelessWidget {
  final String? hintText;
  final String? text;
  final bool? readOnly;
  final TextEditingController controller;
  final TextInputType? textInputType;
  final TextAlign? textAlign;
  final bool? nextInputForm;
  final bool? obscureText;
  final FocusNode? focusNode;
  final Color? textColor;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final VoidCallback? onTap;
  final Color? inputBackgroundColor;
  final Color? inputBorderColor;

  const BasicInput(this.controller,
      {super.key,
      this.hintText,
      this.readOnly,
      this.textInputType,
      this.textAlign,
      this.nextInputForm,
      this.text,
      this.obscureText,
      this.focusNode,
      this.textColor,
      this.inputFormatters,
      this.maxLength,
      this.onTap,
      this.inputBackgroundColor,
      this.inputBorderColor});

  @override
  Widget build(BuildContext context) {
    return InputForm(
      child: BasicTextFormField(
        controller,
        keyboardType: textInputType,
        readOnly: readOnly ?? false,
        obscureText: obscureText ?? false,
        textAlign: textAlign ?? TextAlign.start,
        maxLength: maxLength,
        focusNode: focusNode,
        hintText: hintText,
        textColor: textColor,
        onTap: onTap,
        inputFormatters: inputFormatters,
      ),
    );
  }
}
