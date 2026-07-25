import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(teamListProvider.notifier).loadTeam());
  }

  void _reload() => ref.read(teamListProvider.notifier).loadTeam();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamListProvider);
    final isMobile = ResponsiveLayout.isMobile(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');

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
                    Text('Équipe Admin', style: boldTextStyle(fontSize: isMobile ? 22 : 28)),
                    const SizedBox(height: 4),
                    Text('${state.members.length} membres', style: basicTextStyle(color: AppColors.colorGrayDark)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.colorBluePrimary,
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(LucideIcons.userPlus, size: 18, color: Colors.white),
                label: Text(isMobile ? 'Ajouter' : 'Ajouter un admin', style: mediumTextStyle(fontSize: 14, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (state.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (state.error != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.colorRedSecondary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Icon(LucideIcons.circleAlert, color: AppColors.colorRedSecondary, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(state.error!, style: basicTextStyle(color: AppColors.colorRedSecondary, fontSize: 13))),
                TextButton(onPressed: _reload, child: Text('Réessayer', style: mediumTextStyle(fontSize: 13, color: AppColors.colorBluePrimary))),
              ]),
            )
          else if (state.members.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: Center(child: Column(children: [
                Icon(LucideIcons.shield, size: 40, color: AppColors.colorGrayDark),
                const SizedBox(height: 12),
                Text('Aucun admin', style: mediumTextStyle(color: AppColors.colorGrayDark)),
              ])),
            )
          else if (isMobile)
            Column(children: state.members.map((m) => _MemberCard(member: m, dateFormat: dateFormat, onAction: (a) => _onAction(m, a))).toList())
          else
            _MembersTable(members: state.members, dateFormat: dateFormat, onAction: _onAction),
        ],
      ),
    );
  }

  void _onAction(AdminTeamMemberModel member, String action) async {
    switch (action) {
      case 'edit_role':
        _showEditRoleDialog(member);
        break;
      case 'toggle_active':
        final confirmed = await _confirm(
          member.isActive ? 'Désactiver ${member.userName} ?' : 'Activer ${member.userName} ?',
          member.isActive ? 'L\'admin ne pourra plus accéder au dashboard.' : 'L\'admin pourra de nouveau accéder au dashboard.',
        );
        if (confirmed) {
          final ok = await ref.read(teamListProvider.notifier).updateMember(member.id, isActive: !member.isActive);
          _snack(ok ? (member.isActive ? 'Admin désactivé' : 'Admin activé') : 'Erreur', ok);
          if (ok) _reload();
        }
        break;
      case 'remove':
        final confirmed = await _confirm('Supprimer ${member.userName} ?', 'Cette action est irréversible.');
        if (confirmed) {
          final ok = await ref.read(teamListProvider.notifier).removeMember(member.id);
          _snack(ok ? 'Admin supprimé' : 'Erreur', ok);
          if (ok) _reload();
        }
        break;
    }
  }

  void _showAddDialog() {
    final userIdCtrl = TextEditingController();
    String selectedRole = 'analyst';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const TitleText('Ajouter un admin', fontSize: 18),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: userIdCtrl,
                  style: basicTextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'ID utilisateur *',
                    labelStyle: basicTextStyle(fontSize: 14, color: AppColors.colorGrayDark),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Rôle',
                    labelStyle: basicTextStyle(fontSize: 14, color: AppColors.colorGrayDark),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _roleOptions.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                  onChanged: (val) => setDialogState(() => selectedRole = val ?? 'analyst'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const MediumText('Annuler', fontSize: 14)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.colorBluePrimary),
              onPressed: () async {
                if (userIdCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                final ok = await ref.read(teamListProvider.notifier).addMember(userIdCtrl.text.trim(), selectedRole);
                _snack(ok ? 'Admin ajouté' : 'Erreur ajout', ok);
                if (ok) _reload();
              },
              child: const MediumText('Ajouter', fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditRoleDialog(AdminTeamMemberModel member) {
    String selectedRole = member.role;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: TitleText('Modifier le rôle de ${member.userName}', fontSize: 18),
          content: SizedBox(
            width: 400,
            child: DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: InputDecoration(
                labelText: 'Rôle',
                labelStyle: basicTextStyle(fontSize: 14, color: AppColors.colorGrayDark),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: _roleOptions.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
              onChanged: (val) => setDialogState(() => selectedRole = val ?? member.role),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const MediumText('Annuler', fontSize: 14)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.colorBluePrimary),
              onPressed: () async {
                Navigator.pop(ctx);
                if (selectedRole == member.role) return;
                final ok = await ref.read(teamListProvider.notifier).updateMember(member.id, role: selectedRole);
                _snack(ok ? 'Rôle modifié' : 'Erreur', ok);
                if (ok) _reload();
              },
              child: const MediumText('Enregistrer', fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
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
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.colorRedSecondary),
                onPressed: () => Navigator.pop(ctx, true),
                child: const MediumText('Confirmer', fontSize: 14, color: Colors.white),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _snack(String msg, bool success) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: MediumText(msg, color: Colors.white), backgroundColor: success ? Colors.green : Colors.red));
  }

  static const _roleOptions = {
    'super_admin': 'Super Admin',
    'content_manager': 'Gestionnaire Contenu',
    'finance_manager': 'Gestionnaire Finance',
    'support_agent': 'Support',
    'analyst': 'Analyste',
  };
}

// ============================================================
// Members Table (Desktop)
// ============================================================

class _MembersTable extends StatelessWidget {
  final List<AdminTeamMemberModel> members;
  final DateFormat dateFormat;
  final Function(AdminTeamMemberModel, String) onAction;

  const _MembersTable({required this.members, required this.dateFormat, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
          child: Row(children: [
            Expanded(flex: 3, child: Text('Admin', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
            Expanded(flex: 2, child: Text('Rôle', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
            Expanded(flex: 2, child: Text('Statut', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
            Expanded(flex: 2, child: Text('Dernière connexion', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
            const SizedBox(width: 140),
          ]),
        ),
        ...members.map((m) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
              child: Row(children: [
                Expanded(
                  flex: 3,
                  child: Row(children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: _roleColor(m.role).withOpacity(0.1),
                      child: Text(m.userName[0].toUpperCase(), style: boldTextStyle(color: _roleColor(m.role), fontSize: 14)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(m.userName, style: mediumTextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                      Text(m.userEmail, style: basicTextStyle(fontSize: 12, color: AppColors.colorGrayDark), overflow: TextOverflow.ellipsis),
                    ])),
                  ]),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: _roleColor(m.role).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(m.roleLabel, style: mediumTextStyle(fontSize: 12, color: _roleColor(m.role))),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: m.isActive ? const Color(0xFF10B981) : AppColors.colorRedSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(m.isActive ? 'Actif' : 'Inactif', style: basicTextStyle(fontSize: 13)),
                  ]),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    m.lastLoginAt != null ? dateFormat.format(DateTime.parse(m.lastLoginAt!)) : 'Jamais',
                    style: basicTextStyle(fontSize: 13, color: AppColors.colorGrayDark),
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: Row(children: [
                    Tooltip(
                      message: 'Modifier le rôle',
                      child: IconButton(onPressed: () => onAction(m, 'edit_role'), icon: Icon(LucideIcons.pencil, size: 18, color: AppColors.colorBluePrimary)),
                    ),
                    Tooltip(
                      message: m.isActive ? 'Désactiver' : 'Activer',
                      child: IconButton(
                        onPressed: () => onAction(m, 'toggle_active'),
                        icon: Icon(m.isActive ? LucideIcons.userX : LucideIcons.userCheck, size: 18, color: m.isActive ? AppColors.colorRedSecondary : const Color(0xFF10B981)),
                      ),
                    ),
                    Tooltip(
                      message: 'Supprimer',
                      child: IconButton(onPressed: () => onAction(m, 'remove'), icon: Icon(LucideIcons.trash2, size: 18, color: AppColors.colorRedSecondary)),
                    ),
                  ]),
                ),
              ]),
            )),
      ]),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'super_admin': return AppColors.colorRedSecondary;
      case 'content_manager': return AppColors.colorBluePrimary;
      case 'finance_manager': return const Color(0xFF10B981);
      case 'support_agent': return const Color(0xFFF59E0B);
      case 'analyst': return const Color(0xFF8B5CF6);
      default: return AppColors.colorGrayDark;
    }
  }
}

// ============================================================
// Member Card (Mobile)
// ============================================================

class _MemberCard extends StatelessWidget {
  final AdminTeamMemberModel member;
  final DateFormat dateFormat;
  final Function(String) onAction;

  const _MemberCard({required this.member, required this.dateFormat, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.colorBluePrimary.withOpacity(0.1),
            child: Text(member.userName[0].toUpperCase(), style: boldTextStyle(color: AppColors.colorBluePrimary, fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(member.userName, style: mediumTextStyle(fontSize: 15)),
            Text(member.userEmail, style: basicTextStyle(fontSize: 12, color: AppColors.colorGrayDark)),
          ])),
          PopupMenuButton<String>(
            onSelected: onAction,
            itemBuilder: (ctx) => [
              PopupMenuItem(value: 'edit_role', child: Row(children: [Icon(LucideIcons.pencil, size: 16), const SizedBox(width: 8), Text('Modifier rôle', style: basicTextStyle(fontSize: 14))])),
              PopupMenuItem(value: 'toggle_active', child: Row(children: [Icon(member.isActive ? LucideIcons.userX : LucideIcons.userCheck, size: 16), const SizedBox(width: 8), Text(member.isActive ? 'Désactiver' : 'Activer', style: basicTextStyle(fontSize: 14))])),
              PopupMenuItem(value: 'remove', child: Row(children: [Icon(LucideIcons.trash2, size: 16, color: AppColors.colorRedSecondary), const SizedBox(width: 8), Text('Supprimer', style: basicTextStyle(fontSize: 14, color: AppColors.colorRedSecondary))])),
            ],
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.colorBluePrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(member.roleLabel, style: mediumTextStyle(fontSize: 12, color: AppColors.colorBluePrimary)),
          ),
          const SizedBox(width: 8),
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: member.isActive ? const Color(0xFF10B981) : AppColors.colorRedSecondary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(member.isActive ? 'Actif' : 'Inactif', style: basicTextStyle(fontSize: 12)),
        ]),
      ]),
    );
  }
}
