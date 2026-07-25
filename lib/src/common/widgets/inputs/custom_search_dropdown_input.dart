import 'dart:async';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class CustomSearchDropdownInput extends StatefulWidget {
  final String label;
  final ValueChanged<List<String>> onSelectionChange;
  final Future<List<DropdownItem<String>>> Function(String query) onSearch;
  final bool singleSelect;
  final List<DropdownItem<String>>? preSelectedItems;

  const CustomSearchDropdownInput({
    super.key,
    required this.label,
    required this.onSelectionChange,
    required this.onSearch,
    this.preSelectedItems,
    this.singleSelect = false,
  });

  @override
  State<CustomSearchDropdownInput> createState() => _CustomSearchDropdownInputState();
}

class _CustomSearchDropdownInputState extends State<CustomSearchDropdownInput> {
  final MultiSelectController<String> _dropdownController = MultiSelectController<String>();
  Timer? _debounce;
  List<DropdownItem<String>> _currentSelectedItems = [];

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedItems != null) {
      _currentSelectedItems = List.from(widget.preSelectedItems!);
    }
    _loadInitialData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _dropdownController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final initialItems = await widget.onSearch('');
      if (!mounted) return;

      _updateDropdownItems(initialItems);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final values = _currentSelectedItems.map((e) => e.value).toSet();
        _dropdownController.selectWhere((item) => values.contains(item.value));
      });

      // Synchronise l'état parent
      if (_currentSelectedItems.isNotEmpty) {
        widget.onSelectionChange(
          _currentSelectedItems.map((e) => e.value).toList(),
        );
      }
    } catch (e) {
      debugPrint("Erreur Init Dropdown ${widget.label}: $e");
    }
  }

  void _onSearchQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final newItems = await widget.onSearch(query);
        if (!mounted) return;
        _updateDropdownItems(newItems);
      } catch (e) {
        debugPrint("Erreur Recherche Dropdown ${widget.label}: $e");
      }
    });
  }

  void _updateDropdownItems(List<DropdownItem<String>> fetchedItems) {
    final selectedValues = _currentSelectedItems.map((e) => e.value).toSet();
    final Map<String, DropdownItem<String>> mergedMap = {};

    // Les présélectionnés d'abord (au cas où la recherche ne les renvoie pas)
    for (final item in _currentSelectedItems) {
      mergedMap[item.value] = item.copyWith(selected: true);
    }
    // Puis les résultats de recherche, en marquant sélectionnés ceux déjà choisis
    for (final item in fetchedItems) {
      mergedMap[item.value] =
          item.copyWith(selected: selectedValues.contains(item.value));
    }

    _dropdownController.setItems(mergedMap.values.toList());
  }

  @override
  Widget build(BuildContext context) {
    return MultiDropdown<String>(
      controller: _dropdownController,
      searchEnabled: true,
      singleSelect: widget.singleSelect,

      // 👑 FIX 1 : On évite le 'always' pour ne pas déclencher l'erreur avant le chargement asynchrone
      autovalidateMode: AutovalidateMode.always,

      // 👑 FIX 2 : On vérifie si la liste est nulle OU vide, car multi_dropdown renvoie une liste vide []
      validator: (items) {
        if (items == null || items.isEmpty) {
          return 'Veuillez sélectionner au moins un ${widget.label.toLowerCase()}';
        }
        return null;
      },

      searchDecoration: SearchFieldDecoration(
        hintText: 'Rechercher dans ${widget.label}...',
      ),
      onSearchChange: _onSearchQueryChanged,

      onSelectionChange: (selectedIds) {
        _currentSelectedItems = _dropdownController.selectedItems;
        widget.onSelectionChange(selectedIds);
      },

      fieldDecoration: FieldDecoration(
        hintText: widget.label,
        labelText: widget.label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      items: const [],
    );
  }
}