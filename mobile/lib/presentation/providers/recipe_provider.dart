import 'package:flutter/foundation.dart';
import '../../data/models/recipe_model.dart';
import '../../data/services/recipe_service.dart';

class RecipeProvider with ChangeNotifier {
  final RecipeService _recipeService = RecipeService();

  List<RecipeModel> _recipes = [];
  RecipeModel? _selectedRecipe;
  bool _isLoading = false;
  String? _error;

  List<RecipeModel> get recipes => _recipes;
  RecipeModel? get selectedRecipe => _selectedRecipe;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRecipes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🍳 [RECIPE PROVIDER] Chargement des recettes...');
      _recipes = await _recipeService.getRecipes();
      debugPrint('✅ [RECIPE PROVIDER] ${_recipes.length} recette(s) chargée(s)');
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('❌ [RECIPE PROVIDER] Erreur lors du chargement: $e');
      debugPrint('   Stack: $stackTrace');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRecipeDetails(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🍳 [RECIPE PROVIDER] Chargement des détails: $id');
      _selectedRecipe = await _recipeService.getRecipeDetails(id);
      debugPrint('✅ [RECIPE PROVIDER] Détails chargés: ${_selectedRecipe?.name}');
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('❌ [RECIPE PROVIDER] Erreur lors du chargement des détails: $e');
      debugPrint('   Stack: $stackTrace');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cookRecipe(String id, {int servings = 1}) async {
    try {
      debugPrint('🍳 [RECIPE PROVIDER] Cuisson de la recette: $id');
      await _recipeService.cookRecipe(id, servings: servings);
      // Recharger les recettes après cuisson
      await loadRecipes();
      debugPrint('✅ [RECIPE PROVIDER] Recette cuisinée avec succès');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [RECIPE PROVIDER] Erreur lors de la cuisson: $e');
      debugPrint('   Stack: $stackTrace');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

