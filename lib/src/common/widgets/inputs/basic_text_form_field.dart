import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common.dart';

class BasicTextFormField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? text;
  final bool? readOnly;
  final bool? autofocus;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextAlign? textAlign;
  final bool? showIconToClear;
  final TextInputAction? textInputAction;
  final bool? enableInteractiveSelection;
  final bool obscureText;
  final FocusNode? focusNode;
  final Color? textColor;
  final Color? backgroundColor;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final double? fontSize;
  final TextCapitalization? textCapitalization;
  final Widget? prefix;
  final Widget? suffix;
  final Function(String value)? onChanged;
  final Function()? onEditingComplete;
  final Function(String value)? onEditingCompleted;
  final Function(String value)? onFieldSubmitted;
  final String? Function(String? value)? validator;
  final String? Function(String? value)? onSaved;
  final Function()? onTap;
  final String? validatorValue;
  final EdgeInsets? padding;
  final TextAlignVertical? textAlignVertical;
  final bool? expands;
  final double? height;
  final int? minLines;
  final int? maxLines;
  final List<String>? autofillHints;

  const BasicTextFormField({
    super.key,
    this.labelText,
    this.hintText,
    this.text,
    this.readOnly,
    this.controller,
    this.keyboardType,
    this.textAlign,
    this.showIconToClear,
    this.textInputAction,
    this.enableInteractiveSelection,
    this.obscureText = false,
    this.focusNode,
    this.textColor,
    this.backgroundColor,
    this.inputFormatters,
    this.maxLength,
    this.textCapitalization,
    this.prefix,
    this.suffix,
    this.onChanged,
    this.onEditingComplete,
    this.onEditingCompleted,
    this.onFieldSubmitted,
    this.onTap,
    this.validatorValue,
    this.padding,
    this.validator,
    this.onSaved,
    this.fontSize,
    this.textAlignVertical,
    this.expands,
    this.height,
    this.minLines,
    this.maxLines,
    this.autofocus, this.autofillHints,
  });

  @override
  State<BasicTextFormField> createState() => _BasicTextFormFieldState();
}

class _BasicTextFormFieldState extends State<BasicTextFormField> {
  Timer? _checkTypingTimer;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _checkTypingTimer?.cancel();
    _focusNode.removeListener(_onFocusChange);

    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          keyboardType: widget.keyboardType,
          enableInteractiveSelection: widget.enableInteractiveSelection ?? true,
          readOnly: widget.readOnly ?? false,
          controller: widget.controller,
          obscureText: widget.obscureText,
          textInputAction: widget.textInputAction,
          textAlign: widget.textAlign ?? TextAlign.start,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines ?? 1,
          minLines: widget.minLines,
          onTap: widget.onTap,
          autofocus: widget.autofocus ?? false,
          expands: widget.expands ?? false,
          validator: widget.validator,
          autofillHints: widget.autofillHints,
          onChanged: (value) {
            resetTimer(value);
          },
          onEditingComplete: widget.onEditingComplete,
          onFieldSubmitted: widget.onFieldSubmitted,
          onSaved: widget.onSaved,
          style: TextStyle(fontSize: widget.fontSize ?? 15, color: widget.textColor, fontWeight: FontWeight.w500),
          textCapitalization: widget.textCapitalization ?? TextCapitalization.sentences,
          focusNode: widget.focusNode,
          textAlignVertical: widget.textAlignVertical,
          inputFormatters: widget.inputFormatters,
          decoration: InputDecoration(
            suffixIcon: widget.suffix,
            prefixIcon: widget.prefix,
            contentPadding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            // filled: true,
            // fillColor: widget.readOnly == true ? Colors.grey.withValues(alpha: .09) : Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.colorBluePrimary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.colorRedSecondary),
            ),
            labelText: widget.labelText,
            hintText: widget.hintText,
            counterText: "",
            labelStyle: TextStyle(color: Colors.grey, fontSize: widget.fontSize ?? 15),
            hintStyle: TextStyle(color: Colors.grey, fontSize: widget.fontSize ?? 15),
          ),
        ),
        Spacers.min,
      ],
    );
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void startTimer(String value) {
    _checkTypingTimer = Timer(const Duration(milliseconds: 300), () {
      if (widget.onChanged != null) {
        widget.onChanged!(value);
      }
    });
  }

  void resetTimer(String value) {
    _checkTypingTimer?.cancel();
    startTimer(value);
  }
}
