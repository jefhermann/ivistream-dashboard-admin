import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../common/common.dart';
import '../../revenues.dart';

@RoutePage()
class RevenuesScreen extends ConsumerStatefulWidget {
  const RevenuesScreen({super.key});

  @override
  ConsumerState<RevenuesScreen> createState() => _RevenuesScreenState();
}

class _RevenuesScreenState extends ConsumerState<RevenuesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => _loadPayouts());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadPayouts() {
    final f = ref.read(payoutsFilterProvider);
    ref.read(payoutsListProvider.notifier).loadPayouts(page: f.page, status: f.status, producerId: f.producerId);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.colorBluePrimary,
            unselectedLabelColor: AppColors.colorGrayDark,
            indicatorColor: AppColors.colorBluePrimary,
            labelStyle: mediumTextStyle(fontSize: 14),
            unselectedLabelStyle: basicTextStyle(fontSize: 14),
            tabs: const [
              Tab(text: 'Vue d\'ensemble'),
              Tab(text: 'Payouts'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _OverviewTab(isMobile: isMobile),
              _PayoutsTab(isMobile: isMobile, onRefresh: _loadPayouts),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// OVERVIEW TAB
// ============================================================

class _OverviewTab extends ConsumerWidget {
  final bool isMobile;
  const _OverviewTab({required this.isMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(revenueOverviewProvider);
    final producersAsync = ref.watch(producerRevenuesProvider);
    final currencyFormat = NumberFormat('#,###', 'fr_FR');

    return overviewAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e', style: basicTextStyle(color: AppColors.colorRedSecondary))),
      data: (overview) => SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Revenus', style: boldTextStyle(fontSize: isMobile ? 22 : 28)),
            const SizedBox(height: 4),
            Text('Vue d\'ensemble financière', style: basicTextStyle(color: AppColors.colorGrayDark)),
            const SizedBox(height: 24),

            // Global cards
            Wrap(
              spacing: 16, runSpacing: 16,
              children: [
                _RevenueCard(icon: LucideIcons.trendingUp, label: 'CA Total', value: '${currencyFormat.format(overview.totalGross)} ${overview.currency}', color: AppColors.colorBluePrimary, isMobile: isMobile),
                _RevenueCard(icon: LucideIcons.building2, label: 'Part Producteurs', value: '${currencyFormat.format(overview.totalProducer)} ${overview.currency}', color: const Color(0xFF10B981), isMobile: isMobile),
                _RevenueCard(icon: LucideIcons.landmark, label: 'Part Plateforme', value: '${currencyFormat.format(overview.totalPlatform)} ${overview.currency}', color: const Color(0xFF8B5CF6), isMobile: isMobile),
                _RevenueCard(icon: LucideIcons.clock, label: 'Payouts en attente', value: '${overview.pendingPayoutsCount} (${currencyFormat.format(overview.pendingPayoutsAmount)} ${overview.currency})', color: const Color(0xFFF59E0B), isMobile: isMobile),
              ],
            ),
            const SizedBox(height: 24),

            // Revenue by source
            if (overview.bySource.isNotEmpty) ...[
              _SectionCard(
                title: 'Répartition par source',
                icon: LucideIcons.chartPie,
                child: Column(
                  children: overview.bySource.entries.map((entry) {
                    final label = entry.key == 'subscription' ? 'Abonnements' : entry.key == 'rental' ? 'Locations' : 'Publicité';
                    final color = entry.key == 'subscription' ? AppColors.colorBluePrimary : entry.key == 'rental' ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(children: [
                        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
                        const SizedBox(width: 10),
                        Expanded(child: Text(label, style: mediumTextStyle(fontSize: 14))),
                        Text('${currencyFormat.format(entry.value.gross)} ${overview.currency}', style: boldTextStyle(fontSize: 14)),
                      ]),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Monthly chart (simple bar-like)
            if (overview.monthly.isNotEmpty) ...[
              _SectionCard(
                title: 'Revenus mensuels',
                icon: LucideIcons.chartBar,
                child: Column(
                  children: overview.monthly.reversed.take(6).toList().reversed.map((m) {
                    final maxGross = overview.monthly.map((e) => e.gross).reduce((a, b) => a > b ? a : b);
                    final ratio = maxGross > 0 ? m.gross / maxGross : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(children: [
                        SizedBox(width: 70, child: Text(m.month, style: basicTextStyle(fontSize: 12, color: AppColors.colorGrayDark))),
                        Expanded(
                          child: Container(
                            height: 28,
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: ratio,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.colorBluePrimary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(width: 100, child: Text('${currencyFormat.format(m.gross)}', style: mediumTextStyle(fontSize: 12), textAlign: TextAlign.right)),
                      ]),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Revenues by producer
            producersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const SizedBox.shrink(),
              data: (producers) => producers.isEmpty ? const SizedBox.shrink() : _SectionCard(
                title: 'Revenus par producteur',
                icon: LucideIcons.users,
                child: Column(
                  children: producers.take(10).map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                        child: Text(p.producerName[0].toUpperCase(), style: boldTextStyle(color: const Color(0xFF10B981), fontSize: 12)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(p.producerName, style: mediumTextStyle(fontSize: 14))),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${currencyFormat.format(p.totalGross)} ${overview.currency}', style: boldTextStyle(fontSize: 13)),
                          Text('Part prod: ${currencyFormat.format(p.totalProducer)}', style: basicTextStyle(fontSize: 11, color: AppColors.colorGrayDark)),
                        ],
                      ),
                    ]),
                  )).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isMobile;

  const _RevenueCard({required this.icon, required this.label, required this.value, required this.color, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final width = isMobile ? double.infinity : (MediaQuery.of(context).size.width - 240 - 48 - 48 - 16) / 2;
    return SizedBox(
      width: isMobile ? null : width,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: basicTextStyle(color: AppColors.colorGrayDark, fontSize: 13)),
            const SizedBox(height: 4),
            Text(value, style: boldTextStyle(fontSize: 17)),
          ])),
        ]),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 20, color: AppColors.colorBluePrimary),
          const SizedBox(width: 8),
          TitleText(title, fontSize: 16),
        ]),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }
}

// ============================================================
// PAYOUTS TAB
// ============================================================

class _PayoutsTab extends ConsumerWidget {
  final bool isMobile;
  final VoidCallback onRefresh;

  const _PayoutsTab({required this.isMobile, required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(payoutsListProvider);
    final filters = ref.watch(payoutsFilterProvider);
    final currencyFormat = NumberFormat('#,###', 'fr_FR');
    final dateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Payouts', style: boldTextStyle(fontSize: isMobile ? 22 : 28)),
        const SizedBox(height: 4),
        Text(state.pagination != null ? '${state.pagination!.total} payouts' : 'Chargement...', style: basicTextStyle(color: AppColors.colorGrayDark)),
        const SizedBox(height: 20),

        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
          child: Wrap(spacing: 12, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center, children: [
            _FilterChip(label: 'Statut', value: filters.status, options: const {
              'pending': 'En attente', 'calculated': 'Calculé', 'approved': 'Approuvé', 'paid': 'Payé', 'disputed': 'Contesté',
            }, onChanged: (val) {
              ref.read(payoutsFilterProvider.notifier).state = filters.copyWith(status: val, page: 1, clearStatus: val == null);
              onRefresh();
            }),
            if (filters.status != null)
              TextButton.icon(
                onPressed: () { ref.read(payoutsFilterProvider.notifier).state = PayoutsFilterState(); onRefresh(); },
                icon: const Icon(LucideIcons.x, size: 16),
                label: Text('Effacer', style: basicTextStyle(fontSize: 13, color: AppColors.colorRedSecondary)),
              ),
          ]),
        ),
        const SizedBox(height: 16),

        // List
        if (state.isLoading) const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
        else if (state.error != null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.colorRedSecondary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Icon(LucideIcons.badgeAlert, color: AppColors.colorRedSecondary, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(state.error!, style: basicTextStyle(color: AppColors.colorRedSecondary, fontSize: 13))),
              TextButton(onPressed: onRefresh, child: Text('Réessayer', style: mediumTextStyle(fontSize: 13, color: AppColors.colorBluePrimary))),
            ]),
          )
        else if (state.payouts.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
            child: Center(child: Column(children: [
              Icon(LucideIcons.handCoins, size: 40, color: AppColors.colorGrayDark),
              const SizedBox(height: 12),
              Text('Aucun payout', style: mediumTextStyle(color: AppColors.colorGrayDark)),
            ])),
          )
        else
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
            child: Column(children: [
              if (!isMobile) Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                child: Row(children: [
                  Expanded(flex: 3, child: Text('Producteur', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
                  Expanded(flex: 2, child: Text('Source', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
                  Expanded(flex: 2, child: Text('Période', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
                  Expanded(flex: 2, child: Text('Montant', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
                  Expanded(flex: 2, child: Text('Statut', style: mediumTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
                  const SizedBox(width: 120),
                ]),
              ),
              ...state.payouts.map((payout) => _PayoutRow(
                payout: payout,
                isMobile: isMobile,
                currencyFormat: currencyFormat,
                dateFormat: dateFormat,
                onAction: (action) => _handleAction(context, ref, payout, action),
              )),
            ]),
          ),

        if (state.pagination != null && state.pagination!.totalPages > 1) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(onPressed: filters.page > 1 ? () { ref.read(payoutsFilterProvider.notifier).state = filters.copyWith(page: filters.page - 1); onRefresh(); } : null, icon: const Icon(LucideIcons.chevronLeft, size: 20)),
              Text('Page ${filters.page}/${state.pagination!.totalPages}', style: mediumTextStyle(fontSize: 14)),
              IconButton(onPressed: filters.page < state.pagination!.totalPages ? () { ref.read(payoutsFilterProvider.notifier).state = filters.copyWith(page: filters.page + 1); onRefresh(); } : null, icon: const Icon(LucideIcons.chevronRight, size: 20)),
            ]),
          ),
        ],
      ]),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, PayoutModel payout, String action) async {
    switch (action) {
      case 'detail':
        showDialog(context: context, builder: (ctx) => _PayoutDetailDialog(payoutId: payout.id));
        break;
      case 'approve':
        final ok = await ref.read(payoutsListProvider.notifier).approvePayout(payout.id);
        _snack(context, ok ? 'Payout approuvé' : 'Erreur', ok);
        if (ok) onRefresh();
        break;
      case 'pay':
        final refCtrl = TextEditingController();
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const TitleText('Marquer comme payé', fontSize: 18),
            content: TextField(controller: refCtrl, style: basicTextStyle(fontSize: 14), decoration: InputDecoration(labelText: 'Référence virement (optionnel)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const MediumText('Annuler', fontSize: 14)),
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)), onPressed: () => Navigator.pop(ctx, true), child: const MediumText('Confirmer', fontSize: 14, color: Colors.white)),
            ],
          ),
        );
        if (confirmed == true) {
          final ok = await ref.read(payoutsListProvider.notifier).markPaid(payout.id, refCtrl.text.trim().isEmpty ? null : refCtrl.text.trim());
          _snack(context, ok ? 'Payout marqué payé' : 'Erreur', ok);
          if (ok) onRefresh();
        }
        break;
      case 'dispute':
        final ok = await ref.read(payoutsListProvider.notifier).disputePayout(payout.id);
        _snack(context, ok ? 'Payout contesté' : 'Erreur', ok);
        if (ok) onRefresh();
        break;
    }
  }

  void _snack(BuildContext context, String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: MediumText(msg, color: Colors.white), backgroundColor: success ? Colors.green : Colors.red));
  }
}

// ============================================================
// Payout Row
// ============================================================

class _PayoutRow extends StatelessWidget {
  final PayoutModel payout;
  final bool isMobile;
  final NumberFormat currencyFormat;
  final DateFormat dateFormat;
  final Function(String) onAction;

  const _PayoutRow({required this.payout, required this.isMobile, required this.currencyFormat, required this.dateFormat, required this.onAction});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return InkWell(
        onTap: () => onAction('detail'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(payout.producerName, style: mediumTextStyle(fontSize: 15))),
              _StatusBadge(label: payout.statusLabel, color: _statusColor(payout.status)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Text(payout.sourceLabel, style: basicTextStyle(fontSize: 12, color: AppColors.colorGrayDark)),
              const SizedBox(width: 8),
              Text(payout.periodStart, style: basicTextStyle(fontSize: 12, color: AppColors.colorGrayDark)),
              const Spacer(),
              Text('${currencyFormat.format(payout.producerAmount)} ${payout.currency}', style: boldTextStyle(fontSize: 14)),
            ]),
          ]),
        ),
      );
    }

    return InkWell(
      onTap: () => onAction('detail'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
        child: Row(children: [
          Expanded(flex: 3, child: Text(payout.producerName, style: mediumTextStyle(fontSize: 14))),
          Expanded(flex: 2, child: Text(payout.sourceLabel, style: basicTextStyle(fontSize: 13))),
          Expanded(flex: 2, child: Text(payout.periodStart, style: basicTextStyle(fontSize: 13))),
          Expanded(flex: 2, child: Text('${currencyFormat.format(payout.producerAmount)} ${payout.currency}', style: boldTextStyle(fontSize: 13))),
          Expanded(flex: 2, child: _StatusBadge(label: payout.statusLabel, color: _statusColor(payout.status))),
          SizedBox(
            width: 120,
            child: Row(children: [
              if (payout.status == 'pending' || payout.status == 'calculated')
                Tooltip(message: 'Approuver', child: IconButton(onPressed: () => onAction('approve'), icon: Icon(LucideIcons.circleCheck, size: 18, color: const Color(0xFF10B981)))),
              if (payout.status == 'approved')
                Tooltip(message: 'Marquer payé', child: IconButton(onPressed: () => onAction('pay'), icon: Icon(LucideIcons.banknote, size: 18, color: AppColors.colorBluePrimary))),
              if (payout.status != 'paid' && payout.status != 'disputed')
                Tooltip(message: 'Contester', child: IconButton(onPressed: () => onAction('dispute'), icon: Icon(LucideIcons.triangleAlert, size: 18, color: AppColors.colorRedSecondary))),
            ]),
          ),
        ]),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'paid': return const Color(0xFF10B981);
      case 'approved': return AppColors.colorBluePrimary;
      case 'pending': case 'calculated': return const Color(0xFFF59E0B);
      case 'disputed': return AppColors.colorRedSecondary;
      default: return AppColors.colorGrayDark;
    }
  }
}

// ============================================================
// Payout Detail Dialog
// ============================================================

class _PayoutDetailDialog extends ConsumerWidget {
  final String payoutId;
  const _PayoutDetailDialog({required this.payoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(payoutDetailProvider(payoutId));
    final currencyFormat = NumberFormat('#,###', 'fr_FR');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: detailAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(LucideIcons.badgeAlert, color: AppColors.colorRedSecondary, size: 40),
            const SizedBox(height: 12),
            Text('Erreur: $e', style: basicTextStyle(color: AppColors.colorRedSecondary)),
            TextButton(onPressed: () => Navigator.pop(context), child: const MediumText('Fermer')),
          ]),
          data: (payout) => SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text('Payout — ${payout.producerName}', style: boldTextStyle(fontSize: 20))),
              _StatusBadge(label: payout.statusLabel, color: payout.status == 'paid' ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x, size: 20)),
            ]),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _InfoRow('Source', payout.sourceLabel),
            _InfoRow('Période', '${payout.periodStart} → ${payout.periodEnd}'),
            _InfoRow('CA Brut', '${currencyFormat.format(payout.grossRevenue)} ${payout.currency}'),
            _InfoRow('Part plateforme', '${payout.platformSharePct}% — ${currencyFormat.format(payout.platformAmount)} ${payout.currency}'),
            _InfoRow('Part producteur', '${currencyFormat.format(payout.producerAmount)} ${payout.currency}'),
            if (payout.totalWatchMinutes > 0) _InfoRow('Minutes visionnées', '${currencyFormat.format(payout.totalWatchMinutes)}'),
            if (payout.totalRentals > 0) _InfoRow('Locations', '${payout.totalRentals}'),
            if (payout.paymentRef != null) _InfoRow('Réf. virement', payout.paymentRef!),
            if (payout.paidAt != null) _InfoRow('Payé le', DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(DateTime.parse(payout.paidAt!))),

            if (payout.details != null && payout.details!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Détails par contenu (${payout.details!.length})', style: boldTextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              ...payout.details!.map((d) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(d.contentTitle, style: mediumTextStyle(fontSize: 14)),
                    Text(
                      [
                        if (d.watchMinutes > 0) '${currencyFormat.format(d.watchMinutes)} min',
                        if (d.rentalCount > 0) '${d.rentalCount} locations',
                        if (d.adImpressions > 0) '${d.adImpressions} pubs',
                      ].join(' • '),
                      style: basicTextStyle(fontSize: 12, color: AppColors.colorGrayDark),
                    ),
                  ])),
                  Text('${currencyFormat.format(d.revenueShare)} ${payout.currency}', style: boldTextStyle(fontSize: 14)),
                ]),
              )),
            ],

            const SizedBox(height: 16),
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.pop(context), child: const MediumText('Fermer', fontSize: 14))),
          ])),
        ),
      ),
    );
  }
}

// ============================================================
// Shared
// ============================================================

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: mediumTextStyle(fontSize: 12, color: color)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 140, child: Text(label, style: basicTextStyle(fontSize: 13, color: AppColors.colorGrayDark))),
      Expanded(child: Text(value, style: mediumTextStyle(fontSize: 13))),
    ]));
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
      itemBuilder: (ctx) => options.entries.map((e) => PopupMenuItem<String?>(value: e.key, child: Row(children: [
        if (e.key == value) Icon(LucideIcons.check, size: 16, color: AppColors.colorBluePrimary) else const SizedBox(width: 16),
        const SizedBox(width: 8),
        Text(e.value, style: basicTextStyle(fontSize: 14)),
      ]))).toList(),
      child: Container(
        height: 44, padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: value != null ? AppColors.colorBluePrimary.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: value != null ? AppColors.colorBluePrimary.withOpacity(0.3) : Colors.grey.shade300),
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
