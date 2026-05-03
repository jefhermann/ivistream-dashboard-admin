import 'package:flutter/material.dart';

import '../common.dart';

class TitleText extends StatelessWidget {
  final String title;
  final Color? color;
  final double? fontSize;
  final TextAlign? textAlign;
  final TextOverflow? textOverflow;
  final FontWeight? fontWeight;
  final int? maxLines;

  const TitleText(this.title, {super.key, this.color, this.fontSize, this.textAlign, this.textOverflow, this.maxLines, this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      style: boldTextStyle(
        color: color,
        decoration: TextDecoration.none,
        fontSize: fontSize,
      ),
    );
  }
}
