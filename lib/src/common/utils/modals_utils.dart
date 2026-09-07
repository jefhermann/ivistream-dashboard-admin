import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

/// Dialog sur grand écran (desktop web), bottom sheet en dessous de 700px —
/// pattern partagé par tous les modaux d'administration vidéo (série, film,
/// et les prochains : trailers, aperçus...).
WoltModalType responsiveModalType(BuildContext context) {
  return MediaQuery.of(context).size.width < 700
      ? WoltModalType.bottomSheet()
      : WoltModalType.dialog();
}