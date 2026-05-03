import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../common/common.dart';
import '../../dashboard.dart';

@RoutePage()
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final recentUsersAsync = ref.watch(recentUsersProvider);
    final recentContentsAsync = ref.watch(recentContentsProvider);
    final isMobile = ResponsiveLayout.isMobile(context);
    final formatter = NumberFormat('#,###', 'fr_FR');

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: boldTextStyle(fontSize: isMobile ? 22 : 28)),
          const SizedBox(height: 4),
          Text('Vue d\'ensemble de la plateforme', style: basicTextStyle(color: AppColors.colorGrayDark)),
          const SizedBox(height: 24),

          // ============================================================
          // Stats Cards
          // ============================================================
          statsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorCard(message: e.toString()),
            data: (stats) => _StatsGrid(stats: stats, formatter: formatter, isMobile: isMobile),
          ),

          const SizedBox(height: 32),

          // ============================================================
          // Recent Users & Recent Contents
          // ============================================================
          if (isMobile) ...[
            _RecentUsersCard(asyncData: recentUsersAsync),
            const SizedBox(height: 16),
            _RecentContentsCard(asyncData: recentContentsAsync),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _RecentUsersCard(asyncData: recentUsersAsync)),
                const SizedBox(width: 16),
                Expanded(child: _RecentContentsCard(asyncData: recentContentsAsync)),
              ],
            ),
        ],
      ),
    );
  }
}

// ============================================================
// Stats Grid
// ============================================================

class _StatsGrid extends StatelessWidget {
  final AdminStatsModel stats;
  final NumberFormat formatter;
  final bool isMobile;

  const _StatsGrid({required this.stats, required this.formatter, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCardData(
        icon: LucideIcons.users,
        label: 'Utilisateurs',
        value: formatter.format(stats.totalUsers),
        subtitle: '${formatter.format(stats.activeUsers)} actifs',
        color: AppColors.colorBluePrimary,
      ),
      _StatCardData(
        icon: LucideIcons.building2,
        label: 'Producteurs',
        value: formatter.format(stats.totalProducers),
        color: const Color(0xFF10B981),
      ),
      _StatCardData(
        icon: LucideIcons.clapperboard,
        label: 'Contenus',
        value: formatter.format(stats.totalContents),
        subtitle: '${formatter.format(stats.publishedContents)} publiés',
        color: const Color(0xFFF59E0B),
      ),
      _StatCardData(
        icon: LucideIcons.eye,
        label: 'Vues totales',
        value: formatter.format(stats.totalViews),
        color: const Color(0xFF8B5CF6),
      ),
      _StatCardData(
        icon: LucideIcons.clock,
        label: 'Minutes regardées',
        value: formatter.format(stats.totalWatchMinutes),
        color: const Color(0xFFEC4899),
      ),
      _StatCardData(
        icon: LucideIcons.creditCard,
        label: 'Abonnements actifs',
        value: formatter.format(stats.activeSubscriptions),
        color: const Color(0xFF06B6D4),
      ),
    ];

    if (isMobile) {
      return Column(
        children: cards.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _StatCard(data: c),
        )).toList(),
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: cards.map((c) => SizedBox(
        width: (MediaQuery.of(context).size.width - 240 - 48 - 32 - 32) / 3,
        child: _StatCard(data: c),
      )).toList(),
    );
  }
}

class _StatCardData {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color color;

  _StatCardData({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    required this.color,
  });
}

class _StatCard extends StatelessWidget {
  final _StatCardData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.label, style: basicTextStyle(color: AppColors.colorGrayDark, fontSize: 13)),
                const SizedBox(height: 4),
                Text(data.value, style: boldTextStyle(fontSize: 22)),
                if (data.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(data.subtitle!, style: basicTextStyle(color: AppColors.colorGrayDark, fontSize: 12)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Recent Users Card
// ============================================================

class _RecentUsersCard extends StatelessWidget {
  final AsyncValue<List<RecentUserModel>> asyncData;

  const _RecentUsersCard({required this.asyncData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.userPlus, size: 20, color: AppColors.colorBluePrimary),
              const SizedBox(width: 8),
              const TitleText('Derniers inscrits', fontSize: 16),
            ],
          ),
          const SizedBox(height: 16),
          asyncData.when(
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            )),
            error: (e, _) => _ErrorCard(message: e.toString()),
            data: (users) {
              if (users.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: MediumText('Aucun utilisateur')),
                );
              }
              return Column(
                children: users.map((user) => _UserTile(user: user)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final RecentUserModel user;

  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.colorBluePrimary.withOpacity(0.1),
            child: Text(
              (user.fullName.isNotEmpty ? user.fullName[0] : 'U').toUpperCase(),
              style: boldTextStyle(color: AppColors.colorBluePrimary, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName, style: mediumTextStyle(fontSize: 14)),
                Text(user.email, style: basicTextStyle(color: AppColors.colorGrayDark, fontSize: 12)),
              ],
            ),
          ),
          if (user.trialStatus != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: user.trialStatus == 'active'
                    ? const Color(0xFF10B981).withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user.trialStatus == 'active' ? 'Essai' : user.trialStatus ?? '',
                style: basicTextStyle(
                  fontSize: 11,
                  color: user.trialStatus == 'active' ? const Color(0xFF10B981) : AppColors.colorGrayDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// Recent Contents Card
// ============================================================

class _RecentContentsCard extends StatelessWidget {
  final AsyncValue<List<RecentContentModel>> asyncData;

  const _RecentContentsCard({required this.asyncData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.film, size: 20, color: AppColors.colorBluePrimary),
              const SizedBox(width: 8),
              const TitleText('Derniers contenus', fontSize: 16),
            ],
          ),
          const SizedBox(height: 16),
          asyncData.when(
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            )),
            error: (e, _) => _ErrorCard(message: e.toString()),
            data: (contents) {
              if (contents.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: MediumText('Aucun contenu')),
                );
              }
              return Column(
                children: contents.map((c) => _ContentTile(content: c)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ContentTile extends StatelessWidget {
  final RecentContentModel content;

  const _ContentTile({required this.content});

  String get _typeLabel {
    switch (content.type) {
      case 'movie':
        return 'Film';
      case 'series':
        return 'Série';
      case 'documentary':
        return 'Documentaire';
      case 'short':
        return 'Court-métrage';
      default:
        return content.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(LucideIcons.clapperboard, color: Color(0xFFF59E0B), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(content.title, style: mediumTextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                Text(_typeLabel, style: basicTextStyle(color: AppColors.colorGrayDark, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: content.status == 'published'
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : const Color(0xFFF59E0B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              content.status == 'published' ? 'Publié' : 'Brouillon',
              style: basicTextStyle(
                fontSize: 11,
                color: content.status == 'published' ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Error Card
// ============================================================

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.colorRedSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.badgeAlert, color: AppColors.colorRedSecondary, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: basicTextStyle(color: AppColors.colorRedSecondary, fontSize: 13))),
        ],
      ),
    );
  }
}
