import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../content_gender.dart';

@RoutePage()
class ContentGenderScreen extends ConsumerWidget {
const ContentGenderScreen({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
// Exemple d'écoute
final state = ref.watch(contentGenderControllerProvider);

return Scaffold(
appBar: AppBar(title: const Text('Content Gender')),
body: Center(
child: state.isLoading
? const CircularProgressIndicator()
    : const Text('Feature Content Gender prête !'),
),
);
}
}