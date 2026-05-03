import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../common/common.dart';
import '../../users.dart';

@RoutePage()
class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadUsers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _loadUsers() {
    final filters = ref.read(usersFilterProvider);
    ref.read(usersListProvider.notifier).loadUsers(
          page: filters.page,
          search: filters.search,
          status: filters.status,
          trialStatus: filters.trialStatus,
        );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(usersFilterProvider.notifier).state =
          ref.read(usersFilterProvider).copyWith(search: value.isEmpty ? null : value, page: 1, clearSearch: value.isEmpty);
      _loadUsers();
    });
  }

  void _onStatusFilter(String? status) {
    ref.read(usersFilterProvider.notifier).state =
        ref.read(usersFilterProvider).copyWith(status: status, page: 1, clearStatus: status == null);
    _loadUsers();
  }

  void _onTrialFilter(String? trial) {
    ref.read(usersFilterProvider.notifier).state =
        ref.read(usersFilterProvider).copyWith(trialStatus: trial, page: 1, clearTrialStatus: trial == null);
    _loadUsers();
  }

  void _goToPage(int page) {
    ref.read(usersFilterProvider.notifier).state =
        ref.read(usersFilterProvider).copyWith(page: page);
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(usersListProvider);
    final filters = ref.watch(usersFilterProvider);
    final isMobile = ResponsiveLayout.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Utilisateurs', style: boldTextStyle(fontSize: isMobile ? 22 : 28)),
                    const SizedBox(height: 4),
                    Text(
                      usersState.pagination != null
                          ? '${usersState.pagination!.total} utilisateurs au total'
                          : 'Chargement...',
                      style: basicTextStyle(color: AppColors.colorGrayDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search + Filters
          _buildFilters(filters, isMobile),
          const SizedBox(height: 16),

          // Table / List
          _buildUsersList(usersState, isMobile),

          // Pagination
          if (usersState.pagination != null && usersState.pagination!.totalPages > 1) ...[
            const SizedBox(height: 16),
            _buildPagination(usersState.pagination!, filters.page),
          ],
        ],
      ),
    );
  }

  Widget _buildFilters(UsersFilterState filters, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search
          SizedBox(
            width: isMobile ? double.infinity : 280,
            height: 44,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: basicTextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Rechercher par nom ou email...',
                hintStyle: basicTextStyle(color: AppColors.colorGrayDark, fontSize: 14),
                prefixIcon: const Icon(LucideIcons.search, size: 18),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),

          // Status filter
          _FilterChip(
            label: 'Statut',
            value: filters.status,
            options: const {'active': 'Actif', 'inactive': 'Inactif'},
            onChanged: _onStatusFilter,
          ),

          // Trial filter
          _FilterChip(
            label: 'Essai',
            value: filters.trialStatus,
            options: const {
              'available': 'Disponible',
              'active': 'En cours',
              'expired': 'Expiré',
              'converted': 'Converti',
            },
            onChanged: _onTrialFilter,
          ),

          // Clear filters
          if (filters.search != null || filters.status != null || filters.trialStatus != null)
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                ref.read(usersFilterProvider.notifier).state = UsersFilterState();
                _loadUsers();
              },
              icon: const Icon(LucideIcons.x, size: 16),
              label: Text('Effacer', style: basicTextStyle(fontSize: 13, color: AppColors.colorRedSecondary)),
            ),
        ],
      ),
    );
  }

  Widget _buildUsersList(UsersListState usersState, bool isMobile) {
    if (usersState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (usersState.error != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.colorRedSecondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.badgeAlert, color: AppColors.colorRedSecondary, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(usersState.error!, style: basicTextStyle(color: AppColors.colorRedSecondary, fontSize: 13))),
            TextButton(
              onPressed: _loadUsers,
              child: Text('Réessayer', style: mediumTextStyle(fontSize: 13, color: AppColors.colorBluePrimary)),
            ),
          ],
        ),
      );
    }

    if (usersState.users.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(LucideIcons.userX, size: 40, color: AppColors.colorGrayDark),
              const SizedBox(height: 12),
              Text('Aucun utilisateur trouvé', style: mediumTextStyle(color: AppColors.colorGrayDark)),
            ],
          ),
        ),
      );
    }

    if (isMobile) {
      return Column(
        children: usersState.users.map((user) => _UserCard(user: user, onAction: _onUserAction)).toList(),
      );
    }

    return _UsersTable(users: usersState.users, onAction: _onUserAction);
  }

  void _onUserAction(AdminUserModel user, String action) async {
    switch (action) {
      case 'detail':
        _showUserDetail(user);
        break;
      case 'toggle_status':
        final confirmed = await _showConfirmDialog(
          user.isActive ? 'Désactiver ${user.fullName ?? user.email} ?' : 'Activer ${user.fullName ?? user.email} ?',
          user.isActive ? 'L\'utilisateur ne pourra plus se connecter.' : 'L\'utilisateur pourra se reconnecter.',
        );
        if (confirmed) {
          final success = await ref.read(usersListProvider.notifier).toggleUserStatus(user.id, !user.isActive);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: MediumText(
                success ? (user.isActive ? 'Utilisateur désactivé' : 'Utilisateur activé') : 'Erreur',
                color: Colors.white,
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            ));
          }
        }
        break;
      case 'extend_trial':
        _showExtendTrialDialog(user);
        break;
    }
  }

  void _showUserDetail(AdminUserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => _UserDetailDialog(userId: user.id),
    );
  }

  void _showExtendTrialDialog(AdminUserModel user) {
    final daysController = TextEditingController(text: '7');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const TitleText('Prolonger l\'essai', fontSize: 18),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MediumText('Pour ${user.fullName ?? user.email}', fontSize: 14),
            const SizedBox(height: 16),
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              style: basicTextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Nombre de jours',
                labelStyle: basicTextStyle(fontSize: 14, color: AppColors.colorGrayDark),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const MediumText('Annuler', fontSize: 14),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.colorBluePrimary),
            onPressed: () async {
              final days = int.tryParse(daysController.text) ?? 0;
              if (days < 1) return;
              Navigator.pop(ctx);

              final success = await ref.read(usersListProvider.notifier).extendTrial(user.id, days);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: MediumText(
                    success ? 'Essai prolongé de $days jours' : 'Erreur',
                    color: Colors.white,
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ));
                if (success) _loadUsers(); // Refresh
              }
            },
            child: const MediumText('Prolonger', fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: TitleText(title, fontSize: 18),
            content: MediumText(message, fontSize: 14),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const MediumText('Annuler', fontSize: 14),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.colorRedSecondary),
                onPressed: () => Navigator.pop(ctx, true),
                child: const MediumText('Confirmer', fontSize: 14, color: Colors.white),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildPagination(PaginationModel pagination, int currentPage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: currentPage > 1 ? () => _goToPage(currentPage - 1) : null,
            icon: const Icon(LucideIcons.chevronLeft, size: 20),
          ),
          const SizedBox(width: 8),
          ...List.generate(
            pagination.totalPages > 5 ? 5 : pagination.totalPages,
            (index) {
              int pageNum;
              if (pagination.totalPages <= 5) {
                pageNum = index + 1;
              } else if (currentPage <= 3) {
                pageNum = index + 1;
              } else if (currentPage >= pagination.totalPages - 2) {
                pageNum = pagination.totalPages - 4 + index;
              } else {
                pageNum = currentPage - 2 + index;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  onTap: () => _goToPage(pageNum),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: pageNum == currentPage ? AppColors.colorBluePrimary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$pageNum',
                      style: mediumTextStyle(
                        fontSize: 14,
                        color: pageNum == currentPage ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: currentPage < pagination.totalPages ? () => _goToPage(currentPage + 1) : null,
            icon: const Icon(LucideIcons.chevronRight, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            'Page $currentPage/${pagination.totalPages}',
            style: basicTextStyle(fontSize: 13, color: AppColors.colorGrayDark),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Filter Chip
// ============================================================

class _FilterChip extends StatelessWidget {
  final String label;
  final String? value;
  final Map<String, String> options;
  final Function(String?) onChanged;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      onSelected: (val) => onChanged(val == value ? null : val),
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (ctx) => [
        ...options.entries.map((entry) => PopupMenuItem<String?>(
              value: entry.key,
              child: Row(
                children: [
                  if (entry.key == value)
                    Icon(LucideIcons.check, size: 16, color: AppColors.colorBluePrimary)
                  else
                    const SizedBox(width: 16),
                  const SizedBox(width: 8),
                  Text(entry.value, style: basicTextStyle(fontSize: 14)),
                ],
              ),
            )),
      ],
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: value != null ? AppColors.colorBluePrimary.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value != null ? AppColors.colorBluePrimary.withOpacity(0.3) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value != null ? options[value] ?? label : label,
              style: basicTextStyle(
                fontSize: 14,
                color: value != null ? AppColors.colorBluePrimary : AppColors.colorGrayDark,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              LucideIcons.chevronDown,
              size: 16,
              color: value != null ? AppColors.colorBluePrimary : AppColors.colorGrayDark,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Users Table (Desktop)
// ============================================================

class _UsersTable extends StatelessWidget {
  final List<AdminUserModel> users;
  final Function(AdminUserModel, String) onAction;

  const _UsersTable({required this.users, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('Utilisateur', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
                Expanded(flex: 2, child: Text('Statut', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
                Expanded(flex: 2, child: Text('Essai', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
                Expanded(flex: 2, child: Text('Inscrit le', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
                const SizedBox(width: 100, child: Text('Actions', style: TextStyle(fontSize: 13))),
              ],
            ),
          ),
          // Rows
          ...users.map((user) => _UserRow(user: user, dateFormat: dateFormat, onAction: onAction)),
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final AdminUserModel user;
  final DateFormat dateFormat;
  final Function(AdminUserModel, String) onAction;

  const _UserRow({required this.user, required this.dateFormat, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onAction(user, 'detail'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            // User info
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.colorBluePrimary.withOpacity(0.1),
                    child: Text(
                      ((user.fullName ?? user.email)[0]).toUpperCase(),
                      style: boldTextStyle(color: AppColors.colorBluePrimary, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.fullName ?? 'Sans nom', style: mediumTextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                        Text(user.email, style: basicTextStyle(fontSize: 12, color: AppColors.colorGrayDark), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Status
            Expanded(
              flex: 2,
              child: _StatusBadge(
                label: user.isActive ? 'Actif' : 'Inactif',
                color: user.isActive ? const Color(0xFF10B981) : AppColors.colorRedSecondary,
              ),
            ),

            // Trial
            Expanded(
              flex: 2,
              child: _StatusBadge(
                label: user.trialStatusLabel,
                color: _trialColor(user.trialStatus),
              ),
            ),

            // Date
            Expanded(
              flex: 2,
              child: Text(
                user.createdAt.isNotEmpty ? dateFormat.format(DateTime.parse(user.createdAt)) : '-',
                style: basicTextStyle(fontSize: 13),
              ),
            ),

            // Actions
            SizedBox(
              width: 100,
              child: Row(
                children: [
                  Tooltip(
                    message: user.isActive ? 'Désactiver' : 'Activer',
                    child: IconButton(
                      onPressed: () => onAction(user, 'toggle_status'),
                      icon: Icon(
                        user.isActive ? LucideIcons.userX : LucideIcons.userCheck,
                        size: 18,
                        color: user.isActive ? AppColors.colorRedSecondary : const Color(0xFF10B981),
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Prolonger essai',
                    child: IconButton(
                      onPressed: () => onAction(user, 'extend_trial'),
                      icon: Icon(LucideIcons.clock, size: 18, color: AppColors.colorBluePrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _trialColor(String? status) {
    switch (status) {
      case 'active':
        return const Color(0xFF10B981);
      case 'expired':
        return AppColors.colorRedSecondary;
      case 'converted':
        return AppColors.colorBluePrimary;
      default:
        return AppColors.colorGrayDark;
    }
  }
}

// ============================================================
// User Card (Mobile)
// ============================================================

class _UserCard extends StatelessWidget {
  final AdminUserModel user;
  final Function(AdminUserModel, String) onAction;

  const _UserCard({required this.user, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => onAction(user, 'detail'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.colorBluePrimary.withOpacity(0.1),
                  child: Text(
                    ((user.fullName ?? user.email)[0]).toUpperCase(),
                    style: boldTextStyle(color: AppColors.colorBluePrimary, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName ?? 'Sans nom', style: mediumTextStyle(fontSize: 15)),
                      Text(user.email, style: basicTextStyle(fontSize: 13, color: AppColors.colorGrayDark)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (action) => onAction(user, action),
                  itemBuilder: (ctx) => [
                    PopupMenuItem(value: 'detail', child: Row(children: [Icon(LucideIcons.eye, size: 16), const SizedBox(width: 8), Text('Détail', style: basicTextStyle(fontSize: 14))])),
                    PopupMenuItem(value: 'toggle_status', child: Row(children: [Icon(user.isActive ? LucideIcons.userX : LucideIcons.userCheck, size: 16), const SizedBox(width: 8), Text(user.isActive ? 'Désactiver' : 'Activer', style: basicTextStyle(fontSize: 14))])),
                    PopupMenuItem(value: 'extend_trial', child: Row(children: [Icon(LucideIcons.clock, size: 16), const SizedBox(width: 8), Text('Prolonger essai', style: basicTextStyle(fontSize: 14))])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatusBadge(
                  label: user.isActive ? 'Actif' : 'Inactif',
                  color: user.isActive ? const Color(0xFF10B981) : AppColors.colorRedSecondary,
                ),
                const SizedBox(width: 8),
                _StatusBadge(
                  label: user.trialStatusLabel,
                  color: user.trialStatus == 'active'
                      ? const Color(0xFF10B981)
                      : user.trialStatus == 'expired'
                          ? AppColors.colorRedSecondary
                          : AppColors.colorGrayDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Status Badge
// ============================================================

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: mediumTextStyle(fontSize: 12, color: color)),
    );
  }
}

// ============================================================
// User Detail Dialog
// ============================================================

class _UserDetailDialog extends ConsumerWidget {
  final String userId;

  const _UserDetailDialog({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDetailProvider(userId));
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550),
        padding: const EdgeInsets.all(24),
        child: userAsync.when(
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.badgeAlert, color: AppColors.colorRedSecondary, size: 40),
              const SizedBox(height: 12),
              Text('Erreur: $e', style: basicTextStyle(color: AppColors.colorRedSecondary)),
              const SizedBox(height: 16),
              TextButton(onPressed: () => Navigator.pop(context), child: const MediumText('Fermer')),
            ],
          ),
          data: (user) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.colorBluePrimary.withOpacity(0.1),
                      child: Text(
                        ((user.fullName ?? user.email)[0]).toUpperCase(),
                        style: boldTextStyle(color: AppColors.colorBluePrimary, fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullName ?? 'Sans nom', style: boldTextStyle(fontSize: 20)),
                          Text(user.email, style: basicTextStyle(color: AppColors.colorGrayDark, fontSize: 14)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.x, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                // Info rows
                _DetailRow('ID', user.id),
                _DetailRow('Téléphone', user.phone ?? 'N/A'),
                _DetailRow('Pays', user.countryCode ?? 'N/A'),
                _DetailRow('Email vérifié', user.emailVerified ? 'Oui' : 'Non'),
                _DetailRow('Statut', user.isActive ? 'Actif' : 'Inactif'),
                _DetailRow('Essai', user.trialStatusLabel),
                if (user.trialEndsAt != null)
                  _DetailRow('Fin essai', dateFormat.format(DateTime.parse(user.trialEndsAt!))),
                _DetailRow('Inscrit le', user.createdAt.isNotEmpty ? dateFormat.format(DateTime.parse(user.createdAt)) : 'N/A'),
                if (user.lastSignInAt != null)
                  _DetailRow('Dernière connexion', dateFormat.format(DateTime.parse(user.lastSignInAt!))),
                _DetailRow('Paiements', '${user.paymentsCount ?? 0}'),

                // Subscription
                if (user.subscription != null) ...[
                  const SizedBox(height: 16),
                  Text('Abonnement', style: boldTextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.creditCard, size: 20, color: const Color(0xFF10B981)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.subscription!.planName, style: mediumTextStyle(fontSize: 14)),
                              if (user.subscription!.expiresAt != null)
                                Text(
                                  'Expire le ${dateFormat.format(DateTime.parse(user.subscription!.expiresAt!))}',
                                  style: basicTextStyle(fontSize: 12, color: AppColors.colorGrayDark),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Profiles
                if (user.profiles != null && user.profiles!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Profils (${user.profiles!.length})', style: boldTextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  ...user.profiles!.map((profile) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(
                              profile.isChild ? LucideIcons.baby : LucideIcons.user,
                              size: 16,
                              color: AppColors.colorGrayDark,
                            ),
                            const SizedBox(width: 8),
                            Text(profile.name, style: basicTextStyle(fontSize: 14)),
                            if (profile.isPrimary) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.colorBluePrimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('Principal', style: mediumTextStyle(fontSize: 10, color: AppColors.colorBluePrimary)),
                              ),
                            ],
                          ],
                        ),
                      )),
                ],

                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const MediumText('Fermer', fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: basicTextStyle(fontSize: 13, color: AppColors.colorGrayDark)),
          ),
          Expanded(child: Text(value, style: mediumTextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
