import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../person.dart';

@RoutePage()
class PersonScreen extends ConsumerWidget {
const PersonScreen({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
// Exemple d'écoute
final state = ref.watch(personControllerProvider);

return Scaffold(
appBar: AppBar(title: const Text('Person')),
body: Center(
child: state.isLoading
? const CircularProgressIndicator()
    : const Text('Feature Person prête !'),
),
);
}
}