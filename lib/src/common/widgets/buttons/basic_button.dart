import 'package:flutter/material.dart';

import '../../common.dart';

class BasicButton extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  final Color? iconColor;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double? fontSize;
  final IconData? icon;
  final bool showToLeft; // 👑 FIX : Non-nullable avec une valeur par défaut saine
  final bool showToRight; // 👑 FIX : Non-nullable avec une valeur par défaut saine
  final bool isLoading; // ✨ NOUVEAU : Gestion de l'état de chargement

  const BasicButton({
    super.key,
    required this.text,
    this.color,
    this.textColor,
    required this.onTap,
    this.borderColor,
    this.padding,
    this.fontSize,
    this.icon,
    this.iconColor,
    this.showToLeft = false, // 👑 FIX : False par défaut pour éviter le crash instantané
    this.showToRight = false, // 👑 FIX : False par défaut
    this.isLoading = false, // ✨ False par défaut
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null || isLoading;

    final Color buttonColor = isDisabled
        ? (color ?? AppColors.colorBluePrimary).withValues(alpha: 0.6)
        : (color ?? AppColors.colorBluePrimary);

    if (icon == null && (showToLeft || showToRight)) {
      throw Exception("L'icône ne peut pas être nulle si showToLeft ou showToRight est activé");
    }
    if (showToLeft && showToRight) {
      throw Exception("showToLeft et showToRight ne peuvent pas être actifs en même temps");
    }

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: buttonColor,
        border: borderColor == null ? null : Border.all(color: borderColor!),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: isDisabled
            ? null
            : [BoxShadow(color: buttonColor.withValues(alpha: .3), blurRadius: 10)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          onTap: isDisabled ? null : onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 10,
                    height:10,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor ?? Colors.white),
                    ),
                  ),
                ] else ...[
                  if (icon != null && showToLeft) ...[
                    Icon(
                      icon,
                      color: iconColor ?? Colors.white,
                      size: 10,
                    ),
                    Spacers.min,
                  ],
                  TitleText(
                    text,
                    textAlign: TextAlign.center,
                    color: textColor,
                    fontSize: fontSize,
                  ),
                  if (icon != null && showToRight) ...[
                    Spacers.min,
                    Icon(
                      icon,
                      color: iconColor ?? Colors.white,
                      size: 10,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
