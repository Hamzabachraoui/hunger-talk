import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/stock_provider.dart';
import '../../widgets/nutrition_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/nutrition_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final NutritionService _nutritionService = NutritionService();
  
  Map<String, dynamic>? _dailyNutrition;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Attendre que le token soit sauvegardé avant de faire les requêtes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Attendre que le token soit sauvegardé dans le storage
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _loadData();
        context.read<StockProvider>().loadStock();
      }
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final nutrition = await _nutritionService.getDailyNutrition();
      setState(() {
        _dailyNutrition = nutrition;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        'Erreur de chargement',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Statistiques du stock
                        Text(
                          'Mon Stock',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Consumer<StockProvider>(
                          builder: (context, stockProvider, _) {
                            final items = stockProvider.items;
                            final totalItems = items.length;
                            final expiringSoon = items.where((item) => item.isExpiringSoon).length;
                            final expired = items.where((item) => item.isExpired).length;

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _StatCard(
                                        label: 'Total',
                                        value: totalItems.toString(),
                                        icon: Icons.inventory_2_outlined,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _StatCard(
                                        label: 'Expire bientôt',
                                        value: expiringSoon.toString(),
                                        icon: Icons.warning_amber_rounded,
                                        color: AppColors.stockExpiring,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (expired > 0)
                                  Card(
                                    color: AppColors.stockExpired.withValues(alpha: 0.1),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.error_outline, color: AppColors.stockExpired),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              '$expired produit(s) expiré(s)',
                                              style: const TextStyle(
                                                color: AppColors.stockExpired,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () => context.go('/stock'),
                                            child: const Text('Voir'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        // Statistiques nutritionnelles
                        Text(
                          'Nutrition du Jour',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        if (_dailyNutrition != null) ...[
                          NutritionCard(
                            label: 'Calories',
                            value: (_dailyNutrition!['total']?['calories'] ?? 0).toDouble(),
                            target: (_dailyNutrition!['goals']?['calories'] ?? 0).toDouble(),
                            unit: 'kcal',
                            icon: Icons.local_fire_department,
                            color: AppColors.accent,
                          ),
                          const SizedBox(height: 12),
                          NutritionCard(
                            label: 'Protéines',
                            value: (_dailyNutrition!['total']?['proteins'] ?? 0).toDouble(),
                            target: (_dailyNutrition!['goals']?['proteins'] ?? 0).toDouble(),
                            unit: 'g',
                            icon: Icons.fitness_center,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          NutritionCard(
                            label: 'Glucides',
                            value: (_dailyNutrition!['total']?['carbohydrates'] ?? 0).toDouble(),
                            target: (_dailyNutrition!['goals']?['carbohydrates'] ?? 0).toDouble(),
                            unit: 'g',
                            icon: Icons.energy_savings_leaf,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(height: 12),
                          NutritionCard(
                            label: 'Lipides',
                            value: (_dailyNutrition!['total']?['lipids'] ?? 0).toDouble(),
                            target: (_dailyNutrition!['goals']?['lipids'] ?? 0).toDouble(),
                            unit: 'g',
                            icon: Icons.water_drop,
                            color: AppColors.accentDark,
                          ),
                        ] else
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  const Icon(Icons.restaurant_outlined, size: 48, color: AppColors.textTertiary),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucune donnée nutritionnelle',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Cuisinez des recettes pour voir vos statistiques',
                                    style: Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 32),

                        // Actions rapides
                        Text(
                          'Actions Rapides',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _ActionCard(
                                label: 'Ajouter au stock',
                                icon: Icons.add_circle_outline,
                                color: AppColors.primary,
                                onTap: () => context.go('/stock'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ActionCard(
                                label: 'Chat IA',
                                icon: Icons.chat_bubble_outline,
                                color: AppColors.secondary,
                                onTap: () => context.go('/chat'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ActionCard(
                                label: 'Recettes',
                                icon: Icons.restaurant_outlined,
                                color: AppColors.accent,
                                onTap: () => context.go('/recipes'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.go('/stock');
              break;
            case 2:
              context.go('/chat');
              break;
            case 3:
              context.go('/recipes');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Stock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_outlined),
            label: 'Recettes',
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
