import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/visu.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final SupabaseAuthService _authService = SupabaseAuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.user != null) {
          // Redirection will be handled by go_router
        } else {
          setState(() {
            _errorMessage = 'Email ou mot de passe incorrect';
          });
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16232E),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo and title
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/img/icon.png',
                          height: 80,
                          width: 80,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Visu',
                          style: TextStyle(
                            color: Color(0xFFF8C13A),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Suivez vos films et séries préférés',
                          style: TextStyle(
                            color: Color(0xFFF4F6F8),
                            fontSize: 16,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Form title
                  const Text(
                    'Connexion',
                    style: TextStyle(
                      color: Color(0xFFF4F6F8),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Email field
                  VisuTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password field
                  VisuTextField(
                    label: 'Mot de passe',
                    controller: _passwordController,
                    obscureText: true,
                    prefixIcon: Icons.lock,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Login button
                  VisuButton(
                    text: 'Se connecter',
                    isLoading: _isLoading,
                    icon: Icons.login,
                    onPressed: _login,
                  ),

                  const SizedBox(height: 24),

                  // Registration link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Pas encore de compte ?',
                          style: TextStyle(
                            color: Color(0xFFF4F6F8),
                            fontSize: 14,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: const Text(
                            'S\'inscrire',
                            style: TextStyle(
                              color: Color(0xFFF8C13A),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
