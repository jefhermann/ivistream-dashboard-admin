import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../team.dart';


/// Retourne `true` via Navigator.pop si l'invitation a bien été envoyée,
/// pour que l'écran appelant sache qu'il doit rafraîchir ses listes.
class AddAdminMemberDialog extends ConsumerStatefulWidget {
  const AddAdminMemberDialog({super.key});

  @override
  ConsumerState<AddAdminMemberDialog> createState() => _AddAdminMemberDialogState();
}

class _AddAdminMemberDialogState extends ConsumerState<AddAdminMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  AdminRole _selectedRole = AdminRole.analyst;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Inviter un membre', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Email requis';
                    if (!value.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AdminRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Rôle',
                    border: OutlineInputBorder(),
                  ),
                  items: AdminRole.values
                      .map((role) => DropdownMenuItem(value: role, child: Text(role.label)))
                      .toList(),
                  onChanged: (role) => setState(() => _selectedRole = role ?? _selectedRole),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Text("Envoyer l'invitation"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref.read(adminTeamRepositoryProvider).inviteMember(
        email: _emailController.text.trim(),
        role: _selectedRole,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _errorMessage = "Erreur : $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}