import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../theme/app_theme.dart';

// Login / Sign up screen with form validation.
// When login succeeds, AuthGate (in main.dart) automatically shows the app.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _isLogin = true;
  bool _hide = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final p = context.read<MovieProvider>();
    final error = _isLogin
        ? p.login(_email.text, _password.text)
        : p.signUp(_name.text.trim(), _email.text, _password.text);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _toggleMode() {
    setState(() => _isLogin = !_isLogin);
    _formKey.currentState?.reset();
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_isLogin ? 'Welcome back' : 'Create account',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            _isLogin
                ? 'Log in to see your favorites and watchlist.'
                : 'Sign up to start building your movie library.',
            style: TextStyle(color: AppTheme.mutedText(context)),
          ),
          const SizedBox(height: 24),

          // Name field only appears on Sign up (animated).
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: Column(
              children: [
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _name,
                    decoration: AppTheme.inputDeco('Full name', icon: Icons.person),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter your name';
                      if (v.trim().length < 2) return 'Name is too short';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),

          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: AppTheme.inputDeco('Email', icon: Icons.email),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter your email';
              final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
              return ok ? null : 'Enter a valid email address';
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _password,
            obscureText: _hide,
            decoration: AppTheme.inputDeco(
              'Password',
              icon: Icons.lock,
              suffix: IconButton(
                icon: Icon(_hide ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _hide = !_hide),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter a password';
              if (v.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),

          // Confirm password only appears on Sign up (animated).
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: Column(
              children: [
                if (!_isLogin) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirm,
                    obscureText: _hide,
                    decoration: AppTheme.inputDeco('Confirm password',
                        icon: Icons.lock_outline),
                    validator: (v) =>
                        v != _password.text ? 'Passwords do not match' : null,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            child: Text(_isLogin ? 'Log in' : 'Sign up'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.read<MovieProvider>().continueAsGuest(),
            child: const Text('Continue as guest'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _toggleMode,
            child: Text(_isLogin
                ? 'New here? Create an account'
                : 'Already have an account? Log in'),
          ),
          if (_isLogin)
            Center(
              child: Text('Demo account: demo@movie.com / demo123',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.mutedText(context))),
            ),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white70, size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: const TextStyle(color: Colors.white, fontSize: 16))),
        ],
      ),
    );
  }

  // Left panel shown only on wide screens.
  Widget _brandPanel() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8E0000), Color(0xFF111111)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.movie_filter, color: Colors.white, size: 64),
          const SizedBox(height: 16),
          const Text('Movie Explorer',
              style: TextStyle(
                  color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Discover, save and review the movies you love.',
              style: TextStyle(color: Colors.white70, fontSize: 18)),
          const SizedBox(height: 32),
          _bullet('Search, filter and sort movies'),
          _bullet('Build your favorites and watchlist'),
          _bullet('Rate and review with stars'),
          _bullet('Light and dark themes'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final formArea = Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!wide) ...[
                      Icon(Icons.movie_filter,
                          size: 56, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 8),
                      const Text('Movie Explorer',
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 24),
                    ],
                    _form(),
                  ],
                ),
              ),
            ),
          );
          if (!wide) return formArea;
          return Row(
            children: [
              Expanded(child: _brandPanel()),
              Expanded(child: formArea),
            ],
          );
        },
      ),
    );
  }
}
