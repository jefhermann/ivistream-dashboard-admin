import 'package:flutter/material.dart';

import '../widgets.dart';

class CancelButton extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Function onTap;
  final bool isEnabled;
  final Color? color;

  const CancelButton({super.key, required this.text, this.textColor, required this.onTap, this.isEnabled = true, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BasicButton(
            text: text,
            onTap: () {
              if (isEnabled) onTap();
            },
            color: isEnabled ? color : color?.withOpacity(0.3),
            textColor: textColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}
