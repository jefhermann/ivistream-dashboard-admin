import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ivistream_dashboard_admin/src/config/app_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../common/common.dart';
import '../../../auth/application/application.dart';
import '../../contents.dart';

@RoutePage()
class ContentDetailScreen extends ConsumerWidget {
  final String contentId;

  const ContentDetailScreen({super.key, required this.contentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(contentDetailProvider(contentId));
    final isMobile = ResponsiveLayout.isMobile(context);
    final formatter = NumberFormat('#,###', 'fr_FR');

    return detailAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) {
        debugPrintStack(stackTrace: _);
        return Center(child: MediumText('Erreur: $e'));
      },
      data: (content) {
        if (content == null) {
          return const Center(child: MediumText('Contenu introuvable'));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec retour
              Row(
                children: [
                  Expanded(
                    child: Text(
                      content.title ?? "",
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusChip(content.status ?? ""),
                ],
              ),
              const SizedBox(height: 24),

              // Layout principal
              isMobile ? _MobileDetail(content: content, formatter: formatter) : _DesktopDetail(content: content, formatter: formatter),
            ],
          ),
        );
      },
    );
  }
}

class _DesktopDetail extends ConsumerStatefulWidget {
  final AdminContentModel content;
  final NumberFormat formatter;

  const _DesktopDetail({required this.content, required this.formatter});

  @override
  ConsumerState<_DesktopDetail> createState() => _DesktopDetailState();
}

class _DesktopDetailState extends ConsumerState<_DesktopDetail> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bouton retour
        TextButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft, size: 18),
          label: const Text('Retour aux contenus'),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: widget.content.posterUrl != null
                      ? Image.network(
                          widget.content.posterUrl!,
                          width: 280,
                          height: 400,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const _PosterPlaceholder(),
                        )
                      : const _PosterPlaceholder(),
                ),
                Spacers.min,
                Row(
                  children: [
                    Tooltip(
                        message: 'Modifier',
                        child: IconButton(onPressed: () => _onAction(widget.content, 'edit'), icon: const Icon(LucideIcons.pencil, size: 18, color: Colors.grey))),
                    if (widget.content.status == 'draft' || widget.content.status == 'archived')
                      Tooltip(
                          message: 'Publier',
                          child: IconButton(onPressed: () => _onAction(widget.content, 'publish'), icon: const Icon(LucideIcons.send, size: 18, color: Color(0xFF10B981)))),
                    if (widget.content.status == 'published')
                      Tooltip(
                          message: 'Archiver',
                          child: IconButton(
                              onPressed: () => _onAction(widget.content, 'archive'), icon: const Icon(LucideIcons.archive, size: 18, color: AppColors.colorRedSecondary))),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 32),

            // Détails
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatsSection(content: widget.content),
                  const SizedBox(height: 24),
                  _RevenuePayoutSection(content: widget.content),
                  const SizedBox(height: 24),
                  _DetailSection(content: widget.content),
                  const SizedBox(height: 24),
                  _CastSection(content: widget.content),
                  const SizedBox(height: 24),
                  if (widget.content.isMovie) _MovieSection(content: widget.content) else if (widget.content.isSeries) _SeriesSection(content: widget.content),
                  const SizedBox(height: 24),
                  _PromoVideosSection(content: widget.content),
                  const SizedBox(height: 24),
                  // _PricingSection(content: widget.content, formatter: widget.formatter),
                  // const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onAction(AdminContentModel content, String action) async {
    switch (action) {
      case 'publish':
        final confirmed = await _confirm('Publier "${content.title}" ?', 'Le contenu sera visible par les utilisateurs.');
        if (confirmed) {
          if (content.id == null) break;
          final ok = await ref.read(contentsListProvider.notifier).publishContent(content.id!);
          _snack(ok ? 'Contenu publié' : 'Erreur', ok);
        }
        break;
      case 'archive':
        final confirmed = await _confirm('Archiver "${content.title}" ?', 'Le contenu ne sera plus visible.');
        if (confirmed) {
          if (content.id == null) break;
          final ok = await ref.read(contentsListProvider.notifier).archiveContent(content.id!);
          _snack(ok == true ? 'Contenu archivé' : 'Erreur', ok!);
        }
        break;
      case 'edit':
        context.router.push(EditContentRoute(content: content));
        break;
    }
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
}

class _MobileDetail extends StatelessWidget {
  final AdminContentModel content;
  final NumberFormat formatter;

  const _MobileDetail({required this.content, required this.formatter});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Poster centré
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: content.posterUrl != null
                ? Image.network(
                    content.posterUrl!,
                    width: 200,
                    height: 280,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _PosterPlaceholder(width: 200, height: 280),
                  )
                : const _PosterPlaceholder(width: 200, height: 280),
          ),
        ),
        const SizedBox(height: 24),
        _RevenueSection(contentId: content.id ?? "", formatter: formatter),
        const SizedBox(height: 24),
        // _InfoCards(content: content, formatter: formatter),
        // const SizedBox(height: 24),
        _DetailSection(content: content),
        const SizedBox(height: 24),
        _CastSection(content: content),
        const SizedBox(height: 24),
        _PricingSection(content: content, formatter: formatter),
      ],
    );
  }
}

class _StatsSection extends ConsumerWidget {
  final AdminContentModel content;

  const _StatsSection({required this.content});

  @override
  Widget build(BuildContext context, ref) {
    final contentId = content.id ?? '';
    final stats = ref.watch(contentStatsProvider(contentId));
    final formatter = NumberFormat.decimalPattern('fr');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Statistiques', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        stats.when(
          data: (data) {
            if (data == null) {
              return const Text('Aucune donnée pour l’instant.');
            }

            final totalViews = data.totalViews ?? 0;
            final totalWatchMinutes = data.averageWatchMinutes ?? 0;
            final uniqueViewers = data.uniqueViewers ?? 0;
            final completionRate = data.completionRate ?? 0;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _MiniCard(
                  label: 'Vues totales',
                  value: formatter.format(totalViews),
                  icon: Icons.visibility_outlined,
                ),
                _MiniCard(
                  label: 'Minutes visionnées',
                  value: formatter.format(totalWatchMinutes),
                  icon: Icons.timer_outlined,
                ),
                _MiniCard(
                  label: 'Spectateurs uniques',
                  value: formatter.format(uniqueViewers),
                  icon: Icons.people_outline,
                ),
                _MiniCard(
                  label: 'Taux de complétion',
                  value: '${(completionRate * 100).toStringAsFixed(0)}%',
                  icon: Icons.check_circle_outline,
                ),
                // data['mux'] reste null tant que l'intégration Mux Data
                // n'est pas branchée côté backend — pas de carte pour
                // l'instant, à ajouter quand ces métriques arriveront
                // (temps de démarrage, rebuffering...).
              ],
            );
          },
          error: (err, st) {
            debugPrint(st.toString());
            return const Center(child: Text('Une erreur est survenue'));
          },
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Icon(icon, size: 20, color: Colors.blueAccent),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final AdminContentModel content;

  const _DetailSection({required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _DetailRow('Pays d\'origine', _typeLabel(content.country?.name ?? "")),
            _DetailRow('Type', _typeLabel(content.type ?? "")),
            _DetailRow('Accès', content.access == 'premium' ? 'Premium' : 'Gratuit'),
            _DetailRow('Maturité', content.maturity ?? ""),
            _DetailRow('Année', content.releaseYear?.toString() ?? '-'),
            if (content.description != null) ...[
              const SizedBox(height: 12),
              const Text('Synopsis', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text(content.description!, style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
            ],
            if (content.genres != null && content.genres!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: content.genres!
                    .map<Widget>((g) => Chip(
                          label: Text(g.name ?? "N/A", style: const TextStyle(fontSize: 12)),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CastSection extends StatelessWidget {
  final AdminContentModel content;

  const _CastSection({required this.content});

  @override
  Widget build(BuildContext context) {
    if ((content.actors.isEmpty) && (content.directors.isEmpty)) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Équipe', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            if (content.directors.isNotEmpty) ...[
              const Text('Réalisation', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: content.directors
                    .map<Widget>((d) => Chip(
                          avatar: const Icon(Icons.movie_creation, size: 16),
                          label: Text(d.name ?? "N/A", style: const TextStyle(fontSize: 12)),
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (content.actors.isNotEmpty) ...[
              const Text('Acteurs', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: content.actors
                    .map<Widget>((a) => Chip(
                          avatar: const Icon(Icons.person, size: 16),
                          label: Text(a.name ?? "N/A", style: const TextStyle(fontSize: 12)),
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PricingSection extends StatelessWidget {
  final AdminContentModel content;
  final NumberFormat formatter;

  const _PricingSection({required this.content, required this.formatter});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prix de location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 16),
            // if (content.rentalPriceAfrica != null) _DetailRow('Zone Afrique', '${formatter.format(content.rentalPriceAfrica)} XOF'),
            // if (content.rentalPriceIntl != null) _DetailRow('Zone Internationale', '${content.rentalPriceIntl} EUR'),
            // if (content.rentalPriceAfrica == null && content.rentalPriceIntl == null) Text('Aucun prix configuré', style: TextStyle(color: Colors.grey.shade600)),
          ],
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  final double width;
  final double height;

  const _PosterPlaceholder({this.width = 280, this.height = 400});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.movie, size: 48, color: Colors.grey),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'published' => ('Publié', Colors.green),
      'draft' => ('Brouillon', Colors.amber),
      'archived' => ('Archivé', Colors.grey),
      _ => (status, Colors.grey),
    };
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
      backgroundColor: color,
    );
  }
}

class _RevenueSection extends ConsumerWidget {
  final String contentId;
  final NumberFormat formatter;

  const _RevenueSection({required this.contentId, required this.formatter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (authState.user?.role == 'viewer') return const SizedBox.shrink();

    final payoutsAsync = ref.watch(contentPayoutsProvider(contentId));

    return Column(
      children: [
        const SizedBox(height: 24),
        payoutsAsync.when(
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (summary) {
            if (summary == null || summary.details.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Revenus', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Text('Aucun revenu enregistré', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              );
            }

            final totalRevenue = summary.totalRevenue;
            final totalMinutes = summary.totalWatchMinutes;
            final totalRentals = summary.totalRentals;
            final details = summary.details;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Revenus', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),

                    // Totaux
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        _RevenueMini(label: 'Total gagné', value: '${formatter.format(totalRevenue)} XOF', color: Colors.green),
                        _RevenueMini(label: 'Minutes', value: formatter.format(totalMinutes), color: Colors.purple),
                        _RevenueMini(label: 'Locations', value: formatter.format(totalRentals), color: Colors.orange),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Liste par période
                    ...details.map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d.payout != null ? '${_sourceLabel(d.payout!.source)} · ${d.payout!.periodStart}' : 'Période inconnue',
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      '${d.watchMinutes} min · ${d.rentalCount} locations',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${formatter.format(d.revenueShare)} XOF',
                                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RevenueMini extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _RevenueMini({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}

class _MovieSection extends ConsumerWidget {
  final AdminContentModel content;

  const _MovieSection({required this.content});

  @override
  Widget build(BuildContext context, ref) {
    final videos = ref.watch(contentVideosProvider(content.id ?? ''));
    final appDio = ref.read(dioProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Vidéos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    await showAddMovieVideoModal(
                      context,
                      apiDio: appDio,
                      contentId: content.id ?? '',
                      contentTitle: content.title ?? '',
                    ).then((_) {
                      ref.invalidate(contentVideosProvider(content.id ?? ''));
                    });
                  },
                  label: const MediumText(
                    "Ajouter la Vidéo",
                    fontSize: 14,
                  ),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 20),
            videos.when(
                data: (data) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: data?.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (ctx, index) {
                      final video = data?[index];

                      return Column(
                        children: [
                          Row(
                            children: [
                              if (video?.thumbnailUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(video!.thumbnailUrl!, width: 96, height: 54, fit: BoxFit.cover),
                                )
                              else
                                Container(
                                  width: 116,
                                  height: 74,
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  child: const Icon(Icons.movie_outlined),
                                ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        TitleText(
                                          video?.title ?? '',
                                        ),
                                        const SizedBox(width: 4),
                                        BodyText("(${video?.roleLabel ?? ''})"),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    BodyText("Durée: ${video?.durationFormatted ?? ''}"),
                                    const SizedBox(height: 2),
                                    BodyText("Résolution: ${video?.resolution ?? ''}")
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  );
                },
                error: (err, st) {
                  debugPrintStack();
                  return const Center(child: Text('Une erreur est survenue'));
                },
                loading: () => const CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

class _SeriesSection extends ConsumerWidget {
  final AdminContentModel content;

  const _SeriesSection({required this.content});

  @override
  Widget build(BuildContext context, ref) {
    final contentId = content.id ?? '';
    final seasons = ref.watch(contentSeasonsProvider(contentId));
    final appDio = ref.read(dioProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Saisons & épisodes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    final numbers = seasons.value?.map((s) => s.number as int).toList() ?? <int>[];
                    final nextNumber = numbers.isEmpty ? 1 : (numbers.reduce((a, b) => a > b ? a : b) + 1);

                    await showAddSeasonModal(
                      context,
                      apiDio: appDio,
                      contentId: contentId,
                      nextNumber: nextNumber,
                    ).then((_) => ref.invalidate(contentSeasonsProvider(contentId)));
                  },
                  label: const MediumText('Ajouter une saison', fontSize: 14),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 20),
            seasons.when(
              data: (data) {
                final list = data ?? [];
                if (list.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Aucune saison pour l’instant.'),
                  );
                }
                return Column(
                  children: list
                      .map((season) => _SeasonTile(
                            season: season,
                            contentId: contentId,
                            appDio: appDio,
                            onEpisodeAdded: () => ref.invalidate(contentSeasonsProvider(contentId)),
                          ))
                      .toList(),
                );
              },
              error: (err, st) {
                debugPrintStack();
                return const Center(child: Text('Une erreur est survenue'));
              },
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeasonTile extends StatelessWidget {
  final dynamic season; // adapte au type réel (SeasonModel...)
  final String contentId;
  final Dio appDio;
  final VoidCallback onEpisodeAdded;

  const _SeasonTile({
    required this.season,
    required this.contentId,
    required this.appDio,
    required this.onEpisodeAdded,
  });

  @override
  Widget build(BuildContext context) {
    final episodes = (season.episodes as List?) ?? [];

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 8),
      title: Text(
        season.title as String? ?? 'Saison ${season.number}',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text('${episodes.length} épisode${episodes.length > 1 ? 's' : ''}'),
      children: [
        ...episodes.map((ep) => _EpisodeTile(episode: ep)),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () async {
                await showAddEpisodeModal(
                  context,
                  apiDio: appDio,
                  contentId: contentId,
                  seasonNumber: season.number as int,
                ).then((_) => onEpisodeAdded());
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ajouter un épisode'),
            ),
          ),
        ),
      ],
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  final dynamic episode; // adapte au type réel (EpisodeModel...)

  const _EpisodeTile({required this.episode});

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = episode.thumbnailUrl as String?;
    final status = episode.videoStatus as String?;
    final duration = episode.durationSeconds as int?;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 56,
        height: 32,
        child: thumbnailUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(thumbnailUrl, fit: BoxFit.cover),
              )
            : Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  status == null ? Icons.videocam_off_outlined : Icons.hourglass_empty,
                  size: 16,
                ),
              ),
      ),
      title: Text('${episode.number}. ${episode.title ?? ''}'),
      subtitle: Text(duration != null ? '${_statusLabel(status)} · ${_formatDuration(duration)}' : _statusLabel(status)),
    );
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'ready':
        return 'Vidéo prête';
      case 'failed':
        return 'Échec du traitement';
      case null:
        return 'Aucune vidéo';
      default:
        return 'En cours ($status)';
    }
  }

  String _formatDuration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}h${m.toString().padLeft(2, '0')}';
    return '${m}min';
  }
}

// À coller dans content_detail_screen.dart, à côté de _MovieSection et
// _SeriesSection — cette section-ci ne dépend PAS du type de contenu
// (film, série, documentaire...), donc à afficher inconditionnellement.
//
// Réutilise le même contentVideosProvider que _MovieSection (une seule
// requête GET /contents/:contentId/videos, filtrée par rôle côté client) —
// pas besoin d'un provider séparé.
//
// Import requis :
//   import 'promo_videos_screen.dart'; // showAddPromoVideoModal
//
// ⚠️ Rappel : si tu gardais jusqu'ici le bouton "Ajouter un trailer/preview"
// et l'appel à showPromoVideosModal DANS _MovieSection, retire-les de là —
// cette section les remplace. Pense aussi à filtrer la liste de
// _MovieSection sur role == 'main' uniquement, puisque trailers/aperçus
// s'affichent maintenant ici.

class _PromoVideosSection extends ConsumerWidget {
  final AdminContentModel content;

  const _PromoVideosSection({required this.content});

  @override
  Widget build(BuildContext context, ref) {
    final contentId = content.id ?? '';
    final videos = ref.watch(contentVideosProvider(contentId));
    final appDio = ref.read(dioProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bandes-annonces & aperçus', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            videos.when(
              data: (data) {
                final all = data ?? [];
                final trailers = all.where((v) => v.role == 'trailer').toList();
                final previews = all.where((v) => v.role == 'preview').toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSubSection(
                      context: context,
                      ref: ref,
                      title: 'Bandes-annonces',
                      role: 'trailer',
                      items: trailers,
                      contentId: contentId,
                      appDio: appDio,
                    ),
                    const SizedBox(height: 20),
                    _buildSubSection(
                      context: context,
                      ref: ref,
                      title: 'Aperçus',
                      role: 'preview',
                      items: previews,
                      contentId: contentId,
                      appDio: appDio,
                    ),
                  ],
                );
              },
              error: (err, st) {
                debugPrintStack();
                return const Center(child: Text('Une erreur est survenue'));
              },
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubSection({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String role,
    required List<dynamic> items, // adapte au type réel (VideoModel...)
    required String contentId,
    required Dio appDio,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            TextButton.icon(
              onPressed: () async {
                await showAddPromoVideoModal(
                  context,
                  apiDio: appDio,
                  contentId: contentId,
                  role: role,
                ).then((_) => ref.invalidate(contentVideosProvider(contentId)));
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ajouter'),
            ),
          ],
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Aucune vidéo pour l’instant.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          )
        else
          ...items.map((video) => _PromoVideoTile(video: video)),
      ],
    );
  }
}

class _PromoVideoTile extends StatelessWidget {
  final dynamic video; // adapte au type réel (VideoModel...)

  const _PromoVideoTile({required this.video});

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = video.thumbnailUrl as String?;
    final status = video.status as String?;
    final duration = video.durationSeconds as int?;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 56,
        height: 32,
        child: thumbnailUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(thumbnailUrl, fit: BoxFit.cover),
              )
            : Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.hourglass_empty, size: 16),
              ),
      ),
      title: Text(_statusLabel(status)),
      subtitle: duration != null ? Text(_formatDuration(duration)) : null,
    );
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'ready':
        return 'Vidéo prête';
      case 'failed':
        return 'Échec du traitement';
      default:
        return 'En cours ($status)';
    }
  }

  String _formatDuration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}h${m.toString().padLeft(2, '0')}';
    return '${m}min';
  }
}

class _RevenuePayoutSection extends ConsumerWidget {
  final AdminContentModel content;

  const _RevenuePayoutSection({required this.content});

  @override
  Widget build(BuildContext context, ref) {
    final contentId = content.id ?? '';
    final payout = ref.watch(contentPayoutsProvider(contentId));
    final formatter = NumberFormat.decimalPattern('fr');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Revenus & location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _RentalPriceRow(content: content),
            const SizedBox(height: 20),
            payout.when(
              data: (data) {
                if (data == null) return const Text('Aucune donnée pour l’instant.');

                final totalRevenue = data.totalRevenue ?? 0;
                final totalWatchMinutes = data.totalWatchMinutes ?? 0;
                final totalRentals = data.totalRentals ?? 0;
                final details = data.details;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _MiniCard(
                          label: 'Revenu total',
                          value: '${formatter.format(totalRevenue)} FCFA',
                          icon: Icons.payments_outlined,
                        ),
                        _MiniCard(
                          label: 'Locations totales',
                          value: formatter.format(totalRentals),
                          icon: Icons.shopping_cart_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Détail', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    if (details.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Aucune transaction pour l’instant.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      )
                    else
                      ...details.map((d) => _PayoutDetailTile(detail: d as Map<String, dynamic>)),
                  ],
                );
              },
              error: (err, st) {
                debugPrintStack();
                return const Center(child: Text('Une erreur est survenue'));
              },
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ligne prix de location — affichage simple, bascule en édition inline sur
/// tap, enregistre via PATCH /:contentId/rental-price.
class _RentalPriceRow extends ConsumerStatefulWidget {
  final AdminContentModel content;

  const _RentalPriceRow({required this.content});

  @override
  ConsumerState<_RentalPriceRow> createState() => _RentalPriceRowState();
}

class _RentalPriceRowState extends ConsumerState<_RentalPriceRow> {
  bool _editing = false;
  bool _saving = false;
  late final TextEditingController _controller = TextEditingController(
    text: widget.content.rentalPrice?.toStringAsFixed(2) ?? '',
  );

  Future<void> _save() async {
    final price = double.tryParse(_controller.text.replaceAll(',', '.'));
    if (price == null || price < 0) return;

    setState(() => _saving = true);
    final appDio = ref.read(dioProvider);
    try {
      await appDio.patch(
        '/admin/contents/${widget.content.id}/rental-price',
        data: {'price': price},
      );
      if (mounted) {
        setState(() {
          _editing = false;
          _saving = false;
        });
        // Adapte au nom réel de ton provider de détail de contenu, pour que
        // le nouveau prix s'affiche sans recharger toute la page à la main.
        ref.invalidate(contentDetailProvider(widget.content.id ?? ''));
      }
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_editing) {
      final price = widget.content.rentalPrice;
      return Row(
        children: [
          Text(
            price != null
                ? 'Prix de location : ${price.toStringAsFixed(2)} FCFA'
                : 'Aucun prix de location défini',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: () => setState(() => _editing = true),
          ),
        ],
      );
    }

    return Row(
      children: [
        SizedBox(
          width: 120,
          child: TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Prix'),
          ),
        ),
        const SizedBox(width: 8),
        _saving
            ? const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : IconButton(icon: const Icon(Icons.check), onPressed: _save),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() => _editing = false),
        ),
      ],
    );
  }
}

class _PayoutDetailTile extends StatelessWidget {
  final Map<String, dynamic> detail;

  const _PayoutDetailTile({required this.detail});

  @override
  Widget build(BuildContext context) {
    final amount = detail['amount'] as num?;
    final date = detail['date'] as String?;
    final type = detail['type'] as String?;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(type ?? 'Transaction'),
      subtitle: date != null ? Text(date) : null,
      trailing: amount != null ? Text('${amount.toStringAsFixed(2)} FCFA') : null,
    );
  }
}

String _sourceLabel(String source) {
  return switch (source) {
    'subscription' => 'Abonnements',
    'rental' => 'Locations',
    'advertising' => 'Publicité',
    _ => source,
  };
}

String _typeLabel(String type) {
  return switch (type) {
    'movie' => 'Film',
    'series' => 'Série',
    'documentary' => 'Documentaire',
    'short' => 'Court-métrage',
    _ => type,
  };
}
