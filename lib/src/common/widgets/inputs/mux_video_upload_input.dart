import 'dart:async';
import 'dart:js_interop';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/* -------------------------------------------------------------------------- */
/*  NOTE : ce fichier utilise package:web (dart:js_interop), donc il ne       */
/*  compile que pour la cible web — cohérent avec le fait que ton dashboard   */
/*  admin est exclusivement Flutter Web. Si un jour ce widget doit tourner    */
/*  aussi sur mobile/desktop, il faudra l'isoler derrière une abstraction     */
/*  conditionnelle (fichier _web.dart / _io.dart + import conditionnel).      */
/* -------------------------------------------------------------------------- */

/// Résultat final, une fois la vidéo prête côté Mux (après le webhook).
class MuxVideoUploadResult {
  final String videoId;
  final String? playbackId;
  final int? durationSeconds;
  final String? thumbnailUrl;

  MuxVideoUploadResult({
    required this.videoId,
    this.playbackId,
    this.durationSeconds,
    this.thumbnailUrl,
  });
}

enum _UploadState { idle, initiating, uploading, processing, ready, failed }

/// Champ d'upload vidéo générique, en chunks resumables :
///   sélection de fichier -> découpage en morceaux de 5 Mo -> PUT successifs
///   avec Content-Range vers l'URL Mux -> polling du statut une fois le
///   dernier octet confirmé.
///
/// Réutilisable pour les 4 scénarios (film, épisode, trailer, aperçu) :
/// c'est l'appelant qui fournit l'endpoint d'initiation et le corps de la
/// requête. Le backend ne change pas du tout entre la version "PUT simple"
/// et celle-ci : l'URL Mux accepte les deux, seul le comportement du client
/// change.
class MuxVideoUploadInput extends StatefulWidget {
  /// Client Dio dédié à TON API (avec le token d'auth admin en interceptor).
  /// Ne sert JAMAIS à l'upload vers Mux lui-même — un Dio nu est créé en
  /// interne pour ça, justement pour ne pas envoyer ton token d'auth à Mux.
  final Dio apiDio;

  final String initiateUploadEndpoint;
  final Map<String, dynamic> initiateUploadBody;
  final String label;
  final ValueChanged<MuxVideoUploadResult?> onCompleted;

  const MuxVideoUploadInput({
    super.key,
    required this.apiDio,
    required this.initiateUploadEndpoint,
    required this.onCompleted,
    this.initiateUploadBody = const {},
    this.label = 'Vidéo',
  });

  @override
  State<MuxVideoUploadInput> createState() => _MuxVideoUploadInputState();
}

class _MuxVideoUploadInputState extends State<MuxVideoUploadInput> {
  // Taille de chunk : doit être un multiple de 256 Ko (contrainte du
  // protocole resumable de Google Cloud Storage, qui héberge les uploads
  // Mux). 5 Mo = la valeur par défaut utilisée par upchunk, la lib de Mux.
  static const int _chunkSize = 5 * 1024 * 1024;
  static const int _maxConsecutiveFailures = 5;

  _UploadState _state = _UploadState.idle;
  double _uploadProgress = 0;
  String? _fileName;
  String? _errorMessage;
  Timer? _pollTimer;
  bool _cancelled = false;

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cancelled = true;
    super.dispose();
  }

  /* ---------------------------- Sélection fichier -------------------------- */

  Future<web.File?> _pickVideoFile() {
    final input = web.HTMLInputElement()
      ..type = 'file'
      ..accept = 'video/*';

    final completer = Completer<web.File?>();
    input.addEventListener(
      'change',
          (web.Event event) {
        final files = input.files;
        completer.complete(
          files != null && files.length > 0 ? files.item(0) : null,
        );
      }.toJS,
    );
    input.click();
    return completer.future;
  }

  /* ------------------------------- Flux principal --------------------------- */

  Future<void> _pickAndUpload() async {
    final file = await _pickVideoFile();
    if (file == null) return;

    setState(() {
      _state = _UploadState.initiating;
      _fileName = file.name;
      _errorMessage = null;
      _uploadProgress = 0;
    });
    widget.onCompleted(null);

    try {
      // 1. Demander l'URL d'upload à notre backend (inchangé)
      final initResponse = await widget.apiDio.post(
        widget.initiateUploadEndpoint,
        data: {...widget.initiateUploadBody, 'originalFilename': file.name},
      );
      final initData = initResponse.data['item'] as Map<String, dynamic>;
      final videoId = initData['videoId'] as String;
      final uploadUrl = initData['uploadUrl'] as String;

      // 2. Upload en chunks, directement vers Mux
      if (mounted) setState(() => _state = _UploadState.uploading);
      await _uploadInChunks(uploadUrl, file);
      if (_cancelled) return;

      // 3. Le fichier est chez Mux, on attend le webhook en pollant le statut
      if (mounted) setState(() => _state = _UploadState.processing);
      _startPolling(videoId);
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _UploadState.failed;
          _errorMessage = "Échec de l'upload : $e";
        });
      }
    }
  }

  Future<void> _uploadInChunks(String uploadUrl, web.File file) async {
    final total = file.size;
    var offset = 0;
    var consecutiveFailures = 0;
    final uploadDio = Dio(); // nu : jamais le token de notre propre API

    while (offset < total) {
      if (_cancelled) return;
      final end = (offset + _chunkSize < total) ? offset + _chunkSize : total;

      try {
        final blob = file.slice(offset, end);
        final arrayBuffer = await blob.arrayBuffer().toDart;
        final bytes = arrayBuffer.toDart.asUint8List();

        final response = await uploadDio.put(
          uploadUrl,
          data: bytes,
          options: Options(
            headers: {
              Headers.contentLengthHeader: bytes.length,
              'Content-Range': 'bytes $offset-${end - 1}/$total',
            },
            // GCS répond 308 tant que l'upload n'est pas terminé — ce n'est
            // pas une erreur, dio le traiterait comme telle par défaut.
            validateStatus: (s) => s != null && (s == 200 || s == 201 || s == 308),
          ),
        );

        consecutiveFailures = 0;

        if (response.statusCode == 200 || response.statusCode == 201) {
          offset = total; // dernier chunk confirmé, upload terminé
        } else {
          // 308 : on avance à la position que le serveur confirme avoir
          // reçue — ne JAMAIS supposer que tout ce qu'on a envoyé est arrivé.
          offset = _confirmedOffset(response, fallback: end);
        }

        if (mounted) setState(() => _uploadProgress = offset / total);
      } catch (_) {
        consecutiveFailures++;
        if (consecutiveFailures > _maxConsecutiveFailures) {
          throw Exception('trop de tentatives échouées sur ce chunk');
        }
        await Future.delayed(Duration(seconds: consecutiveFailures * 2));

        // Coupure réseau : on ne sait pas si le chunk qu'on vient d'envoyer
        // est arrivé juste avant la coupure. Plutôt que de le renvoyer en
        // aveugle, on sonde Mux pour connaître la position réelle.
        final confirmed = await _probeOffset(uploadDio, uploadUrl, total);
        if (confirmed != null) offset = confirmed;
        // sinon : on retente le même chunk au prochain tour de boucle
      }
    }
  }

  int _confirmedOffset(Response response, {required int fallback}) {
    final rangeHeader = response.headers.value('range'); // "bytes=0-5242879"
    if (rangeHeader == null) return fallback;
    final match = RegExp(r'bytes=\d+-(\d+)').firstMatch(rangeHeader);
    return match != null ? int.parse(match.group(1)!) + 1 : fallback;
  }

  /// PUT vide avec Content-Range: bytes */total — interroge Mux sur ce qu'il
  /// a réellement reçu jusqu'ici. Renvoie null si la sonde elle-même échoue
  /// (on retente alors simplement au tour de boucle suivant).
  Future<int?> _probeOffset(Dio uploadDio, String uploadUrl, int total) async {
    try {
      final response = await uploadDio.put(
        uploadUrl,
        options: Options(
          headers: {Headers.contentLengthHeader: 0, 'Content-Range': 'bytes */$total'},
          validateStatus: (s) => s != null && (s == 200 || s == 201 || s == 308),
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) return total;
      return _confirmedOffset(response, fallback: 0);
    } catch (_) {
      return null;
    }
  }

  /* --------------------------------- Polling --------------------------------- */

  void _startPolling(String videoId) {
    var attempts = 0;
    const maxAttempts = 200; // ~200 * 3s = 10 min

    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      attempts++;
      if (attempts > maxAttempts) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _state = _UploadState.failed;
            _errorMessage = 'Traitement trop long — vérifie le statut plus tard.';
          });
        }
        return;
      }

      try {
        final response = await widget.apiDio.get('/admin/contents/videos/$videoId');
        final data = response.data['item'] as Map<String, dynamic>;
        final status = data['status'] as String;

        if (status == 'ready') {
          timer.cancel();
          final result = MuxVideoUploadResult(
            videoId: videoId,
            playbackId: data['mux_playback_id'] as String?,
            durationSeconds: (data['duration_seconds'] as num?)?.round(),
            thumbnailUrl: data['thumbnailUrl'] as String?,
          );
          if (mounted) setState(() => _state = _UploadState.ready);
          widget.onCompleted(result);
        } else if (status == 'failed') {
          timer.cancel();
          if (mounted) {
            setState(() {
              _state = _UploadState.failed;
              _errorMessage = data['error_message'] as String? ?? 'Le traitement a échoué chez Mux.';
            });
          }
        }
        // sinon (pending/uploading/transcoding) : on continue de poller
      } catch (_) {
        // erreur réseau ponctuelle : on retente au prochain tick
      }
    });
  }

  void _retry() {
    _pollTimer?.cancel();
    setState(() {
      _state = _UploadState.idle;
      _errorMessage = null;
      _uploadProgress = 0;
    });
    widget.onCompleted(null);
  }

  /* ---------------------------------- UI -------------------------------------- */

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        _buildContent(),
      ],
    );
  }

  Widget _buildContent() {
    switch (_state) {
      case _UploadState.idle:
        return OutlinedButton.icon(
          onPressed: _pickAndUpload,
          icon: const Icon(Icons.upload_file),
          label: const Text('Choisir un fichier vidéo'),
        );

      case _UploadState.initiating:
        return const Row(
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text("Préparation de l'upload..."),
          ],
        );

      case _UploadState.uploading:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_fileName ?? ''),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: _uploadProgress),
            const SizedBox(height: 4),
            Text('${(_uploadProgress * 100).toStringAsFixed(0)}%'),
          ],
        );

      case _UploadState.processing:
        return const Row(
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Fichier envoyé — traitement en cours chez Mux (quelques minutes selon la taille)...',
              ),
            ),
          ],
        );

      case _UploadState.ready:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green.shade200),
            borderRadius: BorderRadius.circular(8),
            color: Colors.green.shade50,
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              const Text('Vidéo prête'),
              const Spacer(),
              TextButton(onPressed: _retry, child: const Text('Remplacer')),
            ],
          ),
        );

      case _UploadState.failed:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_errorMessage ?? 'Erreur inconnue', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _retry, child: const Text('Réessayer')),
          ],
        );
    }
  }
}