import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../common/common.dart';
import '../../../users/data/admin_user_model.dart';
import '../../producers.dart';

@RoutePage()
class ProducersScreen extends ConsumerStatefulWidget {
  const ProducersScreen({super.key});

  @override
  ConsumerState<ProducersScreen> createState() => _ProducersScreenState();
}

class _ProducersScreenState extends ConsumerState<ProducersScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadProducers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _loadProducers() {
    final filters = ref.read(producersFilterProvider);
    ref.read(producersListProvider.notifier).loadProducers(
          page: filters.page,
          search: filters.search,
        );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(producersFilterProvider.notifier).state =
          ref.read(producersFilterProvider).copyWith(search: value.isEmpty ? null : value, page: 1, clearSearch: value.isEmpty);
      _loadProducers();
    });
  }

  void _goToPage(int page) {
    ref.read(producersFilterProvider.notifier).state =
        ref.read(producersFilterProvider).copyWith(page: page);
    _loadProducers();
  }

  @override
  Widget build(BuildContext context) {
    final producersState = ref.watch(producersListProvider);
    final filters = ref.watch(producersFilterProvider);
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
                    Text('Producteurs', style: boldTextStyle(fontSize: isMobile ? 22 : 28)),
                    const SizedBox(height: 4),
                    Text(
                      producersState.pagination != null
                          ? '${producersState.pagination!.total} producteurs au total'
                          : 'Chargement...',
                      style: basicTextStyle(color: AppColors.colorGrayDark),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.colorBluePrimary,
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
                label: Text(isMobile ? 'Ajouter' : 'Nouveau producteur', style: mediumTextStyle(fontSize: 14, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: basicTextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Rechercher par nom...',
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
                ),
                if (filters.search != null) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      _searchController.clear();
                      ref.read(producersFilterProvider.notifier).state = ProducersFilterState();
                      _loadProducers();
                    },
                    icon: const Icon(LucideIcons.x, size: 16),
                    label: Text('Effacer', style: basicTextStyle(fontSize: 13, color: AppColors.colorRedSecondary)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // List
          _buildProducersList(producersState, isMobile),

          // Pagination
          if (producersState.pagination != null && producersState.pagination!.totalPages > 1) ...[
            const SizedBox(height: 16),
            _buildPagination(producersState.pagination!, filters.page),
          ],
        ],
      ),
    );
  }

  Widget _buildProducersList(ProducersListState state, bool isMobile) {
    if (state.isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
    }

    if (state.error != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.colorRedSecondary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(LucideIcons.badgeAlert, color: AppColors.colorRedSecondary, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(state.error!, style: basicTextStyle(color: AppColors.colorRedSecondary, fontSize: 13))),
            TextButton(onPressed: _loadProducers, child: Text('Réessayer', style: mediumTextStyle(fontSize: 13, color: AppColors.colorBluePrimary))),
          ],
        ),
      );
    }

    if (state.producers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
        child: Center(
          child: Column(
            children: [
              Icon(LucideIcons.building2, size: 40, color: AppColors.colorGrayDark),
              const SizedBox(height: 12),
              Text('Aucun producteur trouvé', style: mediumTextStyle(color: AppColors.colorGrayDark)),
            ],
          ),
        ),
      );
    }

    if (isMobile) {
      return Column(children: state.producers.map((p) => _ProducerCard(producer: p, onTap: () => _showDetailDialog(p))).toList());
    }

    return _ProducersTable(producers: state.producers, onTap: _showDetailDialog, onEdit: _showEditDialog, onToggleVerify: _toggleVerify);
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final countryCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const TitleText('Nouveau producteur', fontSize: 18),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogTextField(controller: nameCtrl, label: 'Nom *'),
              const SizedBox(height: 12),
              _DialogTextField(controller: descCtrl, label: 'Description', maxLines: 3),
              const SizedBox(height: 12),
              _DialogTextField(controller: countryCtrl, label: 'Code pays (ex: CI, FR)'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const MediumText('Annuler', fontSize: 14)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.colorBluePrimary),
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final ok = await ref.read(producersListProvider.notifier).createProducer(
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                    countryCode: countryCtrl.text.trim().isEmpty ? null : countryCtrl.text.trim().toUpperCase(),
                  );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: MediumText(ok ? 'Producteur créé' : 'Erreur création', color: Colors.white),
                  backgroundColor: ok ? Colors.green : Colors.red,
                ));
                if (ok) _loadProducers();
              }
            },
            child: const MediumText('Créer', fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(AdminProducerModel producer) {
    final nameCtrl = TextEditingController(text: producer.name);
    final descCtrl = TextEditingController(text: producer.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: TitleText('Modifier ${producer.name}', fontSize: 18),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogTextField(controller: nameCtrl, label: 'Nom'),
              const SizedBox(height: 12),
              _DialogTextField(controller: descCtrl, label: 'Description', maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const MediumText('Annuler', fontSize: 14)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.colorBluePrimary),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref.read(producersListProvider.notifier).updateProducer(
                    producer.id,
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                  );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: MediumText(ok ? 'Producteur modifié' : 'Erreur', color: Colors.white),
                  backgroundColor: ok ? Colors.green : Colors.red,
                ));
                if (ok) _loadProducers();
              }
            },
            child: const MediumText('Enregistrer', fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _toggleVerify(AdminProducerModel producer) async {
    final ok = await ref.read(producersListProvider.notifier).updateProducer(producer.id, isVerified: !producer.isVerified);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: MediumText(ok ? (producer.isVerified ? 'Vérification retirée' : 'Producteur vérifié') : 'Erreur', color: Colors.white),
        backgroundColor: ok ? Colors.green : Colors.red,
      ));
      if (ok) _loadProducers();
    }
  }

  void _showDetailDialog(AdminProducerModel producer) {
    showDialog(
      context: context,
      builder: (ctx) => _ProducerDetailDialog(
        producerId: producer.id,
        onMemberRemoved: () => _loadProducers(),
      ),
    );
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
// Producers Table (Desktop)
// ============================================================

class _ProducersTable extends StatelessWidget {
  final List<AdminProducerModel> producers;
  final Function(AdminProducerModel) onTap;
  final Function(AdminProducerModel) onEdit;
  final Function(AdminProducerModel) onToggleVerify;

  const _ProducersTable({required this.producers, required this.onTap, required this.onEdit, required this.onToggleVerify});

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
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('Producteur', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
                Expanded(flex: 2, child: Text('Pays', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
                Expanded(flex: 2, child: Text('Vérifié', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
                Expanded(flex: 2, child: Text('Créé le', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
                const SizedBox(width: 120, child: Text('Actions', style: TextStyle(fontSize: 13))),
              ],
            ),
          ),
          ...producers.map((producer) => InkWell(
                onTap: () => onTap(producer),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: producer.logoUrl != null
                                  ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(producer.logoUrl!, fit: BoxFit.cover))
                                  : Center(child: Text(producer.name[0].toUpperCase(), style: boldTextStyle(color: const Color(0xFF10B981), fontSize: 16))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(producer.name, style: mediumTextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                                  if (producer.description != null)
                                    Text(producer.description!, style: basicTextStyle(fontSize: 12, color: AppColors.colorGrayDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(flex: 2, child: Text(producer.countryCode ?? '-', style: basicTextStyle(fontSize: 13))),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: producer.isVerified ? const Color(0xFF10B981).withOpacity(0.1) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (producer.isVerified) Icon(LucideIcons.badgeCheck, size: 14, color: const Color(0xFF10B981)),
                              if (producer.isVerified) const SizedBox(width: 4),
                              Text(
                                producer.isVerified ? 'Vérifié' : 'Non vérifié',
                                style: mediumTextStyle(fontSize: 12, color: producer.isVerified ? const Color(0xFF10B981) : AppColors.colorGrayDark),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          producer.createdAt.isNotEmpty ? dateFormat.format(DateTime.parse(producer.createdAt)) : '-',
                          style: basicTextStyle(fontSize: 13),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: Row(
                          children: [
                            Tooltip(
                              message: 'Modifier',
                              child: IconButton(onPressed: () => onEdit(producer), icon: Icon(LucideIcons.pencil, size: 18, color: AppColors.colorBluePrimary)),
                            ),
                            Tooltip(
                              message: producer.isVerified ? 'Retirer vérification' : 'Vérifier',
                              child: IconButton(
                                onPressed: () => onToggleVerify(producer),
                                icon: Icon(
                                  producer.isVerified ? LucideIcons.shieldOff : LucideIcons.shieldCheck,
                                  size: 18,
                                  color: producer.isVerified ? AppColors.colorRedSecondary : const Color(0xFF10B981),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// ============================================================
// Producer Card (Mobile)
// ============================================================

class _ProducerCard extends StatelessWidget {
  final AdminProducerModel producer;
  final VoidCallback onTap;

  const _ProducerCard({required this.producer, required this.onTap});

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
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(producer.name[0].toUpperCase(), style: boldTextStyle(color: const Color(0xFF10B981), fontSize: 18))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(producer.name, style: mediumTextStyle(fontSize: 15)),
                    if (producer.description != null)
                      Text(producer.description!, style: basicTextStyle(fontSize: 12, color: AppColors.colorGrayDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (producer.isVerified) Icon(LucideIcons.badgeCheck, size: 20, color: const Color(0xFF10B981)),
              const SizedBox(width: 4),
              const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.colorGrayDark),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Producer Detail Dialog
// ============================================================

class _ProducerDetailDialog extends ConsumerWidget {
  final String producerId;
  final VoidCallback onMemberRemoved;

  const _ProducerDetailDialog({required this.producerId, required this.onMemberRemoved});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(producerDetailProvider(producerId));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: detailAsync.when(
          loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
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
          data: (producer) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text(producer.name[0].toUpperCase(), style: boldTextStyle(color: const Color(0xFF10B981), fontSize: 22))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(producer.name, style: boldTextStyle(fontSize: 20))),
                              if (producer.isVerified)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(LucideIcons.badgeCheck, size: 14, color: const Color(0xFF10B981)),
                                      const SizedBox(width: 4),
                                      Text('Vérifié', style: mediumTextStyle(fontSize: 11, color: const Color(0xFF10B981))),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          if (producer.description != null) ...[
                            const SizedBox(height: 4),
                            Text(producer.description!, style: basicTextStyle(color: AppColors.colorGrayDark, fontSize: 13)),
                          ],
                        ],
                      ),
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x, size: 20)),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                // Info
                _InfoRow('ID', producer.id),
                _InfoRow('Slug', producer.slug),
                _InfoRow('Pays', producer.countryCode ?? 'N/A'),
                _InfoRow('Contenus', '${producer.contentsCount ?? 0}'),

                // Members
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text('Équipe (${producer.members?.length ?? 0})', style: boldTextStyle(fontSize: 16)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _showAddMemberDialog(context, ref, producer.id),
                      icon: const Icon(LucideIcons.userPlus, size: 16),
                      label: Text('Ajouter', style: mediumTextStyle(fontSize: 13, color: AppColors.colorBluePrimary)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (producer.members == null || producer.members!.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text('Aucun membre', style: basicTextStyle(color: AppColors.colorGrayDark))),
                  )
                else
                  ...producer.members!.map((member) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.colorBluePrimary.withOpacity(0.1),
                              child: Text(member.userName[0].toUpperCase(), style: boldTextStyle(color: AppColors.colorBluePrimary, fontSize: 13)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(member.userName, style: mediumTextStyle(fontSize: 14)),
                                  Text(member.userEmail, style: basicTextStyle(fontSize: 12, color: AppColors.colorGrayDark)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.colorBluePrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                              child: Text(member.roleLabel, style: mediumTextStyle(fontSize: 11, color: AppColors.colorBluePrimary)),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const TitleText('Retirer le membre ?', fontSize: 16),
                                    content: MediumText('${member.userName} sera retiré de l\'équipe.', fontSize: 14),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const MediumText('Annuler', fontSize: 14)),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.colorRedSecondary),
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const MediumText('Retirer', fontSize: 14, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true) {
                                  try {
                                    await ref.read(producersRepositoryProvider).removeMember(producer.id, member.id);
                                    ref.invalidate(producerDetailProvider(producer.id));
                                    onMemberRemoved();
                                  } catch (_) {}
                                }
                              },
                              icon: Icon(LucideIcons.userMinus, size: 16, color: AppColors.colorRedSecondary),
                            ),
                          ],
                        ),
                      )),

                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: () => Navigator.pop(context), child: const MediumText('Fermer', fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, WidgetRef ref, String producerId) {
    final userIdCtrl = TextEditingController();
    String selectedRole = 'viewer';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const TitleText('Ajouter un membre', fontSize: 18),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogTextField(controller: userIdCtrl, label: 'ID utilisateur'),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Rôle',
                    labelStyle: basicTextStyle(fontSize: 14, color: AppColors.colorGrayDark),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'owner', child: Text('Propriétaire')),
                    DropdownMenuItem(value: 'manager', child: Text('Manager')),
                    DropdownMenuItem(value: 'viewer', child: Text('Lecteur')),
                  ],
                  onChanged: (val) => setDialogState(() => selectedRole = val ?? 'viewer'),
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
                try {
                  await ref.read(producersRepositoryProvider).addMember(producerId, userIdCtrl.text.trim(), selectedRole);
                  ref.invalidate(producerDetailProvider(producerId));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: MediumText('Membre ajouté', color: Colors.white),
                      backgroundColor: Colors.green,
                    ));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: MediumText('Erreur ajout membre', color: Colors.white),
                      backgroundColor: Colors.red,
                    ));
                  }
                }
              },
              child: const MediumText('Ajouter', fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Shared Widgets
// ============================================================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: basicTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
          Expanded(child: Text(value, style: mediumTextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const _DialogTextField({required this.controller, required this.label, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: basicTextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: basicTextStyle(fontSize: 14, color: AppColors.colorGrayDark),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
