import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common.dart';

class BasicInput extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final String? text;
  final bool? readOnly;
  final TextEditingController controller;
  final TextInputType? textInputType;
  final TextAlign? textAlign;
  final bool? nextInputForm;
  final bool? obscureText;
  final bool? showIconToClear;
  final FocusNode? focusNode;
  final Color? textColor;
  final Color? backgroundColor;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextCapitalization? textCapitalization;
  final Function(String)? onChanged;
  final Function()? onEditingComplete;
  final Function(String)? onFieldSubmitted;
  final Function(String value)? onEditingCompleted;
  final String? Function(String?)? validator;
  final String? Function(String?)? onSaved;
  final Function()? onTap;
  final Widget? suffix;
  final Widget? prefix;
  final bool? isRequired;
  final bool? enableInteractiveSelection;
  final EdgeInsets? padding;
  final TextAlignVertical? textAlignVertical;
  final int? maxLines;
  final List<String>? autofillHints;
  final TextInputAction? textInputAction;

  const BasicInput(this.controller,
      {super.key,
        this.hintText,
        this.labelText,
        this.readOnly,
        this.textInputType,
        this.textAlign,
        this.nextInputForm,
        this.text,
        this.obscureText,
        this.backgroundColor,
        this.focusNode,
        this.textColor,
        this.inputFormatters,
        this.textCapitalization,
        this.showIconToClear,
        this.onChanged,
        this.textAlignVertical,
        this.maxLength,
        this.onTap,
        this.onEditingComplete,
        this.onFieldSubmitted,
        this.onEditingCompleted,
        this.validator,
        this.suffix,
        this.prefix,
        this.isRequired,
        this.maxLines,
        this.enableInteractiveSelection,
        this.padding, this.onSaved, this.autofillHints, this.textInputAction});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: BasicTextFormField(
        keyboardType: textInputType,
        readOnly: readOnly ?? false,
        controller: controller,
        obscureText: obscureText ?? false,
        textInputAction: nextInputForm == true ? TextInputAction.next : TextInputAction.done,
        textAlign: textAlign ?? TextAlign.start,
        maxLength: maxLength,
        labelText: text,
        hintText: hintText,
        enableInteractiveSelection: enableInteractiveSelection ?? true,
        textAlignVertical: textAlignVertical,
        onTap: onTap,
        onChanged: onChanged,
        suffix: suffix,
        prefix: prefix,
        autofillHints: autofillHints,
        textCapitalization: textCapitalization ?? TextCapitalization.sentences,
        focusNode: focusNode,
        inputFormatters: inputFormatters,
        onFieldSubmitted: onFieldSubmitted,
        onSaved: onSaved,
        maxLines:maxLines,
        validator: validator ??
                (value) {
              if (isRequired == true) {
                if (value!.isEmpty || value.trim().isEmpty) {
                  return "Champs obligatoire";
                }
              }

              return null;
            },
      ),
    );
  }
}