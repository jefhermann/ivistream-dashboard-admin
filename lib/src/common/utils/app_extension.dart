import 'package:flutter/material.dart';

import '../common.dart';

class AppExtension {
  static Future<DateTime?> selectYear(BuildContext context, {DateTime? currentSelectedDate}) async {
    final DateTime now = DateTime.now();

    return await showDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(15),
          ),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(now.year - 100, 1),
              lastDate: DateTime.now(),
              selectedDate: currentSelectedDate ?? now,
              onChanged: (DateTime value) {
                Navigator.pop(dialogContext, value);
              },
            ),
          ),
        );
      },
    );
  }


  static Future<DateTime?> selectDate(BuildContext context, {DateTime? currentSelectedDate}) async {

    var date = await showDatePicker(context: context, firstDate: DateTime(DateTime.now().year - 300), lastDate: DateTime(DateTime.now().year + 300), initialDate: currentSelectedDate ?? DateTime.now());

    return date;
  }

  static void snack(BuildContext context ,String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: MediumText(msg, color: Colors.white), backgroundColor: success ? Colors.green : Colors.red));
  }
}