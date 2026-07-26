import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ivistream_dashboard_admin/src/config/app_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../common/common.dart';
import '../../contents.dart';

@RoutePage()
class ContentsScreen extends ConsumerStatefulWidget {
  const ContentsScreen({super.key});

  @override
  ConsumerState<ContentsScreen> createState() => _ContentsScreenState();
}

class _ContentsScreenState extends ConsumerState<ContentsScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadContents());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _loadContents() {
    final f = ref.read(contentsFilterProvider);
    ref.read(contentsListProvider.notifier).loadContents(page: f.page, search: f.search, status: f.status, type: f.type);
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(contentsFilterProvider.notifier).state = ref.read(contentsFilterProvider).copyWith(search: value.isEmpty ? null : value, page: 1, clearSearch: value.isEmpty);
      _loadContents();
    });
  }

  void _onStatusFilter(String? val) {
    ref.read(contentsFilterProvider.notifier).state = ref.read(contentsFilterProvider).copyWith(status: val, page: 1, clearStatus: val == null);
    _loadContents();
  }

  void _onTypeFilter(String? val) {
    ref.read(contentsFilterProvider.notifier).state = ref.read(contentsFilterProvider).copyWith(type: val, page: 1, clearType: val == null);
    _loadContents();
  }

  void _goToPage(int page) {
    ref.read(contentsFilterProvider.notifier).state = ref.read(contentsFilterProvider).copyWith(page: page);
    _loadContents();
  }

  void _gotToDetails(AdminContentModel c) {
    context.router.push(ContentDetailRoute(contentId: c.id ?? ""));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contentsListProvider);
    final filters = ref.watch(contentsFilterProvider);
    final isMobile = ResponsiveLayout.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Contenus', style: boldTextStyle(fontSize: isMobile ? 22 : 28)),
                    const SizedBox(height: 4),
                    Text(
                      state.pagination != null ? '${state.pagination!.total} contenus au total' : 'Chargement...',
                      style: basicTextStyle(color: AppColors.colorGrayDark),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showCreateDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.colorBluePrimary,
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
                label: Text(isMobile ? 'Ajouter' : 'Nouveau contenu', style: mediumTextStyle(fontSize: 14, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFilters(filters, isMobile),
          const SizedBox(height: 16),
          _buildList(state, isMobile),
          if (state.pagination != null && state.pagination!.totalPages > 1) ...[
            const SizedBox(height: 16),
            _buildPagination(state.pagination!, filters.page),
          ],
        ],
      ),
    );
  }

  Widget _buildFilters(ContentsFilterState filters, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: isMobile ? double.infinity : 280,
            height: 44,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: basicTextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Rechercher par titre...',
                hintStyle: basicTextStyle(color: AppColors.colorGrayDark, fontSize: 14),
                prefixIcon: const Icon(LucideIcons.search, size: 18),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          _FilterChip(
              label: 'Statut',
              value: filters.status,
              options: const {'draft': 'Brouillon', 'published': 'Publié', 'archived': 'Archivé', 'processing': 'En cours'},
              onChanged: _onStatusFilter),
          _FilterChip(
              label: 'Type',
              value: filters.type,
              options: const {'movie': 'Film', 'series': 'Série', 'documentary': 'Documentaire', 'short': 'Court-métrage'},
              onChanged: _onTypeFilter),
          if (filters.search != null || filters.status != null || filters.type != null)
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                ref.read(contentsFilterProvider.notifier).state = ContentsFilterState();
                _loadContents();
              },
              icon: const Icon(LucideIcons.x, size: 16),
              label: Text('Effacer', style: basicTextStyle(fontSize: 13, color: AppColors.colorRedSecondary)),
            ),
        ],
      ),
    );
  }

  Widget _buildList(ContentsListState state, bool isMobile) {
    if (state.isLoading) return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
    if (state.error != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.colorRedSecondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(LucideIcons.badgeAlert, color: AppColors.colorRedSecondary, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(state.error!, style: basicTextStyle(color: AppColors.colorRedSecondary, fontSize: 13))),
          TextButton(onPressed: _loadContents, child: Text('Réessayer', style: mediumTextStyle(fontSize: 13, color: AppColors.colorBluePrimary))),
        ]),
      );
    }
    if (state.contents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
        child: Center(
            child: Column(children: [
          const Icon(LucideIcons.clapperboard, size: 40, color: AppColors.colorGrayDark),
          const SizedBox(height: 12),
          Text('Aucun contenu trouvé', style: mediumTextStyle(color: AppColors.colorGrayDark)),
        ])),
      );
    }

    if (isMobile) {
      return Column(children: state.contents.map((c) => _ContentCard(content: c, onTap: () => _showDetail(c), onAction: (a) => _onAction(c, a))).toList());
    }
    return _ContentsTable(contents: state.contents, onTap: _showDetail, onAction: _onAction);
  }

  void _onAction(AdminContentModel content, String action) async {
    switch (action) {
      case 'publish':
        final confirmed = await _confirm('Publier "${content.title}" ?', 'Le contenu sera visible par les utilisateurs.');
        if (confirmed) {
          if (content.id == null) break;
          final ok = await ref.read(contentsListProvider.notifier).publishContent(content.id!);
          _snack(ok ? 'Contenu publié' : 'Erreur', ok);
          if (ok) _loadContents();
        }
        break;
      case 'archive':
        final confirmed = await _confirm('Archiver "${content.title}" ?', 'Le contenu ne sera plus visible.');
        if (confirmed) {
          if (content.id == null) break;
          final ok = await ref.read(contentsListProvider.notifier).archiveContent(content.id!);
          _snack(ok == true ? 'Contenu archivé' : 'Erreur', ok!);
          if (ok) _loadContents();
        }
        break;
    }
  }

  void _showDetail(AdminContentModel content) {
    // if(content.id != null) showDialog(context: context, builder: (ctx) => _ContentDetailDialog(contentId: content.id!));
    _gotToDetails(content);
  }

  void _showCreateDialog() {
    context.router.push(const AddContentRoute());
  }

  Future<bool> _confirm(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: TitleText(title, fontSize: 18),
            content: MediumText(message, fontSize: 14),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const MediumText('Annuler', fontSize: 14)),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.colorBluePrimary),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const MediumText('Confirmer', fontSize: 14, color: Colors.white)),
            ],
          ),
        ) ??
        false;
  }

  void _snack(String msg, bool success) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: MediumText(msg, color: Colors.white), backgroundColor: success ? Colors.green : Colors.red));
  }

  Widget _buildPagination(PaginationModel pagination, int currentPage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(onPressed: currentPage > 1 ? () => _goToPage(currentPage - 1) : null, icon: const Icon(LucideIcons.chevronLeft, size: 20)),
          const SizedBox(width: 8),
          Text('Page $currentPage/${pagination.totalPages}', style: mediumTextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          IconButton(onPressed: currentPage < pagination.totalPages ? () => _goToPage(currentPage + 1) : null, icon: const Icon(LucideIcons.chevronRight, size: 20)),
        ],
      ),
    );
  }
}

// ============================================================
// Contents Table (Desktop)
// ============================================================

class _ContentsTable extends StatelessWidget {
  final List<AdminContentModel> contents;
  final Function(AdminContentModel) onTap;
  final Function(AdminContentModel, String) onAction;

  const _ContentsTable({required this.contents, required this.onTap, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
            child: Row(children: [
              Expanded(flex: 4, child: Text('Contenu', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
              Expanded(flex: 2, child: Text('Type', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
              Expanded(flex: 2, child: Text('Statut', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
              Expanded(flex: 2, child: Text('Accès', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
              Expanded(flex: 2, child: Text('Date', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
              const SizedBox(width: 100, child: Text('Actions', style: TextStyle(fontSize: 13))),
            ]),
          ),
          ...contents.map((c) => InkWell(
                onTap: () => onTap(c),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
                  child: Row(children: [
                    Expanded(
                      flex: 4,
                      child: Row(children: [
                        Container(
                          width: 40,
                          height: 54,
                          decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                          child: c.posterUrl != null
                              ? ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network(c.posterUrl!, fit: BoxFit.cover))
                              : const Icon(LucideIcons.clapperboard, color: Color(0xFFF59E0B), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(c.title ?? "", style: mediumTextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                          Text(c.producerName, style: basicTextStyle(fontSize: 12, color: AppColors.colorGrayDark)),
                        ])),
                      ]),
                    ),
                    Expanded(flex: 2, child: Text(c.typeLabel, style: basicTextStyle(fontSize: 13))),
                    Expanded(flex: 2, child: _StatusBadge(label: c.statusLabel, color: _statusColor(c.status ?? "-"))),
                    Expanded(flex: 2, child: _StatusBadge(label: c.accessLabel, color: c.access == 'premium' ? const Color(0xFF8B5CF6) : const Color(0xFF10B981))),
                    Expanded(
                        flex: 2, child: Text(c.createdAt?.isNotEmpty == true ? dateFormat.format(DateTime.parse(c.createdAt ?? "-")) : '-', style: basicTextStyle(fontSize: 13))),
                    SizedBox(
                      width: 100,
                      child: Row(children: [
                        if (c.status == 'draft' || c.status == 'archived')
                          Tooltip(
                              message: 'Publier',
                              child: IconButton(onPressed: () => onAction(c, 'publish'), icon: const Icon(LucideIcons.send, size: 18, color: Color(0xFF10B981)))),
                        if (c.status == 'published')
                          Tooltip(
                              message: 'Archiver',
                              child: IconButton(onPressed: () => onAction(c, 'archive'), icon: const Icon(LucideIcons.archive, size: 18, color: AppColors.colorRedSecondary))),
                      ]),
                    ),
                  ]),
                ),
              )),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'published':
        return const Color(0xFF10B981);
      case 'draft':
        return const Color(0xFFF59E0B);
      case 'archived':
        return AppColors.colorGrayDark;
      case 'processing':
        return AppColors.colorBluePrimary;
      default:
        return AppColors.colorGrayDark;
    }
  }
}

// ============================================================
// Content Card (Mobile)
// ============================================================

class _ContentCard extends StatelessWidget {
  final AdminContentModel content;
  final VoidCallback onTap;
  final Function(String) onAction;

  const _ContentCard({required this.content, required this.onTap, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
          child: Row(children: [
            Container(
              width: 44,
              height: 60,
              decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(LucideIcons.clapperboard, color: Color(0xFFF59E0B), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(content.title ?? "", style: mediumTextStyle(fontSize: 15), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('${content.typeLabel} • ${content.producerName}', style: basicTextStyle(fontSize: 12, color: AppColors.colorGrayDark)),
              const SizedBox(height: 6),
              Row(children: [
                _StatusBadge(label: content.statusLabel, color: content.status == 'published' ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
                const SizedBox(width: 6),
                _StatusBadge(label: content.accessLabel, color: content.access == 'premium' ? const Color(0xFF8B5CF6) : const Color(0xFF10B981)),
              ]),
            ])),
            PopupMenuButton<String>(
              onSelected: onAction,
              itemBuilder: (ctx) => [
                if (content.status == 'draft') const PopupMenuItem(value: 'publish', child: Text('Publier')),
                if (content.status == 'published') const PopupMenuItem(value: 'archive', child: Text('Archiver')),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

// ============================================================
// Shared Widgets
// ============================================================

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: mediumTextStyle(fontSize: 12, color: color)),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String? value;
  final Map<String, String> options;
  final Function(String?) onChanged;

  const _FilterChip({required this.label, required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      onSelected: (val) => onChanged(val == value ? null : val),
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (ctx) => options.entries
          .map((e) => PopupMenuItem<String?>(
                value: e.key,
                child: Row(children: [
                  if (e.key == value) const Icon(LucideIcons.check, size: 16, color: AppColors.colorBluePrimary) else const SizedBox(width: 16),
                  const SizedBox(width: 8),
                  Text(e.value, style: basicTextStyle(fontSize: 14)),
                ]),
              ))
          .toList(),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: value != null ? AppColors.colorBluePrimary.withValues(alpha: 0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: value != null ? AppColors.colorBluePrimary.withValues(alpha: 0.3) : Colors.grey.shade300),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(value != null ? options[value] ?? label : label, style: basicTextStyle(fontSize: 14, color: value != null ? AppColors.colorBluePrimary : AppColors.colorGrayDark)),
          const SizedBox(width: 6),
          Icon(LucideIcons.chevronDown, size: 16, color: value != null ? AppColors.colorBluePrimary : AppColors.colorGrayDark),
        ]),
      ),
    );
  }
}
