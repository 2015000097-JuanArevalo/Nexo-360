import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/auth/app_session.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';

class LoginScreen extends StatefulWidget {
  final AppSession session;
  const LoginScreen({super.key, required this.session});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool obscure = true;
  String? error;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await widget.session.signIn(email.text, password.text);
    } on FirebaseAuthException catch (exception) {
      setState(() => error = switch (exception.code) {
            'invalid-credential' => 'Correo o contraseña incorrectos.',
            'too-many-requests' => 'Demasiados intentos. Espera unos minutos.',
            _ => exception.message ?? 'No fue posible iniciar sesión.',
          });
    } catch (exception) {
      setState(() => error = 'No fue posible iniciar sesión: $exception');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: NexoColors.brandGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(child: NexoLogo()),
                          const SizedBox(height: 18),
                          Text('Bienvenido', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                          const Text('Portal escolar, QR y eventos', textAlign: TextAlign.center),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.email_outlined)),
                            validator: (value) => value == null || !value.contains('@') ? 'Ingresa un correo válido.' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: password,
                            obscureText: obscure,
                            onFieldSubmitted: (_) => submit(),
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => obscure = !obscure),
                                icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                              ),
                            ),
                            validator: (value) => value == null || value.length < 6 ? 'La contraseña debe tener al menos 6 caracteres.' : null,
                          ),
                          if (error != null) ...[
                            const SizedBox(height: 14),
                            Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                          ],
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: loading ? null : submit,
                            icon: loading
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.login),
                            label: Text(loading ? 'Ingresando...' : 'Iniciar sesión'),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Las cuentas son creadas por el personal técnico. Si tu cuenta de Authentication no tiene un perfil activo en Firestore, no podrá entrar.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: NexoColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  final String? message;
  const SplashScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const NexoLogo(),
              const SizedBox(height: 20),
              if (message == null) const CircularProgressIndicator() else Text(message!, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
