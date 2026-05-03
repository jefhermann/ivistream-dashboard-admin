import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import 'inputs.dart';

class PasswordInputForm extends StatefulWidget {
  final bool readOnly;
  final bool nextInputForm;
  final TextInputType textInputType;
  final TextInputAction? textInputAction;
  final TextEditingController controller;
  final String hintText;
  final FocusNode? focusNode;
  final Function(String)? onSubmitted;

  const PasswordInputForm(
      {super.key,
      this.readOnly = false,
      required this.controller,
      this.focusNode,
      this.nextInputForm = false,
      this.textInputType = TextInputType.text,
      required this.hintText,
      this.textInputAction,
      this.onSubmitted});

  @override
  State<PasswordInputForm> createState() => _PasswordInputFormState();
}

class _PasswordInputFormState extends State<PasswordInputForm> {
  IconData _iconPassword = FluentIcons.eye_off_16_regular;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return InputForm(
      child: Row(
        children: [
          Expanded(
              child: BasicTextFormField(widget.controller,
                  hintText: widget.hintText,
                  readOnly: widget.readOnly,
                  nextInputForm: widget.nextInputForm,
                  textInputType: TextInputType.text,
                  obscureText: _obscurePassword,
                  focusNode: widget.focusNode,
                  onSubmitted: widget.onSubmitted,
                  textInputAction: widget.textInputAction)),
          const SizedBox(width: 10),
          InkWell(
              onTap: () {
                _obscurePassword = !_obscurePassword;
                if (_obscurePassword) {
                  _iconPassword = FluentIcons.eye_off_16_regular;
                } else {
                  _iconPassword = FluentIcons.eye_16_regular;
                }
                setState(() {});
              },
              child: Icon(_iconPassword, color: Colors.black)),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
