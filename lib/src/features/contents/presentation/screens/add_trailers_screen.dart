import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../common/common.dart';

/// Ouvre [PromoVideosScreen] dans un WoltModalSheet — dialog sur large écran
/// (desktop web), bottom sheet en dessous de 700px.
Future<void> showPromoVideosModal(
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
        child: PromoVideosScreen(apiDio: apiDio, contentId: contentId),
      ),
    ],
  );
}

/// Contenu de gestion des bandes-annonces et aperçus d'un contenu — les deux
/// partagent le même modèle (content_videos, plusieurs par contenu, ordonnés
/// par position), donc une seule requête GET /contents/:contentId/videos
/// suffit, filtrée par rôle côté client pour les deux sections. Prévu pour
/// vivre DANS un WoltModalSheetPage (voir showPromoVideosModal ci-dessus).
class PromoVideosScreen extends StatefulWidget {
  final Dio apiDio;
  final String contentId;

  const PromoVideosScreen({
    super.key,
    required this.apiDio,
    required this.contentId,
  });

  @override
  State<PromoVideosScreen> createState() => _PromoVideosScreenState();
}

class _PromoVideosScreenState extends State<PromoVideosScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _trailers = [];
  List<Map<String, dynamic>> _previews = [];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() => _loading = true);
    try {
      final response = await widget.apiDio.get('/admin/contents/${widget.contentId}/videos');
      final items = (response.data['items'] as List).cast<Map<String, dynamic>>();
      setState(() {
        _trailers = items.where((v) => v['role'] == 'trailer').toList();
        _previews = items.where((v) => v['role'] == 'preview').toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _openAddPromo(String role) async {
    final created = await WoltModalSheet.show<bool>(
      context: context,
      modalTypeBuilder: responsiveModalType,
      pageListBuilder: (modalSheetContext) => [
        WoltModalSheetPage(
          topBarTitle: Text(role == 'trailer' ? 'Ajouter une bande-annonce' : 'Ajouter un aperçu'),
          isTopBarLayerAlwaysVisible: true,
          resizeToAvoidBottomInset: true,
          trailingNavBarWidget: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(modalSheetContext).pop(),
          ),
          child: _AddPromoVideoSheet(
            apiDio: widget.apiDio,
            contentId: widget.contentId,
            role: role,
          ),
        ),
      ],
    );
    if (created == true) _loadVideos();
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Bandes-annonces',
            role: 'trailer',
            items: _trailers,
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Aperçus',
            role: 'preview',
            items: _previews,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String role,
    required List<Map<String, dynamic>> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: () => _openAddPromo(role),
              icon: const Icon(Icons.add),
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
          ...items.map(_buildVideoTile),
      ],
    );
  }

  Widget _buildVideoTile(Map<String, dynamic> item) {
    final status = item['status'] as String?;
    final thumbnailUrl = item['thumbnailUrl'] as String?;
    final duration = item['durationSeconds'] as int?;

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

/* -------------------------------------------------------------------------- */
/*  Ajout d'une bande-annonce ou d'un aperçu — titre optionnel + upload      */
/* -------------------------------------------------------------------------- */

class _AddPromoVideoSheet extends StatefulWidget {
  final Dio apiDio;
  final String contentId;
  final String role; // 'trailer' | 'preview'

  const _AddPromoVideoSheet({
    required this.apiDio,
    required this.contentId,
    required this.role,
  });

  @override
  State<_AddPromoVideoSheet> createState() => _AddPromoVideoSheetState();
}

class _AddPromoVideoSheetState extends State<_AddPromoVideoSheet> {
  final TextEditingController _titleController = TextEditingController();

  String get _defaultTitle => widget.role == 'trailer' ? 'Bande-annonce' : 'Aperçu';
  String get _endpointSegment => widget.role == 'trailer' ? 'trailers' : 'previews';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Titre (optionnel)',
              hintText: _defaultTitle,
            ),
            // Rebuild à chaque frappe : initiateUploadBody ci-dessous doit
            // lire la valeur à jour au moment où l'admin choisit le fichier.
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          MuxVideoUploadInput(
            apiDio: widget.apiDio,
            initiateUploadEndpoint:
            '/admin/contents/${widget.contentId}/videos/$_endpointSegment/upload',
            initiateUploadBody: {
              if (_titleController.text.trim().isNotEmpty) 'title': _titleController.text.trim(),
            },
            label: 'Vidéo',
            onCompleted: (result) {
              if (result == null) return;
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