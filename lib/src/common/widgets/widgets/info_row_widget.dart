import 'package:flutter/material.dart';

import '../../common.dart';

class InfoRowWidget extends StatelessWidget {
  final String label;
  final String value;

  const InfoRowWidget(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: basicTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
          Expanded(child: Text(value, style: mediumTextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}