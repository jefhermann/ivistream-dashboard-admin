import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../country.dart';

@RoutePage()
class CountryScreen extends ConsumerWidget {
const CountryScreen({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
// Exemple d'écoute
final state = ref.watch(countryControllerProvider);

return Scaffold(
appBar: AppBar(title: const Text('Country')),
body: Center(
child: state.isLoading
? const CircularProgressIndicator()
    : const Text('Feature Country prête !'),
),
);
}
}