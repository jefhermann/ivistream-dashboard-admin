import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ContentsWrapperPage extends StatelessWidget {
  const ContentsWrapperPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ce widget est crucial : il permet à l'onglet "Contenus"
    // d'avoir sa propre pile de navigation (Stack).
    return const AutoRouter();
  }
}