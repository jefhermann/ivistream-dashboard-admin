// On exige un callback pour que le parent gère la donnée, pas le widget.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

import '../../../../common/common.dart';
import '../../person.dart';

class PersonSearchDropdownWidget extends ConsumerStatefulWidget {
  final String label;
  final Function(List<String> selectedIds) onSelectionChange;

  const PersonSearchDropdownWidget({
    super.key,
    required this.label,
    required this.onSelectionChange,
  });

  @override
  ConsumerState<PersonSearchDropdownWidget> createState() => _PersonSearchDropdownState();
}

class _PersonSearchDropdownState extends ConsumerState<PersonSearchDropdownWidget> {
  final MultiSelectController<String> _dropdownController = MultiSelectController<String>();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _dropdownController.dispose();
    super.dispose();
  }

  void _onSearchQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isNotEmpty) {
        try {
          // 👑 LE FIX EST ICI : On appelle le repository directement.
          // On ne passe PLUS par un provider global pour une recherche locale au composant.
          // Remplace `actorRepositoryProvider` par le nom de ton repository d'API.
          final persons = await ref.read(personRepositoryProvider).getPersons(query: query);

          if (!mounted) return; // Sécurité si le widget est détruit pendant l'appel

          final newItems = persons
              .map((person) => DropdownItem<String>(
                    label: person.name ?? '',
                    value: person.id ?? '',
                  ))
              .toList();

          _dropdownController.setItems(newItems);
        } catch (e) {
          debugPrint("Erreur locale Dropdown ${widget.label}: $e");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiDropdown<String>(
      controller: _dropdownController,
      searchEnabled: true,
      searchDecoration: SearchFieldDecoration(
        hintText: 'Rechercher dans ${widget.label}...',
      ),
      onSearchChange: _onSearchQueryChanged,
      onSelectionChange: widget.onSelectionChange,
      fieldDecoration: FieldDecoration(
        hintText: widget.label,
        labelText: widget.label,
        hintStyle: basicTextStyle(color: AppColors.colorGrayDark, fontSize: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      items: [],
    );
  }
}
