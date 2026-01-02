import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/recipe_provider.dart';
import '../../providers/stock_provider.dart';
import '../../../data/models/recipe_model.dart';
import '../../../core/theme/app_colors.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailsScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    // Charger les détails de la recette au montage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded) {
        _loadRecipeDetails();
      }
    });
  }

  void _loadRecipeDetails() {
    final recipeProvider = context.read<RecipeProvider>();
    // Vérifier si la recette est déjà chargée et correspond
    if (recipeProvider.selectedRecipe?.id == widget.recipeId) {
      setState(() => _hasLoaded = true);
      return;
    }
    // Charger les détails
    recipeProvider.loadRecipeDetails(widget.recipeId).then((_) {
      if (mounted) {
        setState(() => _hasLoaded = true);
      }
    }).catchError((error) {
      debugPrint('❌ [RECIPE DETAILS] Erreur lors du chargement: $error');
    });
  }

  Future<void> _cookRecipe(RecipeModel recipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cuisiner cette recette'),
        content: Text(
          'Voulez-vous cuisiner "${recipe.name}" ?\n\n'
          'Les ingrédients seront soustraits de votre stock et les valeurs nutritionnelles seront ajoutées au dashboard.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cuisiner'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final recipeProvider = context.read<RecipeProvider>();
      final stockProvider = context.read<StockProvider>();
      final success = await recipeProvider.cookRecipe(widget.recipeId);

      if (!context.mounted) return;
      
      if (success) {
        // Recharger le stock
        stockProvider.loadStock();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Recette cuisinée avec succès ! Les données nutritionnelles ont été mises à jour dans le dashboard.'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Voir dashboard',
              textColor: Colors.white,
              onPressed: () {
                context.go('/dashboard');
              },
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(recipeProvider.error ?? 'Erreur'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        
        // Retourner en arrière avec Navigator (car ouvert via Navigator.push)
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          // Sinon, retourner aux recettes
          context.go('/recipes');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Détails de la recette'),
        ),
        body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, _) {
          // Vérifier si on charge ou si la recette chargée correspond
          final isLoading = !_hasLoaded || recipeProvider.isLoading;
          final recipe = recipeProvider.selectedRecipe?.id == widget.recipeId 
                         ? recipeProvider.selectedRecipe 
                         : null;

          if (isLoading || recipe == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (recipeProvider.error != null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Détails de la recette')),
              body: Center(
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
                      recipeProvider.error!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _hasLoaded = false;
                        _loadRecipeDetails();
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(recipe.name),
                  background: Container(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 80,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (recipe.description != null) ...[
                        Text(
                          recipe.description!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Informations générales
                      const _SectionTitle('Informations'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.access_time,
                              label: 'Préparation',
                              value: recipe.preparationTime != null
                                  ? '${recipe.preparationTime} min'
                                  : 'N/A',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.timer,
                              label: 'Cuisson',
                              value: recipe.cookingTime != null
                                  ? '${recipe.cookingTime} min'
                                  : 'N/A',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.restaurant,
                              label: 'Portions',
                              value: '${recipe.servings}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.trending_up,
                              label: 'Difficulté',
                              value: recipe.difficulty ?? 'N/A',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Ingrédients
                      const _SectionTitle('Ingrédients'),
                      const SizedBox(height: 12),
                      ...recipe.ingredients.map((ingredient) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    ingredient.name,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                                Text(
                                  '${ingredient.quantity.toStringAsFixed(1)} ${ingredient.unit}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Étapes
                      const _SectionTitle('Préparation'),
                      const SizedBox(height: 12),
                      ...recipe.steps.map((step) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${step.stepNumber}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    step.instruction,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Nutrition
                      if (recipe.nutrition != null) ...[
                        const _SectionTitle('Valeurs nutritionnelles'),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                if (recipe.nutrition!.calories != null)
                                  _NutritionRow('Calories', '${recipe.nutrition!.calories!.toStringAsFixed(0)} kcal'),
                                if (recipe.nutrition!.proteins != null)
                                  _NutritionRow('Protéines', '${recipe.nutrition!.proteins!.toStringAsFixed(1)} g'),
                                if (recipe.nutrition!.carbohydrates != null)
                                  _NutritionRow('Glucides', '${recipe.nutrition!.carbohydrates!.toStringAsFixed(1)} g'),
                                if (recipe.nutrition!.lipids != null)
                                  _NutritionRow('Lipides', '${recipe.nutrition!.lipids!.toStringAsFixed(1)} g'),
                                if (recipe.nutrition!.fiber != null)
                                  _NutritionRow('Fibres', '${recipe.nutrition!.fiber!.toStringAsFixed(1)} g'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Bouton cuisiner
                      if (recipe.isAvailable == true)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _cookRecipe(recipe),
                            icon: const Icon(Icons.restaurant_menu),
                            label: const Text('Cuisiner cette recette'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        )
                      else if (recipe.isAvailable == false)
                        Card(
                          color: AppColors.error.withValues(alpha: 0.1),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: AppColors.error),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Certains ingrédients manquent dans votre stock',
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final String value;

  const _NutritionRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
          ),
        ],
      ),
    );
  }
}

