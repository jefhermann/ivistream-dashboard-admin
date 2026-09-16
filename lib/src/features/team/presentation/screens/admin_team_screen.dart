import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../common/common.dart';
import '../../team.dart';

@RoutePage()
class AdminTeamScreen extends ConsumerStatefulWidget {
  const AdminTeamScreen({super.key});

  @override
  ConsumerState<AdminTeamScreen> createState() => _AdminTeamScreenState();
}

class _AdminTeamScreenState extends ConsumerState<AdminTeamScreen> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final membersAsync = ref.watch(memberListProvider);
    final filters = ref.watch(memberFilterProvider);


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
                    Text('Membres', style: boldTextStyle(fontSize: isMobile ? 22 : 28)),
                    const SizedBox(height: 4),
                    Text(
                      membersAsync.maybeWhen(
                        data: (state) => state.pagination != null ? '${state.pagination!.total} membres au total' : '0 membres',
                        orElse: () => 'Chargement...',
                      ),
                      style: basicTextStyle(color: AppColors.colorGrayDark),
                    ),
                  ],
                ),
              ),
              if (!isMobile)
                ElevatedButton.icon(
                  onPressed: () => _openAddMemberDialog(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorBluePrimary,
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
                  label: Text(isMobile ? 'Ajouter' : 'Nouveau Membre', style: mediumTextStyle(fontSize: 14, color: Colors.white)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Spacers.min,
                Row(
                  children: [
                    Expanded(
                      child: BasicInput(
                        searchController,
                        hintText: 'Rechercher un membre',
                        onChanged: (value) {
                          ref.read(memberFilterProvider.notifier).update((state) => state.copyWith(
                            search: value.isEmpty ? null : value,
                            page: 1,
                            clearSearch: value.isEmpty,
                          ));
                        },
                      ),
                    ),
                    if (filters.search != null) ...[
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              searchController.clear();
                              ref.invalidate(memberFilterProvider);
                            },
                            icon: const Icon(LucideIcons.x, size: 16),
                            label: Text('Effacer', style: basicTextStyle(fontSize: 13, color: AppColors.colorRedSecondary)),
                          ),
                          Spacers.min,
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          membersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.colorRedSecondary.withValues(alpha: .1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(LucideIcons.badgeAlert, color: AppColors.colorRedSecondary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(error.toString(), style: basicTextStyle(color: AppColors.colorRedSecondary, fontSize: 13))),
                  TextButton(
                    onPressed: () => ref.invalidate(memberListProvider),
                    child: Text('Réessayer', style: mediumTextStyle(fontSize: 13, color: AppColors.colorBluePrimary)),
                  ),
                ],
              ),
            ),
            data: (data) {
              if (data.members.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(LucideIcons.building2, size: 40, color: AppColors.colorGrayDark),
                        const SizedBox(height: 12),
                        Text('Aucun membre trouvé', style: mediumTextStyle(color: AppColors.colorGrayDark)),
                      ],
                    ),
                  ),
                );
              }

              return TableWidget<AdminMemberModel>(
                items: data.members,
                pagination: data.pagination!,
                currentPage: filters.page,
                onRowTap: (item) {},
                goToPage: (int page) {
                  ref.read(memberFilterProvider.notifier).update((state) => state.copyWith(page: page));
                },
                showPagination: data.pagination != null && data.pagination!.totalPages > 1,
                actionBuilder: (item){
                  return PopupMenuButton<String>(
                    onSelected: (value) => _handleAction(context, ref, value, item),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'role', child: Text('Changer le rôle')),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Text(item.isActive ? 'Désactiver' : 'Réactiver'),
                      ),
                      const PopupMenuItem(value: 'remove', child: Text('Retirer')),
                    ],
                  );
                },
                columns: [
                  TableColumn(
                    label: 'Nom',
                    flex: 1,
                    cell: (u) => Row(
                      children: [
                        CircleAvatar(
                          child: Text(u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : '?'),
                        ),
                        Spacers.sw1,
                        Text(
                          u.fullName.isNotEmpty ? u.fullName : u.email,
                          style: boldTextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  TableColumn(
                    label: 'Rôle',
                    flex: 1,
                    cell: (u) => Text(u.role.label, style: basicTextStyle(fontSize: 13)),
                  ),
                  TableColumn(
                    label: 'Statut',
                    flex: 1,
                    cell: (u) => Row(
                      children: [
                        if (u.isActive == true) const Icon(LucideIcons.badgeCheck, size: 14, color: Color(0xFF10B981)),
                        Text(u.isActive == true ? ' Actif ' : ' Inactif',
                            style: boldTextStyle(color: u.isActive == true ? const Color(0xFF10B981) : AppColors.colorRedSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, String action, AdminMemberModel member) async {
    final repo = ref.read(adminTeamRepositoryProvider);

    switch (action) {
      case 'role':
        final newRole = await showDialog<AdminRole>(
          context: context,
          builder: (_) => _RolePickerSheet(current: member.role),
        );
        if (newRole != null && newRole != member.role) {
          await repo.updateMember(member.id, role: newRole);
          ref.invalidate(memberListProvider);
        }
        break;

      case 'toggle':
        await repo.updateMember(member.id, isActive: !member.isActive);
        ref.invalidate(memberListProvider);
        break;

      case 'remove':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Retirer ce membre ?'),
            content: Text("${member.fullName} perdra l'accès au dashboard admin."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Retirer'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await repo.removeMember(member.id);
          ref.invalidate(memberListProvider);
        }
        break;
    }
  }

  void _openAddMemberDialog(BuildContext context, WidgetRef ref) {
    showDialog<bool>(
      context: context,
      builder: (_) => const AddAdminMemberDialog(),
    ).then((invited) {
      if (invited == true) {
        ref.invalidate(memberListProvider);
        ref.invalidate(adminTeamInvitationsProvider);
      }
    });
  }
}

class _RolePickerSheet extends StatelessWidget {
  const _RolePickerSheet({required this.current});

  final AdminRole current;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text('Changer le rôle', style: Theme.of(context).textTheme.titleLarge),
            ),
            ...AdminRole.values.map((role) {
              return ListTile(
                title: Text(role.label),
                trailing: role == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, role),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _InvitationsTab extends ConsumerWidget {
  const _InvitationsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitationsAsync = ref.watch(adminTeamInvitationsProvider);

    return invitationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Erreur : $err')),
      data: (invitations) {
        if (invitations.isEmpty) {
          return const Center(child: Text('Aucune invitation en attente'));
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminTeamInvitationsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: invitations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _InvitationTile(invitation: invitations[index]),
          ),
        );
      },
    );
  }
}

class _InvitationTile extends ConsumerWidget {
  const _InvitationTile({required this.invitation});

  final AdminInvitationModel invitation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.mail_outline),
        title: Text(invitation.email),
        subtitle: Text(
          '${invitation.role.label} · '
          '${invitation.isExpired ? "Expirée" : "Expire le ${_formatDate(invitation.expiresAt)}"}'
          '${invitation.invitedByName != null ? " · Invité par ${invitation.invitedByName}" : ""}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          tooltip: "Annuler l'invitation",
          onPressed: () => _cancel(context, ref),
        ),
      ),
    );
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Annuler cette invitation ?'),
        content: Text("${invitation.email} ne pourra plus utiliser ce lien."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Non')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Annuler l'invitation"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(adminTeamRepositoryProvider).cancelInvitation(invitation.id);
      ref.invalidate(adminTeamInvitationsProvider);
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
