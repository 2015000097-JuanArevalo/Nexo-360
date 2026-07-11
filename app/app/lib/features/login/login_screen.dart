import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/app_session.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/nexo_ui.dart';

class LoginScreen extends StatefulWidget {
  final AppSession session;

  const LoginScreen({super.key, required this.session});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });
    widget.session.clearError();

    try {
      await widget.session.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _error = _authMessage(error.code));
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'No se pudo iniciar sesión. Inténtalo nuevamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _authMessage(String code) {
    return switch (code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'El correo o la contraseña no son correctos.',
      'user-disabled' => 'Esta cuenta fue deshabilitada.',
      'too-many-requests' => 'Demasiados intentos. Espera un momento.',
      'network-request-failed' => 'Revisa tu conexión a Internet.',
      _ => 'Firebase no pudo completar el inicio de sesión.',
    };
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 850;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: wide
                      ? Row(
                          children: [
                            Expanded(child: _brand(wide: true)),
                            const SizedBox(width: 46),
                            Expanded(child: _loginCard()),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _brand(wide: false),
                            const SizedBox(height: 22),
                            _loginCard(),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _brand({required bool wide}) {
    return Column(
      children: [
        NexoBrandPanel(size: wide ? 330 : 190),
        if (wide) ...[
          const SizedBox(height: 16),
          const Text(
            'Colegio Don Bosco · Movimiento Juventud',
            style: TextStyle(
              color: Color(0xFFBFC7EA),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  Widget _loginCard() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: AnimatedBuilder(
            animation: widget.session,
            builder: (context, _) => _buildForm(context),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final errorMessage = _error ?? widget.session.errorMessage;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Bienvenido', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          const Text(
            'Ingresa a tu espacio académico, de permisos y eventos.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          NexoTextFormField(
            controller: _emailController,
            label: 'Correo electrónico',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value == null || !value.contains('@')
                ? 'Ingresa un correo válido.'
                : null,
          ),
          const SizedBox(height: 16),
          NexoTextFormField(
            controller: _passwordController,
            label: 'Contraseña',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            onFieldSubmitted: (_) {
              if (!_isLoading) _login();
            },
            validator: (value) => value == null || value.length < 6
                ? 'La contraseña debe tener al menos 6 caracteres.'
                : null,
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            AppErrorMessage(message: errorMessage),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _isLoading ? null : _login,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Iniciar sesión'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.publicRegistration),
            icon: const Icon(Icons.event_available_outlined),
            label: const Text('Inscripción pública a eventos'),
          ),
        ],
      ),
    );
  }
}
