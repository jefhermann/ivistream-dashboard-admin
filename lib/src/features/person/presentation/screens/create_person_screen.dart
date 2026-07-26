import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/common.dart';
import '../../person.dart';

// 1. Isolation dans un widget dédié pour gérer le cycle de vie (Clean Code)
class CreatePersonDialog extends ConsumerStatefulWidget {
  const CreatePersonDialog({super.key});

  @override
  ConsumerState<CreatePersonDialog> createState() => _CreatePersonDialogState();
}

class _CreatePersonDialogState extends ConsumerState<CreatePersonDialog> {
  // 2. Instanciation au niveau du State
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    // 3. Libération stricte de la mémoire (Performance)
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final name = _titleCtrl.text.trim();
    final bio = _descCtrl.text.trim();

    // 4. Validation front-end stricte
    if (name.isEmpty) {
      AppExtension.snack(context, 'Le nom de la personne est obligatoire', false);
      return;
    }

    final success = ref.read(personListProvider.notifier).createPerson(
      person: PersonModel(name: name, bio: bio),
    );

    // 5. Vérification vitale du contexte après le gap asynchrone (Gestion d'erreur stricte)
    if (!mounted) return;

    success.onError((e, st) {
      AppExtension.snack(context, 'Erreur lors de la création', false);
      debugPrint(e.toString());
      return false;
    });

    Navigator.pop(context);
    AppExtension.snack(context, 'Personne créée avec succès', true);
  }

  @override
  Widget build(BuildContext context) {
    // 6. ref.watch utilisé légalement dans le build()
    final isLoading = ref
        .watch(personListProvider)
        .isLoading;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: const TitleText('Nouvelle Personne', fontSize: 18),
      content: isLoading
          ? const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      )
          : SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BasicInput(_titleCtrl, text: 'Nom de la personne *'),
              BasicInput(_descCtrl, text: 'Bio de la personne', maxLines: 3),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          // Désactive aussi le bouton annuler pendant le chargement pour verrouiller la vue
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const MediumText('Annuler', fontSize: 14),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.colorBluePrimary),
          onPressed: isLoading ? null : _onSubmit,
          child: const MediumText('Créer', fontSize: 14, color: Colors.white),
        ),
      ],
    );
  }
}