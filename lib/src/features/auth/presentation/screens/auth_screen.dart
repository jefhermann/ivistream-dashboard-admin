import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/common.dart';
import '../../auth.dart';

@RoutePage()
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    await ref.read(authControllerProvider.notifier).login(
          _usernameController.text.trim(),
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo placeholder — replace with your asset
              Container(
                height: 60,
                alignment: Alignment.center,
                child: const TitleText('IviStream', fontSize: 32, color: AppColors.colorBluePrimary),
              ),
              const TitleText(
                'Espace Administration',
                fontSize: 16,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              BasicInput(
                _usernameController,
                textInputType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.username, AutofillHints.email],
                hintText: 'Email',
                text: "Email",
              ),
              PasswordInputForm(
                controller: _passwordController,
                hintText: 'Mot de passe',
                text: 'Mot de passe',
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 24),
              if (authState.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: BodyText(
                    authState.error!,
                    color: AppColors.colorRedSecondary,
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorBluePrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: authState.isLoading ? null : _login,
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const TitleText('Se connecter', color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
