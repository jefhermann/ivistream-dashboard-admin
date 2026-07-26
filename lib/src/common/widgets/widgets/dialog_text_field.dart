import 'package:flutter/material.dart';

import '../../common.dart';

class DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final String? Function(String? value)? validator;
  const DialogTextField({super.key, required this.controller, required this.label, this.maxLines = 1, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: basicTextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: basicTextStyle(fontSize: 14, color: AppColors.colorGrayDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
