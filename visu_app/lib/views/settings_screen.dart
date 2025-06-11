import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/visu.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SupabaseAuthService _authService = SupabaseAuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16232E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16232E),
        title: const Text(
          'Paramètres',
          style: TextStyle(color: Color(0xFFF8C13A)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF8C13A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF8C13A)),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Compte',
                      style: TextStyle(
                        color: Color(0xFFF8C13A),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsCard([
                      _buildSettingsOption(
                        Icons.lock_outline,
                        'Changer le mot de passe',
                        onTap: () => _showChangePasswordDialog(context),
                      ),
                      const Divider(color: Color(0xFF2A3B4D)),
                      _buildSettingsOption(
                        Icons.email_outlined,
                        'Modifier l\'adresse email',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fonctionnalité à venir'),
                              backgroundColor: Color(0xFF16232E),
                            ),
                          );
                        },
                      ),
                    ]),

                    const SizedBox(height: 24),

                    const Text(
                      'Préférences',
                      style: TextStyle(
                        color: Color(0xFFF8C13A),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsCard([
                      _buildSettingsOption(
                        Icons.notifications_outlined,
                        'Notifications',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fonctionnalité à venir'),
                              backgroundColor: Color(0xFF16232E),
                            ),
                          );
                        },
                      ),
                      const Divider(color: Color(0xFF2A3B4D)),
                      _buildSettingsOption(
                        Icons.language_outlined,
                        'Langue',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fonctionnalité à venir'),
                              backgroundColor: Color(0xFF16232E),
                            ),
                          );
                        },
                      ),
                    ]),

                    const SizedBox(height: 24),

                    const Text(
                      'Danger',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsCard([
                      _buildSettingsOption(
                        Icons.delete_forever,
                        'Supprimer mon compte',
                        textColor: Colors.red,
                        onTap: () => _showDeleteAccountDialog(context),
                      ),
                    ]),
                  ],
                ),
              ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      color: const Color(0xFF1D2F3E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSettingsOption(
    IconData icon,
    String text, {
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? const Color(0xFFF8C13A)),
      title: Text(
        text,
        style: TextStyle(color: textColor ?? const Color(0xFFF4F6F8)),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Color(0xFFF8C13A),
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final TextEditingController passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1D2F3E),
            title: const Text(
              'Changer le mot de passe',
              style: TextStyle(color: Color(0xFFF8C13A)),
            ),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Color(0xFFF4F6F8)),
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  labelStyle: TextStyle(color: Color(0xFFC0C0C0)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2A3B4D)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFF8C13A)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un mot de passe';
                  }
                  if (value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: Color(0xFFC0C0C0)),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8C13A),
                  foregroundColor: const Color(0xFF16232E),
                ),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      Navigator.pop(context);
                      setState(() => _isLoading = true);
                      await _authService.updatePassword(
                        passwordController.text,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Mot de passe mis à jour avec succès',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
                  }
                },
                child: const Text('Confirmer'),
              ),
            ],
          ),
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();

    final scaffoldContext = context;

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: const Color(0xFF1D2F3E),
            title: const Text(
              'Supprimer mon compte',
              style: TextStyle(color: Colors.red),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cette action est irréversible. Toutes vos données seront supprimées définitivement.',
                  style: TextStyle(color: Color(0xFFF4F6F8)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pour confirmer, entrez votre adresse email:',
                  style: TextStyle(color: Color(0xFFF4F6F8)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Color(0xFFF4F6F8)),
                  decoration: const InputDecoration(
                    hintText: 'votre@email.com',
                    hintStyle: TextStyle(color: Color(0xFF8A8A8A)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2A3B4D)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: Color(0xFFC0C0C0)),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final currentUser = _authService.currentUser;
                  if (currentUser != null &&
                      emailController.text.trim() == currentUser.email) {
                    try {
                      Navigator.of(dialogContext).pop();

                      setState(() => _isLoading = true);

                      await _authService.deleteAccount();

                      if (mounted) {
                        GoRouter.of(scaffoldContext).go('/login');
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() => _isLoading = false);

                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } else {
                    Navigator.of(dialogContext).pop();

                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      const SnackBar(
                        content: Text('L\'adresse email ne correspond pas'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Supprimer définitivement'),
              ),
            ],
          ),
    );
  }
}
