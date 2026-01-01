import 'package:equatable/equatable.dart';

class RecipeModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final int? preparationTime;
  final int? cookingTime;
  final int? totalTime;
  final int servings;
  final String? difficulty;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;
  final NutritionData? nutrition;
  final bool? isAvailable;
  final double? matchScore;
  final int? availableIngredients;
  final int? missingIngredients;

  const RecipeModel({
    required this.id,
    required this.name,
    this.description,
    this.preparationTime,
    this.cookingTime,
    this.totalTime,
    required this.servings,
    this.difficulty,
    required this.ingredients,
    required this.steps,
    this.nutrition,
    this.isAvailable,
    this.matchScore,
    this.availableIngredients,
    this.missingIngredients,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    // Gérer les UUID qui peuvent être des String ou des objets
    String id;
    if (json['id'] is String) {
      id = json['id'] as String;
    } else {
      id = json['id'].toString();
    }

    return RecipeModel(
      id: id,
      name: json['name'] as String,
      description: json['description'] as String?,
      preparationTime: json['preparation_time'] as int?,
      cookingTime: json['cooking_time'] as int?,
      totalTime: json['total_time'] as int?,
      servings: (json['servings'] as num?)?.toInt() ?? 1,
      difficulty: json['difficulty'] as String?,
      ingredients: json['ingredients'] != null && json['ingredients'] is List
          ? (json['ingredients'] as List)
              .map((i) {
                if (i is! Map<String, dynamic>) {
                  throw Exception('Format d\'ingrédient invalide: attendu Map, reçu ${i.runtimeType}');
                }
                return RecipeIngredient.fromJson(i);
              })
              .toList()
          : [],
      steps: json['steps'] != null && json['steps'] is List
          ? (json['steps'] as List)
              .map((s) {
                if (s is! Map<String, dynamic>) {
                  throw Exception('Format d\'étape invalide: attendu Map, reçu ${s.runtimeType}');
                }
                return RecipeStep.fromJson(s);
              })
              .toList()
          : [],
      nutrition: json['nutrition'] != null
          ? NutritionData.fromJson(json['nutrition'] as Map<String, dynamic>)
          : null,
      isAvailable: json['can_cook'] as bool?,
      matchScore: json['match_score'] != null
          ? (json['match_score'] as num).toDouble()
          : null,
      availableIngredients: json['available_ingredients'] as int?,
      missingIngredients: json['missing_ingredients'] as int?,
    );
  }

  int get calculatedTotalTime {
    if (totalTime != null) return totalTime!;
    if (preparationTime != null && cookingTime != null) {
      return preparationTime! + cookingTime!;
    }
    return 0;
  }

  @override
  List<Object?> get props => [id, name];
}

class RecipeIngredient extends Equatable {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final bool optional;

  const RecipeIngredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.optional = false,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    // Gérer les UUID qui peuvent être des String ou des objets
    String id;
    if (json['id'] != null) {
      if (json['id'] is String) {
        id = json['id'] as String;
      } else {
        id = json['id'].toString();
      }
    } else {
      id = DateTime.now().millisecondsSinceEpoch.toString();
    }

    // Gérer quantity qui peut être num ou String
    double quantity = 0.0;
    if (json['quantity'] != null) {
      if (json['quantity'] is num) {
        quantity = (json['quantity'] as num).toDouble();
      } else if (json['quantity'] is String) {
        quantity = double.tryParse(json['quantity'] as String) ?? 0.0;
      }
    }

    return RecipeIngredient(
      id: id,
      name: json['ingredient_name'] as String? ?? json['name'] as String? ?? '',
      quantity: quantity,
      unit: json['unit'] as String? ?? '',
      optional: json['optional'] is bool ? (json['optional'] as bool) : (json['optional'] == 1 || json['optional'] == 'true'),
    );
  }

  @override
  List<Object?> get props => [id, name, quantity, unit];
}

class RecipeStep extends Equatable {
  final String id;
  final int stepNumber;
  final String instruction;
  final String? imageUrl;

  const RecipeStep({
    required this.id,
    required this.stepNumber,
    required this.instruction,
    this.imageUrl,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    // Gérer les UUID qui peuvent être des String ou des objets
    String id;
    if (json['id'] != null) {
      if (json['id'] is String) {
        id = json['id'] as String;
      } else {
        id = json['id'].toString();
      }
    } else {
      id = DateTime.now().millisecondsSinceEpoch.toString();
    }

    return RecipeStep(
      id: id,
      stepNumber: (json['step_number'] as num?)?.toInt() ?? (json['step'] as num?)?.toInt() ?? 0,
      instruction: json['instruction'] as String? ?? json['text'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? json['image'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, stepNumber, instruction];
}

class NutritionData extends Equatable {
  final String id;
  final double? calories;
  final double? proteins;
  final double? carbohydrates;
  final double? lipids;
  final double? fiber;
  final double? sugar;
  final double? sodium;
  final bool perServing;

  const NutritionData({
    required this.id,
    this.calories,
    this.proteins,
    this.carbohydrates,
    this.lipids,
    this.fiber,
    this.sugar,
    this.sodium,
    this.perServing = true,
  });

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    // Gérer les UUID qui peuvent être des String ou des objets
    String id;
    if (json['id'] != null) {
      if (json['id'] is String) {
        id = json['id'] as String;
      } else {
        id = json['id'].toString();
      }
    } else {
      id = DateTime.now().millisecondsSinceEpoch.toString();
    }

    // Helper pour convertir en double de manière sécurisée
    double? safeDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed;
      }
      return null;
    }

    return NutritionData(
      id: id,
      calories: safeDouble(json['calories']),
      proteins: safeDouble(json['proteins']),
      carbohydrates: safeDouble(json['carbohydrates']),
      lipids: safeDouble(json['fats'] ?? json['lipids']),
      fiber: safeDouble(json['fiber']),
      sugar: safeDouble(json['sugar']),
      sodium: safeDouble(json['sodium']),
      perServing: json['per_serving'] is bool 
          ? (json['per_serving'] as bool) 
          : (json['per_serving'] == 1 || json['per_serving'] == 'true'),
    );
  }

  @override
  List<Object?> get props => [id, calories, proteins, carbohydrates, lipids];
}
