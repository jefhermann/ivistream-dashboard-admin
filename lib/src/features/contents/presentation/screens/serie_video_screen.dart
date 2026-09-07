import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../common/common.dart';

/// Ouvre [SeriesVideosScreen] dans un WoltModalSheet plutôt qu'en navigation
/// plein écran — dialog sur large écran (desktop web), bottom sheet en
/// dessous de 700px.
Future<void> showSeriesVideosModal(
    BuildContext context, {
      required Dio apiDio,
      required String contentId,
      required String contentTitle,
    }) {
  return WoltModalSheet.show<void>(
    context: context,
    modalTypeBuilder: responsiveModalType,
    pageListBuilder: (modalSheetContext) => [
      WoltModalSheetPage(
        topBarTitle: Text(contentTitle),
        isTopBarLayerAlwaysVisible: true,
        trailingNavBarWidget: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(modalSheetContext).pop(),
        ),
        child: SeriesVideosScreen(apiDio: apiDio, contentId: contentId),
      ),
    ],
  );
}

/// Contenu de gestion des vidéos d'une série : liste des saisons, chacune
/// dépliée sur ses épisodes (statut + miniature), avec les points d'entrée
/// pour ajouter une saison ou un épisode. Contrairement au film/documentaire
/// (une seule vidéo), une série a une structure à deux niveaux — d'où
/// l'appel à GET /contents/:contentId/seasons qui renvoie tout l'arbre en
/// une fois. Prévu pour vivre DANS un WoltModalSheetPage (voir
/// showSeriesVideosModal ci-dessus) plutôt que comme écran plein-page — pas
/// de Scaffold/AppBar ici, Wolt fournit déjà le chrome et le scroll externe.
class SeriesVideosScreen extends StatefulWidget {
  final Dio apiDio;
  final String contentId;

  const SeriesVideosScreen({
    super.key,
    required this.apiDio,
    required this.contentId,
  });

  @override
  State<SeriesVideosScreen> createState() => _SeriesVideosScreenState();
}

class _SeriesVideosScreenState extends State<SeriesVideosScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _seasons = [];

  @override
  void initState() {
    super.initState();
    _loadSeasons();
  }

  Future<void> _loadSeasons() async {
    setState(() => _loading = true);
    try {
      final response = await widget.apiDio.get('/admin/contents/${widget.contentId}/seasons');
      setState(() {
        _seasons = (response.data['items'] as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _openAddSeason() async {
    final nextNumber = _seasons.isEmpty
        ? 1
        : (_seasons.map((s) => s['number'] as int).reduce((a, b) => a > b ? a : b) + 1);

    final created = await WoltModalSheet.show<bool>(
      context: context,
      modalTypeBuilder: responsiveModalType,
      pageListBuilder: (modalSheetContext) => [
        WoltModalSheetPage(
          topBarTitle: const Text('Ajouter une saison'),
          isTopBarLayerAlwaysVisible: true,
          resizeToAvoidBottomInset: true,
          trailingNavBarWidget: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(modalSheetContext).pop(),
          ),
          child: _AddSeasonSheet(
            apiDio: widget.apiDio,
            contentId: widget.contentId,
            nextNumber: nextNumber,
          ),
        ),
      ],
    );
    if (created == true) _loadSeasons();
  }

  Future<void> _openAddEpisode(int seasonNumber) async {
    final created = await WoltModalSheet.show<bool>(
      context: context,
      modalTypeBuilder: responsiveModalType,
      pageListBuilder: (modalSheetContext) => [
        WoltModalSheetPage(
          topBarTitle: Text('Saison $seasonNumber — nouvel épisode'),
          isTopBarLayerAlwaysVisible: true,
          resizeToAvoidBottomInset: true,
          trailingNavBarWidget: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(modalSheetContext).pop(),
          ),
          child: _AddEpisodeSheet(
            apiDio: widget.apiDio,
            contentId: widget.contentId,
            seasonNumber: seasonNumber,
          ),
        ),
      ],
    );
    if (created == true) _loadSeasons();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: _openAddSeason,
            icon: const Icon(Icons.add),
            label: const Text('Saison'),
          ),
          if (_seasons.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('Aucune saison pour l’instant.'),
            )
          else
            ..._seasons.map(_buildSeasonCard),
        ],
      ),
    );
  }

  Widget _buildSeasonCard(Map<String, dynamic> season) {
    final episodes = (season['episodes'] as List).cast<Map<String, dynamic>>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(season['title'] as String? ?? 'Saison ${season['number']}'),
        subtitle: Text('${episodes.length} épisode${episodes.length > 1 ? 's' : ''}'),
        children: [
          ...episodes.map(_buildEpisodeTile),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _openAddEpisode(season['number'] as int),
                icon: const Icon(Icons.add),
                label: const Text('Épisode'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeTile(Map<String, dynamic> episode) {
    final status = episode['videoStatus'] as String?;
    final thumbnailUrl = episode['thumbnailUrl'] as String?;

    return ListTile(
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
      title: Text('${episode['number']}. ${episode['title']}'),
      subtitle: Text(_statusLabel(status)),
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
}

/* -------------------------------------------------------------------------- */
/*  Ajout de saison — métadonnées seules, pas de vidéo                       */
/* -------------------------------------------------------------------------- */

class _AddSeasonSheet extends StatefulWidget {
  final Dio apiDio;
  final String contentId;
  final int nextNumber;

  const _AddSeasonSheet({
    required this.apiDio,
    required this.contentId,
    required this.nextNumber,
  });

  @override
  State<_AddSeasonSheet> createState() => _AddSeasonSheetState();
}

class _AddSeasonSheetState extends State<_AddSeasonSheet> {
  late final TextEditingController _numberController =
  TextEditingController(text: widget.nextNumber.toString());
  final TextEditingController _titleController = TextEditingController();
  bool _submitting = false;
  String? _error;

  Future<void> _submit() async {
    final number = int.tryParse(_numberController.text);
    if (number == null) {
      setState(() => _error = 'Numéro de saison invalide');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await widget.apiDio.post(
        '/admin/contents/${widget.contentId}/seasons',
        data: {
          'number': number,
          if (_titleController.text.trim().isNotEmpty) 'title': _titleController.text.trim(),
        },
      );
      if (mounted) Navigator.of(context).pop(true);
    } on DioException catch (e) {
      setState(() {
        _submitting = false;
        _error = (e.response?.data?['message'] as String?) ?? "Échec de la création";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _numberController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Numéro'),
            onChanged: (_) => setState(() {}), // pour rafraîchir le hint du titre
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Titre (optionnel)',
              hintText: 'Saison ${_numberController.text}',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Créer'),
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*  Ajout d'épisode — métadonnées + upload vidéo groupés                     */
/* -------------------------------------------------------------------------- */

class _AddEpisodeSheet extends StatefulWidget {
  final Dio apiDio;
  final String contentId;
  final int seasonNumber;

  const _AddEpisodeSheet({
    required this.apiDio,
    required this.contentId,
    required this.seasonNumber,
  });

  @override
  State<_AddEpisodeSheet> createState() => _AddEpisodeSheetState();
}

class _AddEpisodeSheetState extends State<_AddEpisodeSheet> {
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _numberController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Numéro d'épisode"),
            // Rebuild à chaque frappe : initiateUploadBody ci-dessous doit
            // lire la valeur à jour au moment où l'admin choisit le fichier,
            // pas celle capturée au premier rendu de cette feuille.
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Titre'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          MuxVideoUploadInput(
            apiDio: widget.apiDio,
            initiateUploadEndpoint: '/admin/contents/${widget.contentId}/episodes/upload',
            initiateUploadBody: {
              'seasonNumber': widget.seasonNumber,
              'episodeNumber': int.tryParse(_numberController.text) ?? 0,
              'title': _titleController.text.trim(),
              'description': _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
            },
            label: 'Vidéo',
            onCompleted: (result) {
              if (result == null) return; // reset/relance d'upload : on reste sur la feuille
              // On laisse l'admin voir le badge "prêt" un instant avant de
              // refermer, plutôt que de faire disparaître la feuille d'un coup.
              Future.delayed(const Duration(milliseconds: 800), () {
                if (mounted) Navigator.of(context).pop(true);
              });
            },
          ),
        ],
      ),
    );
  }
}