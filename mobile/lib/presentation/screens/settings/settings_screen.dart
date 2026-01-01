import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import 'user_preferences_screen.dart';
import 'server_config_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      final authProvider = context.watch<AuthProvider>();
      final user = authProvider.user;

      return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        
        // Naviguer en arrière dans l'historique si possible
        if (context.canPop()) {
          context.pop();
        } else {
          // Sinon, retourner au dashboard
          context.go('/dashboard');
        }
      },
      child: Scaffold(
        appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          // Section Profil
          if (user != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () {
                  context.push('/profile');
                },
                borderRadius: BorderRadius.circular(12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            (user.firstName.isNotEmpty 
                              ? user.firstName[0].toUpperCase() 
                              : user.email.isNotEmpty 
                                ? user.email[0].toUpperCase() 
                                : '?'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.firstName.isNotEmpty || user.lastName.isNotEmpty
                                  ? user.fullName.trim()
                                  : 'Nom non défini',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const Divider(),

          // Section Préférences
          ListTile(
            leading: const Icon(Icons.restaurant_outlined),
            title: const Text('Préférences alimentaires'),
            subtitle: const Text('Restrictions, allergies, objectifs nutritionnels'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserPreferencesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            subtitle: const Text('Gérer les notifications d\'expiration'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implémenter l'écran de notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité à venir')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_ethernet),
            title: const Text('Configuration du serveur'),
            subtitle: const Text('Modifier l\'adresse IP du serveur'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ServerConfigScreen(),
                ),
              );
            },
          ),
          const Divider(),

          // Section À propos
          ListTile(
            leading: const Icon(Icons.info_outlined),
            title: const Text('À propos'),
            subtitle: const Text('Version 1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Hunger-Talk',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.restaurant, size: 48),
                children: [
                  const Text(
                    'Application mobile intelligente de gestion nutritionnelle et alimentaire.',
                  ),
                ],
              );
            },
          ),
          const Divider(),

          // Déconnexion
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Déconnexion',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Déconnexion'),
                  content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Déconnexion'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                await authProvider.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),
        ],
      ),
      ),
    );
    } catch (e, stackTrace) {
      debugPrint('❌ [SETTINGS] Erreur lors du build: $e');
      debugPrint('   Stack: $stackTrace');
      return Scaffold(
        appBar: AppBar(
          title: const Text('Paramètres'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text(
                'Erreur lors du chargement des paramètres',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Retourner au dashboard
                  context.go('/dashboard');
                },
                child: const Text('Retour au dashboard'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
