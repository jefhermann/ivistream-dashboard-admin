import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle basicTextStyle({Color? color, double? fontSize, FontWeight? fontWeight, TextDecoration? decoration, TextOverflow? textOverflow, FontStyle? fontStyle, double? height}) =>
    TextStyle(
        fontFamily: GoogleFonts.montserrat(fontWeight: fontWeight ?? FontWeight.w300, fontStyle: fontStyle ?? FontStyle.normal).fontFamily,
        fontSize: fontSize ?? 16,
        decoration: decoration,
        color: color ?? Colors.black,
        height: height ?? 1.3);

TextStyle boldTextStyle({Color? color, double? fontSize, TextDecoration? decoration, TextOverflow? textOverflow}) =>
    basicTextStyle(color: color, fontWeight: FontWeight.bold, fontSize: fontSize, decoration: decoration, textOverflow: textOverflow);

TextStyle mediumTextStyle({Color? color, double? fontSize, FontWeight? fontWeight, TextDecoration? decoration, double? height, TextOverflow? textOverflow}) => basicTextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w600,
      decoration: decoration,
      height: height,
      textOverflow: textOverflow,
    );
