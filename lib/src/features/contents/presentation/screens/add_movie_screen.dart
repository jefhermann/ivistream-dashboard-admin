import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../../common/common.dart';

/// Ouvre [AddMovieVideoScreen] dans un WoltModalSheet — dialog sur large
/// écran (desktop web), bottom sheet en dessous de 700px. Le résultat
/// renvoyé (`MuxVideoUploadResult?`) est celui passé à `Navigator.pop` par
/// le bouton "Terminer" une fois la vidéo prête.
Future<MuxVideoUploadResult?> showAddMovieVideoModal(
    BuildContext context, {
      required Dio apiDio,
      required String contentId,
      required String contentTitle,
    }) {
  return WoltModalSheet.show<MuxVideoUploadResult?>(
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
        child: AddMovieVideoScreen(apiDio: apiDio, contentId: contentId),
      ),
    ],
  );
}

/// Contenu d'ajout de la vidéo principale d'un film, documentaire ou
/// court-métrage. Les 3 types partagent exactement le même flux : une seule
/// vidéo par contenu, via /contents/:contentId/videos/main/upload — c'est
/// ce qui les distingue d'une série (épisodes multiples). Prévu pour vivre
/// DANS un WoltModalSheetPage (voir showAddMovieVideoModal ci-dessus) —
/// pas de Scaffold/AppBar ici, Wolt fournit déjà le titre et le scroll.
class AddMovieVideoScreen extends StatefulWidget {
  /// Client Dio authentifié vers TON API — jamais utilisé pour parler à Mux
  /// directement (voir MuxVideoUploadField, qui gère ça en interne).
  final Dio apiDio;
  final String contentId;

  const AddMovieVideoScreen({
    super.key,
    required this.apiDio,
    required this.contentId,
  });

  @override
  State<AddMovieVideoScreen> createState() => _AddMovieVideoScreenState();
}

class _AddMovieVideoScreenState extends State<AddMovieVideoScreen> {
  bool _loading = true;
  Map<String, dynamic>? _existingMain; // l'entrée role == 'main', si elle existe déjà
  bool _showUploadField = false;
  MuxVideoUploadResult? _result;

  @override
  void initState() {
    super.initState();
    _loadExistingVideo();
  }

  /// Vérifie si ce contenu a déjà une vidéo principale (ex: on rouvre
  /// l'écran d'édition d'un film déjà en ligne) plutôt que d'afficher le
  /// champ d'upload à l'aveugle à chaque ouverture.
  Future<void> _loadExistingVideo() async {
    try {
      final response = await widget.apiDio.get('/admin/contents/${widget.contentId}/videos');
      final items = (response.data['items'] as List).cast<Map<String, dynamic>>();

      Map<String, dynamic>? main;
      for (final item in items) {
        if (item['role'] == 'main') {
          main = item;
          break;
        }
      }

      setState(() {
        _existingMain = main;
        _showUploadField = main == null; // pas encore de vidéo -> champ direct
        _loading = false;
      });
    } catch (_) {
      // Si le check échoue, on ne bloque pas l'admin : il peut quand même uploader.
      setState(() {
        _showUploadField = true;
        _loading = false;
      });
    }
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
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vidéo principale',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (_existingMain != null && !_showUploadField)
            _buildExistingVideoCard()
          else
            MuxVideoUploadInput(
              apiDio: widget.apiDio,
              initiateUploadEndpoint: '/admin/contents/${widget.contentId}/videos/main/upload',
              label: 'Fichier vidéo',
              onCompleted: (result) => setState(() => _result = result),
            ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_result),
                child: const Text('Terminer'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExistingVideoCard() {
    final status = _existingMain!['status'] as String?;
    final thumbnailUrl = _existingMain!['thumbnailUrl'] as String?;
    final duration = _existingMain!['durationSeconds'] as int?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (thumbnailUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(thumbnailUrl, width: 96, height: 54, fit: BoxFit.cover),
            )
          else
            Container(
              width: 96,
              height: 54,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.movie_outlined),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status == 'ready' ? 'Vidéo prête' : 'Statut : ${status ?? 'inconnu'}'),
                if (duration != null) Text(_formatDuration(duration)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _showUploadField = true),
            child: const Text('Remplacer'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}h${m.toString().padLeft(2, '0')}';
    return '${m}min';
  }
}