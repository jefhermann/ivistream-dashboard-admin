import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../common/common.dart';

@RoutePage()
class ContentsScreen extends StatelessWidget {
  const ContentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Gestion des Contenus', style: boldTextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text('À venir...', style: basicTextStyle(color: AppColors.colorGrayDark)),
        ],
      ),
    );
  }
}

@RoutePage()
class AdminTeamScreen extends StatelessWidget {
  const AdminTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Équipe Admin', style: boldTextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text('À venir...', style: basicTextStyle(color: AppColors.colorGrayDark)),
        ],
      ),
    );
  }
}
