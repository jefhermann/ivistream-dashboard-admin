import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../common.dart';

class PaginationWidget extends StatelessWidget {
  final PaginationModel pagination;
  final int currentPage;
  final Function(int page) onClick;

  const PaginationWidget({super.key, required this.pagination, required this.currentPage, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(onPressed: currentPage > 1 ? () => onClick(currentPage - 1) : null, icon: const Icon(LucideIcons.chevronLeft, size: 20)),
          const SizedBox(width: 8),
          Text('Page $currentPage/${pagination.totalPages}', style: mediumTextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          IconButton(onPressed: currentPage < pagination.totalPages ? () => onClick(currentPage + 1) : null, icon: const Icon(LucideIcons.chevronRight, size: 20)),
        ],
      ),
    );
  }
}
