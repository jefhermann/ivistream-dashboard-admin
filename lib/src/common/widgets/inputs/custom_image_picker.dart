import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CustomImagePicker extends StatefulWidget {
  final String label;
  final String? initialImageUrl; // Pour gérer le mode édition
  final double height;
  final double width;
  final Function(Uint8List? imageBytes, String? fileName) onImageSelected;
  final FormFieldValidator<Uint8List?>? validator; // 🚨 Le validateur injecté

  const CustomImagePicker({
    super.key,
    required this.label,
    required this.onImageSelected,
    this.initialImageUrl,
    this.validator,
    this.height = 200,
    this.width = double.infinity,
  });

  @override
  State<CustomImagePicker> createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  Uint8List? _localImageBytes;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(FormFieldState<Uint8List?> field) async {
    setState(() => _isLoading = true);

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1080,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();

        setState(() {
          _localImageBytes = bytes;
        });

        // 1. CRITIQUE : On notifie le FormField du nouveau binaire
        field.didChange(bytes);

        // 2. On notifie le widget parent
        widget.onImageSelected(bytes, pickedFile.name);
      }
    } catch (e) {
      debugPrint("Erreur lors de la sélection de l'image : $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible de charger cette image.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _removeImage(FormFieldState<Uint8List?> field) {
    setState(() => _localImageBytes = null);

    // On notifie le FormField qu'il n'y a plus rien
    field.didChange(null);
    widget.onImageSelected(null, null);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<Uint8List?>(
      initialValue: _localImageBytes,
      validator: widget.validator,
      builder: (FormFieldState<Uint8List?> field) {
        // Détermine si une image est visuellement présente (soit fraîchement choisie, soit distante)
        final bool hasImage = _localImageBytes != null ||
            (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: () => _pickImage(field),
              child: Container(
                height: widget.height,
                width: widget.width,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    // 🚨 Changement visuel strict en cas d'erreur de validation
                    color: field.hasError ? Colors.red.shade700 : Colors.grey.shade300,
                    width: field.hasError ? 2.0 : 1.0,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildImageContent(),
              ),
            ),

            if (hasImage)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _removeImage(field),
                  icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 16),
                  label: const Text('Retirer', style: TextStyle(color: Colors.red)),
                ),
              ),

            // 🚨 Affichage du message d'erreur rouge sous le composant
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  field.errorText!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildImageContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_localImageBytes != null) {
      return Image.memory(
        _localImageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }

    if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
      return Image.network(
        widget.initialImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(LucideIcons.imageOff, color: Colors.grey, size: 40),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(LucideIcons.upload, color: Colors.grey.shade400, size: 40),
        const SizedBox(height: 8),
        Text(
          "Cliquez pour ajouter ${widget.label.toLowerCase()}",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ],
    );
  }
}