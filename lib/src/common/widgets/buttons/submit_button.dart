import 'package:flutter/material.dart';

import '../../common.dart';
import '../widgets.dart'; // Assure-toi d'importer le fichier contenant ton nouveau BasicButton

class SubmitButton extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color? color;
  final Color? borderColor;
  final Color? iconColor;
  final VoidCallback? onTap; // 👑 FIX : Changement de 'Function?' à 'VoidCallback?'
  final bool isEnabled;
  final bool isLoading;      // ✨ NOUVEAU : Transmission de l'état de chargement
  final IconData? icon;
  final EdgeInsets? padding;
  final bool showToLeft;     // 👑 FIX : Booléen non-nullable aligné sur BasicButton
  final bool showToRight;    // 👑 FIX : Booléen non-nullable aligné sur BasicButton

  const SubmitButton({
    super.key,
    required this.text,
    this.textColor,
    this.onTap,
    this.isEnabled = true,
    this.isLoading = false,  // ✨ False par défaut
    this.color,
    this.borderColor,
    this.icon,
    this.iconColor,
    this.padding,
    this.showToLeft = false, // 👑 FIX : False par défaut
    this.showToRight = false, // 👑 FIX : False par défaut
  });

  @override
  Widget build(BuildContext context) {
    // 👑 REGLÈ DE LEAD : Si le bouton est explicitement désactivé (isEnabled == false)
    // OU s'il est en train de charger (isLoading == true), on passe 'null' à onTap.
    // Notre BasicButton se chargera de griser l'UI et de bloquer les clics nativement.
    final VoidCallback? effectiveOnTap = (isEnabled && !isLoading) ? onTap : null;

    return Row(
      children: [
        Expanded(
          child: BasicButton(
            text: text,
            borderColor: borderColor,
            icon: icon,
            padding: padding,
            iconColor: iconColor,
            showToLeft: showToLeft,
            showToRight: showToRight,
            color: color, // On laisse BasicButton gérer l'opacité grâce au onTap à null
            textColor: textColor ?? Colors.white,
            isLoading: isLoading, // ✨ On transmet l'état au composant de base
            onTap: effectiveOnTap, // 👑 Injection de l'action sécurisée
          ),
        ),
      ],
    );
  }
}