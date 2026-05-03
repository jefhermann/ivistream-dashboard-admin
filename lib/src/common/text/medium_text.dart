import 'package:flutter/material.dart';

import '../common.dart';

class MediumText extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final int? maxLines;
  final TextAlign? textAlign;

  const MediumText(this.text, {super.key, this.color, this.fontSize, this.textAlign, this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines ?? 1,
      textAlign: textAlign ?? TextAlign.start,
      style: mediumTextStyle(
        color: color ?? Colors.black,
        decoration: TextDecoration.none,
        fontWeight: FontWeight.w300,
        fontSize: fontSize,
      ),
    );
  }
}
