import 'package:flutter/material.dart';

import '../common.dart';

class BodyText extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final TextAlign? textAlign;
  final TextOverflow? textOverflow;
  final int? maxLines;

  const BodyText(this.text, {super.key, this.color, this.fontSize, this.textAlign, this.textOverflow, this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign ?? TextAlign.start,
      overflow: textOverflow,
      maxLines: maxLines,
      style: basicTextStyle(
        color: color,
        decoration: TextDecoration.none,
        fontSize: fontSize,
      ),
    );
  }
}
