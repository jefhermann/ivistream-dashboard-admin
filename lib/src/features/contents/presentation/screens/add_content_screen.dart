import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

import '../../../../common/common.dart';
import '../../../content_gender/content_gender.dart';
import '../../../country/application/application.dart';
import '../../../person/person.dart';
import '../../../producers/producers.dart';
import '../../contents.dart';

@RoutePage()
class AddContentScreen extends ConsumerStatefulWidget {
  const AddContentScreen({super.key});

  @override
  ConsumerState<AddContentScreen> createState() => _AddContentScreenState();
}

class _AddContentScreenState extends ConsumerState<AddContentScreen> {
  String? selectedType;
  String? selectedAccess;
  String? selectedTarget;
  String? producerId;
  bool isGlobal = false;
  List<String>? listActors;
  List<String>? listDirectors;
  List<String>? listGenres;
  List<String>? listProducers;
  String? country;
  DateTime selectedYear = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yearController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  ImageUpload? _posterBytes;

  ImageUpload? _bannerBytes;

  @override
  Widget build(BuildContext context) {
    ref.read(producersListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(LucideIcons.arrowLeft, size: 18),
              label: const Text('Retour'),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          CustomSearchDropdownInput(
                            label: 'Producteurs',
                            onSelectionChange: (List<String> selectedIds) {
                              setState(() => listProducers = selectedIds);
                            },
                            onSearch: (query) async {
                              final persons = await ref.read(producersRepositoryProvider).getProducers(search: query);
                              return persons.producers.map((p) => DropdownItem(label: p.name, value: p.id)).toList();
                            },
                          ),
                          const SizedBox(height: 20),
                          BasicInput(
                            _nameController,
                            hintText: 'Nom du contenu',
                            text: 'Nom du contenu',
                            isRequired: true,
                          ),
                          BasicInput(
                            _synopsisController,
                            hintText: 'Synopsis',
                            text: 'Synopsis',
                            maxLines: 2,
                            isRequired: true,
                          ),
                          BasicInput(
                            _descriptionController,
                            hintText: 'Description',
                            text: 'Description',
                            maxLines: 5,
                            isRequired: true,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CustomSearchDropdownInput(
                                  label: 'Acteurs',
                                  onSelectionChange: (List<String> selectedIds) {
                                    setState(() => listActors = selectedIds);
                                  },
                                  onSearch: (query) async {
                                    final persons = await ref.read(personRepositoryProvider).getPersons(query: query);
                                    return persons.items!.map((p) => DropdownItem(label: p.name ?? 'Inconnu', value: p.id ?? '')).toList();
                                  },
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: CustomSearchDropdownInput(
                                  label: 'Réalisateur(s)',
                                  onSelectionChange: (List<String> selectedIds) {
                                    debugPrint('Selected Directors: $selectedIds');
                                    setState(() => listDirectors = selectedIds);
                                  },
                                  onSearch: (query) async {
                                    final persons = await ref.read(personRepositoryProvider).getPersons(query: query);
                                    return persons.items!.map((p) => DropdownItem(label: p.name ?? 'Inconnu', value: p.id ?? '')).toList();
                                  },
                                ),
                              ),
                              const SizedBox(width: 20),
                              InkWell(
                                // N'oublie pas de passer le context si tu as appliqué ma correction précédente
                                onTap: () => _showCreatePersonDialog(),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    LucideIcons.userRoundPlus,
                                    semanticLabel: "Ajouter une personne",
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: selectedType,
                                  decoration: InputDecoration(
                                    hintText: "Type de contenu",
                                    labelText: "Type",
                                    hintStyle: basicTextStyle(color: AppColors.colorGrayDark, fontSize: 20),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'movie', child: BodyText('Film')),
                                    DropdownMenuItem(value: 'series', child: BodyText('Série')),
                                  ],
                                  onChanged: (val) => setState(() => selectedType = val ?? 'movie'),
                                  validator: (val) => val == null ? 'Veuillez sélectionner un type' : null,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: selectedAccess,
                                  decoration: InputDecoration(
                                    hintText: "Disponibilité du contenu",
                                    labelText: "Disponibilité",
                                    hintStyle: basicTextStyle(color: AppColors.colorGrayDark, fontSize: 20),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'free', child: BodyText('Gratuit')),
                                    DropdownMenuItem(value: 'premium', child: BodyText('Premium')),
                                  ],
                                  onChanged: (val) => setState(() => selectedAccess = val ?? 'free'),
                                  validator: (val) => val == null ? 'Veuillez sélectionner un type' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: selectedTarget,
                                  padding: EdgeInsets.zero,
                                  decoration: InputDecoration(
                                    hintText: "Cible du contenu",
                                    labelText: "Cible",
                                    hintStyle: basicTextStyle(color: AppColors.colorGrayDark, fontSize: 20),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'all', child: BodyText('Tout âge')),
                                    DropdownMenuItem(value: '3+', child: BodyText('+3')),
                                    DropdownMenuItem(value: '10+', child: BodyText('+10')),
                                    DropdownMenuItem(value: '13+', child: BodyText('+13')),
                                    DropdownMenuItem(value: '16+', child: BodyText('+16')),
                                  ],
                                  onChanged: (val) => setState(() => selectedTarget = val),
                                  validator: (val) => val == null ? 'Veuillez sélectionner un type' : null,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: CustomSearchDropdownInput(
                                  label: 'Genres',
                                  onSelectionChange: (List<String> selectedIds) {
                                    setState(() => listGenres = selectedIds);
                                  },
                                  onSearch: (query) async {
                                    final persons = await ref.read(contentGenderRepositoryProvider).getGenres(query: query);
                                    return persons.items!.map((p) => DropdownItem(label: p.name ?? 'Inconnu', value: p.id ?? '')).toList();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: BasicInput(
                                  _yearController,
                                  readOnly: true,
                                  focusNode: AlwaysDisabledFocusNode(),
                                  text: "Année de sortie",
                                  hintText: "Année de sortie",
                                  onTap: () async {
                                    var date = await AppExtension.selectYear(context);
                                    if (date != null) {
                                      _yearController.text = date.year.toString();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  children: [
                                    DropdownButtonFormField<bool>(
                                      initialValue: isGlobal,
                                      decoration: InputDecoration(
                                        hintText: "Zone de disponibilité",
                                        labelText: "Zone de disponibilité",
                                        hintStyle: basicTextStyle(color: AppColors.colorGrayDark, fontSize: 20),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: true, child: BodyText('Disponible partout')),
                                        DropdownMenuItem(value: false, child: BodyText('Exclusif à certain(s)')),
                                      ],
                                      onChanged: (val) => setState(() => isGlobal = val ?? false),
                                      validator: (val) => val == null ? 'Veuillez sélectionner la zone de disponibilité' : null,
                                    ),
                                    Spacers.min,
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  children: [
                                    CustomSearchDropdownInput(
                                      label: 'Pays d\'origine',
                                      singleSelect: true,
                                      onSelectionChange: (List<String> selectedIds) {
                                        setState(() => country = selectedIds.first);
                                      },
                                      onSearch: (String query) async {
                                        final country = await ref.read(countryRepositoryProvider).getCountries(query: query);
                                        return country.items!.map((p) => DropdownItem(label: p.name ?? "", value: p.code ?? "")).toList();
                                      },
                                    ),
                                    Spacers.min,
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CustomImagePicker(
                                  label: "Affiche du film/série",
                                  height: 250,
                                  onImageSelected: (bytes, fileName) {
                                    // Le parent enregistre l'image, prêt à l'envoyer au backend lors de la validation
                                    setState(() {
                                      _posterBytes = ImageUpload(
                                        bytes: bytes!,
                                        filename: fileName!,
                                      );
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: CustomImagePicker(
                                  label: "Banner du film/série",
                                  height: 250,
                                  onImageSelected: (bytes, fileName) {
                                    // Le parent enregistre l'image, prêt à l'envoyer au backend lors de la validation
                                    setState(() {
                                      _bannerBytes = ImageUpload(
                                        bytes: bytes!,
                                        filename: fileName!,
                                      );
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Row(children: [
                            const Spacer(),
                            Flexible(
                                flex: 1,
                                child: SubmitButton(
                                  text: "Annuler",
                                  color: Colors.grey,
                                  onTap: () => context.pop(),
                                )),
                            Spacers.medium,
                            Flexible(
                                flex: 1,
                                child: SubmitButton(
                                    text: "Enregistrer",
                                    onTap: () async {
                                      // 1. On valide le formulaire
                                      if (_formKey.currentState!.validate()) {
                                        _formKey.currentState!.save();

                                        // 2. On construit le DTO pur avec toutes les données collectées
                                        final dto = CreateContentModel(
                                          producerId: listProducers!.first,
                                          title: _nameController.text,
                                          type: selectedType!,
                                          description: _synopsisController.text,
                                          access: selectedAccess,
                                          maturity: selectedTarget,
                                          releaseYear: int.tryParse(_yearController.text),
                                          startDate: _startDateController.text.isNotEmpty ? DateFormat("dd/MM/yyyy").parse(_startDateController.text) : null,
                                          endDate: _endDateController.text.isNotEmpty ? DateFormat("dd/MM/yyyy").parse(_endDateController.text) : null,
                                          genreIds: listGenres!,
                                          directors: listDirectors!,
                                          actors: listActors!,
                                          country: country,
                                          isGlobal: isGlobal,

                                          // 👑 Les fichiers binaires capturés par notre CustomImagePicker
                                          poster: _posterBytes,
                                          banner: _bannerBytes,
                                        );

                                        // 3. On déclenche l'action via le Notifier Riverpod
                                        final success = await ref.read(contentCreationControllerProvider.notifier).createContent(dto);

                                        if (success && context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Contenu créé avec succès !'), backgroundColor: Colors.green),
                                          );
                                          final f = ref.read(contentsFilterProvider);
                                          ref.read(contentsListProvider.notifier).loadContents(page: f.page, search: f.search, status: f.status, type: f.type);
                                          Navigator.of(context).pop(); // Fermeture du modal

                                        } else if (context.mounted) {
                                          final errorState = ref.read(contentCreationControllerProvider);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Erreur : ${errorState.error}'), backgroundColor: Colors.red),
                                          );
                                        }
                                      }
                                    })),
                          ]),
                          Spacers.medium,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePersonDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => const CreatePersonDialog(),
      ),
    );
  }
}
