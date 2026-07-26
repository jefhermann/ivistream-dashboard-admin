import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../common/common.dart';
import '../../country.dart';

@RoutePage()
class CountryScreen extends ConsumerStatefulWidget {
  const CountryScreen({super.key});

  @override
  ConsumerState<CountryScreen> createState() => _CountryScreenState();
}

class _CountryScreenState extends ConsumerState<CountryScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final AsyncValue<CountryListState> gendersAsync = ref.watch(countryListProvider);
    final filters = ref.watch(countryFilterProvider);

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
                    Text('Genres', style: boldTextStyle(fontSize: isMobile ? 22 : 28)),
                    const SizedBox(height: 4),
                    Text(
                      gendersAsync.maybeWhen(
                        data: (state) => state.pagination != null ? '${state.pagination!.total} genres au total' : '0 producteur',
                        orElse: () => 'Chargement...',
                      ),
                      style: basicTextStyle(color: AppColors.colorGrayDark),
                    ),
                  ],
                ),
              ),
              if (!isMobile)
                ElevatedButton.icon(
                  onPressed: () => _showAddDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorBluePrimary,
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
                  label: Text(isMobile ? 'Ajouter' : 'Nouveau pays', style: mediumTextStyle(fontSize: 14, color: Colors.white)),
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
                        _searchController,
                        hintText: 'Rechercher un pays',
                        onChanged: (value) {
                          ref.read(countryFilterProvider.notifier).update((state) => state.copyWith(
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
                              _searchController.clear();
                              ref.invalidate(countryFilterProvider);
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
          gendersAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
            error: (error, _) => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.colorRedSecondary.withValues(alpha: .1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(LucideIcons.badgeAlert, color: AppColors.colorRedSecondary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(error.toString(), style: basicTextStyle(color: AppColors.colorRedSecondary, fontSize: 13))),
                  TextButton(
                    onPressed: () => ref.invalidate(countryFilterProvider), // Force le re-trigger
                    child: Text('Réessayer', style: mediumTextStyle(fontSize: 13, color: AppColors.colorBluePrimary)),
                  ),
                ],
              ),
            ),
            data: (state) {
              if (state.country.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(LucideIcons.building2, size: 40, color: AppColors.colorGrayDark),
                        const SizedBox(height: 12),
                        Text('Aucun genre trouvé', style: mediumTextStyle(color: AppColors.colorGrayDark)),
                      ],
                    ),
                  ),
                );
              }

              return TableWidget<CountryModel>(
                items: state.country,
                pagination: state.pagination!,
                currentPage: filters.page,
                onRowTap: (item) => _showDetailsDialog(item),
                goToPage: (int page) {
                  ref.read(countryFilterProvider.notifier).update((state) => state.copyWith(page: page));
                },
                actionBuilder: (item) => Row(
                  children: [
                    Tooltip(
                      message: 'Modifier',
                      child: IconButton(
                        icon: const Icon(LucideIcons.pencil, size: 18, color: AppColors.colorBluePrimary),
                        onPressed: () => _showEditDialog(context, item),
                      ),
                    ),
                    Tooltip(
                      message: item.isActive == true ? 'Désactiver' : 'Activer',
                      child: IconButton(
                        onPressed: () => _onToggleActive(item.code ?? '', zone: item.zone ?? "", name: item.name ?? "", isActive: item.isActive == true ? false : true),
                        icon: Icon(
                          item.isActive == true ? LucideIcons.shieldOff : LucideIcons.shieldCheck,
                          size: 18,
                          color: item.isActive == true ? AppColors.colorRedSecondary : const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
                showPagination: state.pagination != null && state.pagination!.totalPages > 1,
                columns: [
                  TableColumn(
                    label: 'Nom',
                    flex: 1, // cette colonne prend 2x la place
                    cell: (u) => Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: Text(u.code?.toUpperCase() ?? "", style: boldTextStyle(color: const Color(0xFF10B981), fontSize: 16))),
                        ),
                        Spacers.sw1,
                        Text(
                          u.name ?? "",
                          style: boldTextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  TableColumn(
                    label: 'zone',
                    flex: 1,
                    cell: (u) => Text(u.zone ?? "", style: basicTextStyle(fontSize: 13)),
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

  void _onToggleActive(String id, {String? name, bool? isActive, String? zone}) {
    final controller = ref.read(countryListProvider.notifier);
    controller.updateCountry(id, name: name, isActive: isActive, zone: zone);
  }

  void _showEditDialog(BuildContext context, CountryModel item) {
    final nameCtrl = TextEditingController(text: item.name);
    final codeCtrl = TextEditingController(text: item.code);
    bool isActive = item.isActive ?? false;
    bool zone = item.zone == "africa" ? true : false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, StateSetter setDialogState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: TitleText('Modifier ${item.name}', fontSize: 18),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTextField(controller: nameCtrl, label: 'Nom'),
                Spacers.min,
                DialogTextField(controller: codeCtrl, label: 'Code'),
                Spacers.min,
                DropdownButtonFormField<bool>(
                    isExpanded: true,
                    padding: EdgeInsets.zero,
                    decoration: InputDecoration(
                      hintText: "Zone",
                      labelText: "Zone",
                      hintStyle: basicTextStyle(color: AppColors.colorGrayDark, fontSize: 20),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                    initialValue: zone,
                    items: ["Afrique", "Internationale"].map((e) => DropdownMenuItem(value: e == "Afrique", child: Text(e))).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        zone = value!;
                      });
                    }),
                Spacers.min,
                DropdownButtonFormField<bool>(
                    isExpanded: true,
                    padding: EdgeInsets.zero,
                    decoration: InputDecoration(
                      hintText: "Statut",
                      labelText: "Statut",
                      hintStyle: basicTextStyle(color: AppColors.colorGrayDark, fontSize: 20),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                    initialValue: isActive,
                    items: ["Activé", "Désactivé"].map((e) => DropdownMenuItem(value: e == "Activé", child: Text(e))).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        isActive = value!;
                      });
                    }),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const MediumText('Annuler', fontSize: 14)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.colorBluePrimary),
              onPressed: () async {
                debugPrint("isActive => $isActive");
                Navigator.pop(ctx);
                final ok = await ref.read(countryListProvider.notifier).updateCountry(
                      item.code ?? "",
                      name: nameCtrl.text.trim(),
                      isActive: isActive,
                      zone: zone == true ? "africa" : "international",
                      code: codeCtrl.text.trim(),
                    );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: MediumText(ok ? 'Genre modifié' : 'Erreur', color: Colors.white),
                    backgroundColor: ok ? Colors.green : Colors.red,
                  ));
                }
              },
              child: const MediumText('Modifier', fontSize: 14, color: Colors.white),
            ),
          ],
        );
      }),
    );
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    bool zone = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, StateSetter setDialogState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const TitleText('Créer un pays', fontSize: 18),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BasicInput(nameCtrl, text: 'Nom'),
                BasicInput(codeCtrl, text: 'Code'),
                DropdownButtonFormField<bool>(
                    isExpanded: true,
                    padding: EdgeInsets.zero,
                    decoration: InputDecoration(
                      hintText: "Zone",
                      labelText: "Zone",
                      hintStyle: basicTextStyle(color: AppColors.colorGrayDark, fontSize: 20),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                    initialValue: zone,
                    items: ["Afrique", "Internationale"].map((e) => DropdownMenuItem(value: e == "Afrique", child: Text(e))).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        zone = value!;
                      });
                    }),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const MediumText('Annuler', fontSize: 14)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.colorBluePrimary),
              onPressed: () async {
                Navigator.pop(ctx);
                final ok = await ref.read(countryListProvider.notifier).createCountry(
                      country: CountryModel(name: nameCtrl.text.trim(), code: codeCtrl.text.trim(), zone: zone == true ? "africa" : "international"),
                    );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: MediumText(ok ? 'Genre créer' : 'Erreur', color: Colors.white),
                    backgroundColor: ok ? Colors.green : Colors.red,
                  ));
                }
              },
              child: const MediumText('Ajouter', fontSize: 14, color: Colors.white),
            ),
          ],
        );
      }),
    );
  }

  void _showDetailsDialog(CountryModel item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
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
                        decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: .1), borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Text(item.code ?? "", style: boldTextStyle(color: const Color(0xFF10B981), fontSize: 22))),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: Text(item.name ?? "", style: boldTextStyle(fontSize: 20))),
                            Spacers.sw10,
                            if (item.isActive == true)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: .1), borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(LucideIcons.badgeCheck, size: 14, color: Color(0xFF10B981)),
                                    const SizedBox(width: 4),
                                    Text('Actif', style: mediumTextStyle(fontSize: 11, color: const Color(0xFF10B981))),
                                  ],
                                ),
                              ),
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
                  InfoRowWidget('Code', item.code ?? "-"),
                  InfoRowWidget('Nom', item.name ?? "-"),
                  InfoRowWidget('Zone', item.zone == "africa" ? "Afrique" : "International"),

                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: () => Navigator.pop(context), child: const MediumText('Fermer', fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
