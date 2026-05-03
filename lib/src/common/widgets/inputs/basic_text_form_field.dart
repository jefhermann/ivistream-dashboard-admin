import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common.dart';

class BasicTextFormField extends StatelessWidget {
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
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final InputDecoration? decoration;
  final Function()? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;

  const BasicTextFormField(
    this.controller, {
    super.key,
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
    this.keyboardType,
    this.decoration,
    this.onTap,
    this.onChanged,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      keyboardType: textInputType,
      enableInteractiveSelection: true,
      readOnly: readOnly ?? false,
      controller: controller,
      obscureText: obscureText ?? false,
      textInputAction: textInputAction ?? (nextInputForm == true ? TextInputAction.next : null),
      textAlign: textAlign ?? TextAlign.start,
      maxLength: maxLength,
      style: basicTextStyle(fontSize: 20, color: textColor ?? Colors.black),
      textCapitalization: TextCapitalization.sentences,
      onFieldSubmitted: onSubmitted,
      focusNode: focusNode,
      onChanged: (value) {
        if (onChanged != null) onChanged!(value);
      },
      inputFormatters: inputFormatters,
      decoration: decoration ??
          InputDecoration(
            hintText: hintText ?? text,
            border: InputBorder.none,
            hintStyle: basicTextStyle(color: AppColors.colorGrayDark, fontSize: 20),
          ),
    );
  }
}
