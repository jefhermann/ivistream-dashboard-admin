import 'package:auto_route/auto_route.dart';
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
                  // _InfoCards(content: stats, formatter: formatter),
                  _RevenueSection(contentId: widget.content.id ?? "", formatter: widget.formatter),
                  const SizedBox(height: 24),
                  _DetailSection(content: widget.content),
                  const SizedBox(height: 24),
                  _CastSection(content: widget.content),
                  const SizedBox(height: 24),
                  _MovieSection(content: widget.content,),
                  const SizedBox(height: 24),
                  _PricingSection(content: widget.content, formatter: widget.formatter),
                  const SizedBox(height: 24),
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

class _InfoCards extends StatelessWidget {
  final dynamic content;
  final NumberFormat formatter;

  const _InfoCards({required this.content, required this.formatter});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _MiniCard(icon: Icons.visibility, label: 'Vues', value: formatter.format(content.totalWatchMinutes ?? 0)),
        _MiniCard(icon: Icons.timer, label: 'Minutes', value: formatter.format(content.watchMinutes)),
        _MiniCard(icon: Icons.favorite, label: 'Favoris', value: '${content.favorites}'),
        _MiniCard(icon: Icons.schedule, label: 'Durée', value: content.formattedDuration),
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                if (content.isMovie)
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
                    label: const MediumText("Ajouter la Vidéo", fontSize: 14,),
                    icon: const Icon(Icons.add),
                  ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () async {
                    await showPromoVideosModal(
                      context,
                      apiDio: appDio,
                      contentId: content.id ?? '',
                      contentTitle: content.title ?? '',
                    ).then((_) {
                      ref.invalidate(contentVideosProvider(content.id ?? ''));
                    });
                  },
                  label: const MediumText("Ajouter un trailer/preview", fontSize: 14,),
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
