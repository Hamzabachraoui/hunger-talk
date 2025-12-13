import 'package:flutter/material.dart';
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
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          // Section Profil
          if (user != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user.firstName[0].toUpperCase(),
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
                              user.fullName,
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
                    ],
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
    );
  }
}
