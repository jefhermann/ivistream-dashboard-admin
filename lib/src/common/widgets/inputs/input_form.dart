import 'package:flutter/material.dart';

import '../../common.dart';

class InputForm extends StatelessWidget {
  const InputForm({
    super.key,
    required this.child,
    this.borderColor,
    this.backgroundColor,
  });

  final Widget child;
  final Color? borderColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 55,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            border: Border.all(color: borderColor ?? AppColors.backgroundBodyColor.withValues(alpha: .3)),
          ),
          padding: const EdgeInsets.only(top: 2, left: 16, right: 16),
          child: child,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
