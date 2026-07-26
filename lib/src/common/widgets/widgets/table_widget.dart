import 'package:flutter/material.dart';

import '../../common.dart';

class TableColumn<T> {
  final String label;
  final int flex;
  final Alignment alignment;
  final Widget Function(T item) cell;

  const TableColumn({
    required this.label,
    required this.cell,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
  });
}

// 2. Le widget devient générique sur le type de donnée T
class TableWidget<T> extends StatelessWidget {
  final List<TableColumn<T>> columns;
  final List<T> items;
  final PaginationModel pagination;
  final int currentPage;
  final Function(int page) goToPage;
  final Widget Function(T item)? actionBuilder;
  final Function(T item)? onRowTap;
  final bool showActions;
  final bool showPagination;
  final double minWidth; // largeur en-dessous de laquelle on scrolle
  final double actionWidth; // largeur fixe de la colonne Actions

  const TableWidget({
    super.key,
    required this.columns,
    required this.items,
    required this.pagination,
    required this.currentPage,
    required this.goToPage,
    this.actionBuilder,
    this.onRowTap,
    this.showActions = true,
    this.minWidth = 800,
    this.actionWidth = 120, this.showPagination = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Zone scrollable (header + rows) ---
          LayoutBuilder(
            builder: (context, constraints) {
              final needsScroll = constraints.maxWidth < minWidth;
              final tableWidth = needsScroll ? minWidth : constraints.maxWidth;

              // SizedBox borne la largeur -> Expanded fonctionne dans les 2 cas
              final table = SizedBox(
                width: tableWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    ..._buildRows(),
                  ],
                ),
              );

              return needsScroll
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: table,
                    )
                  : table;
            },
          ),
          // --- Pagination hors du scroll horizontal, reste fixe ---
          Visibility(
            visible: showPagination,
            child: PaginationWidget(
              pagination: pagination,
              currentPage: currentPage,
              onClick: goToPage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          ...columns.map(
            (col) => Expanded(
              flex: col.flex,
              child: Align(
                alignment: col.alignment,
                child: Text(
                  col.label,
                  style: mediumTextStyle(
                    fontSize: 13,
                    color: AppColors.colorGrayDark,
                  ),
                ),
              ),
            ),
          ),
          if (showActions)
            SizedBox(
              width: actionWidth,
              child: Text(
                'Actions',
                style: mediumTextStyle(
                  fontSize: 13,
                  color: AppColors.colorGrayDark,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildRows() {
    if (items.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: Text('Aucune donnée')),
        ),
      ];
    }
    return items.map(_buildRow).toList();
  }

  Widget _buildRow(T item) {
    return InkWell(
      onTap: onRowTap == null ? null : () => onRowTap!(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            ...columns.map(
              (col) => Expanded(
                flex: col.flex,
                child: Align(
                  alignment: col.alignment,
                  child: col.cell(item),
                ),
              ),
            ),
            if (showActions)
              SizedBox(
                width: actionWidth,
                child: actionBuilder?.call(item) ?? const SizedBox(),
              ),
          ],
        ),
      ),
    );
  }
}
