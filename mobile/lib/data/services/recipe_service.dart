import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/recipe_model.dart';
import '../../core/constants/app_constants.dart';

class RecipeService {
  final ApiService _apiService = ApiService();

  Future<List<RecipeModel>> getRecipes() async {
    debugPrint('🍳 [RECIPE] Chargement des recettes...');
    final response = await _apiService.get(AppConstants.recipes);
    if (response == null) {
      debugPrint('⚠️ [RECIPE] Aucune recette trouvée');
      return [];
    }
    if (response is! List) {
      debugPrint('❌ [RECIPE] Format de réponse invalide: ${response.runtimeType}');
      throw Exception('Format de réponse invalide: attendu List, reçu ${response.runtimeType}');
    }
    final List<dynamic> data = response;
    debugPrint('✅ [RECIPE] ${data.length} recette(s) trouvée(s)');
    return data.map((json) {
      if (json is! Map<String, dynamic>) {
        debugPrint('❌ [RECIPE] Format d\'élément invalide: ${json.runtimeType}');
        throw Exception('Format d\'élément invalide: attendu Map, reçu ${json.runtimeType}');
      }
      return RecipeModel.fromJson(json);
    }).toList();
  }

  Future<RecipeModel> getRecipeDetails(String id) async {
    debugPrint('🍳 [RECIPE] Chargement des détails de la recette: $id');
    final response = await _apiService.get('${AppConstants.recipes}/$id');
    if (response == null || response is! Map<String, dynamic>) {
      debugPrint('❌ [RECIPE] Format de réponse invalide: ${response?.runtimeType ?? "null"}');
      throw Exception('Format de réponse invalide: attendu Map, reçu ${response?.runtimeType ?? "null"}');
    }
    debugPrint('✅ [RECIPE] Détails de la recette chargés');
    return RecipeModel.fromJson(response);
  }

  Future<void> cookRecipe(String id, {int servings = 1}) async {
    debugPrint('🍳 [RECIPE] Cuisson de la recette: $id ($servings portion(s))');
    await _apiService.post(
      '${AppConstants.recipes}/$id/cook',
      {'servings': servings},
    );
    debugPrint('✅ [RECIPE] Recette cuisinée avec succès');
  }
}

