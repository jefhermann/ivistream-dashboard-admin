import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../common/common.dart';
import '../../../auth/auth.dart';
import '../../../../config/app_router.dart';

@RoutePage()
class DashboardShellScreen extends ConsumerWidget {
  const DashboardShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AutoTabsRouter(
      routes: const [
        DashboardRoute(),
        UsersRoute(),
        ContentsRoute(),
        ProducersRoute(),
        RevenuesRoute(),
        AdminTeamRoute(),
      ],
      builder: (context, child) {
        final isMobile = ResponsiveLayout.isMobile(context);

        if (isMobile) {
          return _MobileShell(child: child);
        }
        return _DesktopShell(child: child);
      },
    );
  }
}

// ============================================================
// Desktop Shell
// ============================================================

class _DesktopShell extends ConsumerWidget {
  final Widget child;
  const _DesktopShell({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final isTablet = ResponsiveLayout.isTablet(context);
    final tabsRouter = AutoTabsRouter.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundBodyLightColor,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: isTablet ? 72 : 240,
            color: AppColors.backgroundBodyLightColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                if (!isTablet) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.colorBluePrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text('IS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const TitleText('IviStream', fontSize: 20, color: AppColors.colorBluePrimary),
                      ],
                    ),
                  ),
                ] else ...[
                  Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.colorBluePrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('IS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                if (!isTablet)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.colorRedSecondary.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ADMIN',
                        style: boldTextStyle(color: AppColors.colorRedSecondary, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Nav items
                _NavItem(icon: LucideIcons.layoutDashboard, label: 'Dashboard', isActive: tabsRouter.activeIndex == 0, compact: isTablet, onTap: () => tabsRouter.setActiveIndex(0)),
                _NavItem(icon: LucideIcons.users, label: 'Utilisateurs', isActive: tabsRouter.activeIndex == 1, compact: isTablet, onTap: () => tabsRouter.setActiveIndex(1)),
                _NavItem(icon: LucideIcons.clapperboard, label: 'Contenus', isActive: tabsRouter.activeIndex == 2, compact: isTablet, onTap: () => tabsRouter.setActiveIndex(2)),
                _NavItem(icon: LucideIcons.building2, label: 'Producteurs', isActive: tabsRouter.activeIndex == 3, compact: isTablet, onTap: () => tabsRouter.setActiveIndex(3)),
                _NavItem(icon: LucideIcons.handCoins, label: 'Revenus', isActive: tabsRouter.activeIndex == 4, compact: isTablet, onTap: () => tabsRouter.setActiveIndex(4)),
                if (authState.user?.role == 'super_admin')
                  _NavItem(icon: LucideIcons.shield, label: 'Équipe Admin', isActive: tabsRouter.activeIndex == 5, compact: isTablet, onTap: () => tabsRouter.setActiveIndex(5)),

                const Spacer(),

                _NavItem(
                  icon: LucideIcons.logOut,
                  label: 'Déconnexion',
                  isActive: false,
                  compact: isTablet,
                  onTap: () => _showLogoutDialog(context, ref),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundBodyLightColor,
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      if (authState.user != null) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MediumText(
                              authState.user!.fullName ?? '',
                              fontSize: 19,
                            ),
                            const SizedBox(height: 2),
                            TitleText(
                              authState.user!.roleLabel,
                              fontSize: 13,
                              color: AppColors.colorBluePrimary,
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.colorBluePrimary,
                          child: TitleText(
                            (authState.user!.fullName ?? 'A')[0].toUpperCase(),
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Content area
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Mobile Shell
// ============================================================

class _MobileShell extends ConsumerWidget {
  final Widget child;
  const _MobileShell({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final tabsRouter = AutoTabsRouter.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundBodyLightColor,
      appBar: AppBar(
        title: const Text('IviStream Admin'),
      ),
      drawer: Drawer(
        child: Container(
          color: AppColors.backgroundBodyLightColor,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TitleText('IviStream Admin', fontSize: 22),
                      if (authState.user != null) ...[
                        const SizedBox(height: 8),
                        MediumText(authState.user?.fullName ?? '', fontSize: 14),
                        MediumText(authState.user?.email ?? '', fontSize: 12),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.colorRedSecondary.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            authState.user!.roleLabel,
                            style: boldTextStyle(color: AppColors.colorRedSecondary, fontSize: 11),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(),
                _NavItem(icon: LucideIcons.layoutDashboard, label: 'Dashboard', isActive: tabsRouter.activeIndex == 0, onTap: () { Navigator.pop(context); tabsRouter.setActiveIndex(0); }),
                _NavItem(icon: LucideIcons.users, label: 'Utilisateurs', isActive: tabsRouter.activeIndex == 1, onTap: () { Navigator.pop(context); tabsRouter.setActiveIndex(1); }),
                _NavItem(icon: LucideIcons.clapperboard, label: 'Contenus', isActive: tabsRouter.activeIndex == 2, onTap: () { Navigator.pop(context); tabsRouter.setActiveIndex(2); }),
                _NavItem(icon: LucideIcons.building2, label: 'Producteurs', isActive: tabsRouter.activeIndex == 3, onTap: () { Navigator.pop(context); tabsRouter.setActiveIndex(3); }),
                _NavItem(icon: LucideIcons.handCoins, label: 'Revenus', isActive: tabsRouter.activeIndex == 4, onTap: () { Navigator.pop(context); tabsRouter.setActiveIndex(4); }),
                if (authState.user?.role == 'super_admin')
                  _NavItem(icon: LucideIcons.shield, label: 'Équipe Admin', isActive: tabsRouter.activeIndex == 5, onTap: () { Navigator.pop(context); tabsRouter.setActiveIndex(5); }),
                const Spacer(),
                _NavItem(icon: LucideIcons.logOut, label: 'Déconnexion', isActive: false, onTap: () => _showLogoutDialog(context, ref)),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: child,
      ),
    );
  }
}

// ============================================================
// Nav Item
// ============================================================

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool compact;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    this.compact = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 0 : 20,
          vertical: 12,
        ),
        color: isActive ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
        child: compact
            ? Center(child: Tooltip(message: label, child: Icon(icon, color: isActive ? AppColors.colorBluePrimary : Colors.black, size: 30)))
            : Row(
                children: [
                  Icon(icon, color: isActive ? AppColors.colorBluePrimary : Colors.black, size: 20),
                  const SizedBox(width: 12),
                  MediumText(
                    label,
                    color: isActive ? AppColors.colorBluePrimary : Colors.black,
                    fontSize: 20,
                  ),
                ],
              ),
      ),
    );
  }
}

// ============================================================
// Logout Dialog
// ============================================================

void _showLogoutDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const TitleText('Déconnexion'),
      content: const MediumText('Voulez-vous vous déconnecter ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const MediumText('Annuler'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          onPressed: () {
            Navigator.pop(ctx);
            ref.read(authControllerProvider.notifier).logout();
            // auto_route guard will redirect to login
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: MediumText('Déconnexion réussie', color: Colors.white),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: const MediumText('Quitter', color: Colors.white),
        ),
      ],
    ),
  );
}
