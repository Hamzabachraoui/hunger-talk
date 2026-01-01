import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/recipe_provider.dart';
import '../../widgets/recipe_card.dart';
import '../../../core/theme/app_colors.dart';
import 'recipe_details_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  String _filter = 'all'; // all, available, unavailable

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().loadRecipes();
    });
  }

  List<dynamic> _filterRecipes(List<dynamic> recipes) {
    switch (_filter) {
      case 'available':
        return recipes.where((r) => r.isAvailable == true).toList();
      case 'unavailable':
        return recipes.where((r) => r.isAvailable == false).toList();
      default:
        return recipes;
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Recettes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _FilterBottomSheet(
                  currentFilter: _filter,
                  onFilterChanged: (filter) {
                    setState(() => _filter = filter);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<RecipeProvider>().loadRecipes(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/recipes/add'),
        child: const Icon(Icons.add),
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, _) {
          if (recipeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (recipeProvider.error != null) {
            return Center(
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
                    onPressed: () => recipeProvider.loadRecipes(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final recipes = _filterRecipes(recipeProvider.recipes);

          if (recipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.restaurant_outlined, size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text(
                    recipeProvider.recipes.isEmpty ? 'Aucune recette' : 'Aucun résultat',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipeProvider.recipes.isEmpty
                        ? 'Les recettes seront disponibles bientôt'
                        : 'Essayez de modifier les filtres',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => recipeProvider.loadRecipes(),
            child: ListView.builder(
              itemCount: recipes.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return RecipeCard(
                  recipe: recipe,
                  onTap: () async {
                    final recipeId = recipe.id;
                    await recipeProvider.loadRecipeDetails(recipeId);
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailsScreen(recipeId: recipeId),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatelessWidget {
  final String currentFilter;
  final ValueChanged<String> onFilterChanged;

  const _FilterBottomSheet({
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrer les recettes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          RadioListTile<String>(
            title: const Text('Toutes les recettes'),
            value: 'all',
            groupValue: currentFilter,
            onChanged: (value) => onFilterChanged(value!),
          ),
          RadioListTile<String>(
            title: const Text('Disponibles avec mon stock'),
            value: 'available',
            groupValue: currentFilter,
            onChanged: (value) => onFilterChanged(value!),
          ),
          RadioListTile<String>(
            title: const Text('Ingrédients manquants'),
            value: 'unavailable',
            groupValue: currentFilter,
            onChanged: (value) => onFilterChanged(value!),
          ),
        ],
      ),
    );
  }
}
