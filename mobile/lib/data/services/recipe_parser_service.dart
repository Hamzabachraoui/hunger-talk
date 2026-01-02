class ParsedRecipe {
  String? name;
  String? description;
  List<Map<String, dynamic>> ingredients = [];
  List<Map<String, dynamic>> steps = [];
  int? prepTime;
  int? cookingTime;
  String? difficulty;
  int? servings;
}

class RecipeParserService {
  /// Parse la réponse de l'IA pour extraire les informations de recette
  ParsedRecipe parseRecipeFromText(String text) {
    final parsed = ParsedRecipe();
    
    // Normaliser le texte
    final normalized = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final lines = normalized.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    
    if (lines.isEmpty) return parsed;
    
    // 1. Extraire le nom de la recette (généralement en première ligne ou après "Recette:" ou "Nom:")
    parsed.name = _extractName(lines);
    
    // 2. Extraire la description (texte avant "Ingrédients" ou "Étapes")
    parsed.description = _extractDescription(lines);
    
    // 3. Extraire les ingrédients
    parsed.ingredients = _extractIngredients(lines);
    
    // 4. Extraire les étapes
    parsed.steps = _extractSteps(lines);
    
    // 5. Extraire les temps
    final times = _extractTimes(text);
    parsed.prepTime = times['prep'];
    parsed.cookingTime = times['cook'];
    
    // 6. Extraire la difficulté
    parsed.difficulty = _extractDifficulty(text);
    
    // 7. Extraire le nombre de portions
    parsed.servings = _extractServings(text);
    
    return parsed;
  }
  
  String? _extractName(List<String> lines) {
    // Chercher des patterns comme "Recette: [nom]", "Nom: [nom]", ou première ligne si elle contient des mots-clés
    for (int i = 0; i < lines.length && i < 5; i++) {
      final line = lines[i];
      final lower = line.toLowerCase();
      
      if (lower.contains('recette:')) {
        final parts = line.split(':');
        if (parts.length > 1) {
          return parts.skip(1).join(':').trim();
        }
      }
      if (lower.contains('nom:')) {
        final parts = line.split(':');
        if (parts.length > 1) {
          return parts.skip(1).join(':').trim();
        }
      }
      // Si la ligne commence par un titre (pas de ":", pas de "-", pas de chiffre, pas trop long)
      if (!line.contains(':') && 
          !line.startsWith('-') && 
          !RegExp(r'^\d+').hasMatch(line) && 
          line.length < 60 &&
          !lower.contains('ingrédient') &&
          !lower.contains('étape') &&
          !lower.contains('préparation')) {
        // Vérifier que ce n'est pas juste un mot isolé
        if (line.split(' ').length <= 5) {
          return line;
        }
      }
    }
    return null;
  }
  
  String? _extractDescription(List<String> lines) {
    final descriptionLines = <String>[];
    bool nameFound = false;
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lower = line.toLowerCase();
      
      if (lower.contains('ingrédient') || lower.contains('ingredient')) {
        break;
      }
      if (lower.contains('étape') || lower.contains('step') || lower.contains('préparation') || lower.contains('preparation')) {
        break;
      }
      
      // Ignorer la première ligne si c'est probablement le nom
      if (i == 0 && !line.contains('.') && !line.contains(',') && line.length < 60) {
        nameFound = true;
        continue;
      }
      
      // Ignorer les lignes qui sont clairement des titres
      if (line.length < 50 && !line.contains('.') && !line.contains(',') && !line.contains(':')) {
        if (descriptionLines.isEmpty && !nameFound) continue;
      }
      
      descriptionLines.add(line);
    }
    
    if (descriptionLines.isEmpty) return null;
    final description = descriptionLines.join('\n').trim();
    // Ne pas retourner si c'est trop court (probablement pas une description)
    return description.length > 20 ? description : null;
  }
  
  List<Map<String, dynamic>> _extractIngredients(List<String> lines) {
    final ingredients = <Map<String, dynamic>>[];
    bool inIngredients = false;
    int ingredientIndex = 0;
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lower = line.toLowerCase();
      
      // Détecter le début de la section ingrédients
      if (lower.contains('ingrédient') || lower.contains('ingredient')) {
        inIngredients = true;
        continue;
      }
      
      // Arrêter si on trouve la section étapes
      if (inIngredients && (lower.contains('étape') || lower.contains('step') || lower.contains('préparation') || lower.contains('preparation') || lower.contains('instruction'))) {
        break;
      }
      
      if (inIngredients) {
        // Patterns possibles:
        // - "200g de farine"
        // - "200 g farine"
        // - "- 200g farine"
        // - "1. 200g farine"
        // - "farine: 200g"
        
        final cleaned = line.replaceFirst(RegExp(r'^[-•\d+\.\)]\s*'), '').trim();
        if (cleaned.isEmpty) continue;
        
        final ingredient = _parseIngredientLine(cleaned);
        if (ingredient != null) {
          ingredient['order_index'] = ingredientIndex++;
          ingredients.add(ingredient);
        }
      }
    }
    
    return ingredients;
  }
  
  Map<String, dynamic>? _parseIngredientLine(String line) {
    // Pattern: quantité unité nom
    // Exemples: "200g farine", "2 cuillères à soupe d'huile", "1 oignon"
    
    // Nettoyer la ligne
    line = line.trim();
    if (line.isEmpty) return null;
    
    // Pattern 1: "200g farine" ou "200 g farine" ou "200g de farine"
    final pattern1 = RegExp(r'^(\d+(?:[.,]\d+)?)\s*(g|kg|ml|L|cl|dl|tasse|tasses|cuillère|cuillères|cuillère à soupe|cuillères à soupe|cuillère à café|cuillères à café|pièce|pièces|unité|unités|boîte|boîtes|paquet|paquets|bouteille|bouteilles|sachet|sachets)\s+(?:de\s+)?(.+)$', caseSensitive: false);
    final match1 = pattern1.firstMatch(line);
    if (match1 != null) {
      final quantity = double.tryParse(match1.group(1)?.replaceAll(',', '.') ?? '') ?? 0.0;
      final unit = _normalizeUnit(match1.group(2) ?? '');
      final name = (match1.group(3) ?? '').trim();
      
      if (name.isNotEmpty) {
        return {
          'ingredient_name': name,
          'quantity': quantity,
          'unit': unit,
          'optional': false,
        };
      }
    }
    
    // Pattern 2: "farine: 200g" ou "farine : 200 g"
    final pattern2 = RegExp(r'^(.+?):\s*(\d+(?:[.,]\d+)?)\s*(g|kg|ml|L|cl|dl|tasse|tasses|cuillère|cuillères|cuillère à soupe|cuillères à soupe|cuillère à café|cuillères à café|pièce|pièces|unité|unités|boîte|boîtes|paquet|paquets|bouteille|bouteilles|sachet|sachets)$', caseSensitive: false);
    final match2 = pattern2.firstMatch(line);
    if (match2 != null) {
      final name = match2.group(1)?.trim() ?? '';
      final quantity = double.tryParse(match2.group(2)?.replaceAll(',', '.') ?? '') ?? 0.0;
      final unit = _normalizeUnit(match2.group(3) ?? '');
      
      if (name.isNotEmpty) {
        return {
          'ingredient_name': name,
          'quantity': quantity,
          'unit': unit,
          'optional': false,
        };
      }
    }
    
    // Pattern 3: Juste un nom (sans quantité explicite)
    // Vérifier que ce n'est pas une étape (ne contient pas de verbes d'action)
    final actionVerbs = ['mélanger', 'ajouter', 'couper', 'cuire', 'faire', 'mettre', 'verser', 'chauffer'];
    final lower = line.toLowerCase();
    final hasActionVerb = actionVerbs.any((verb) => lower.contains(verb));
    
    if (!hasActionVerb && line.length < 100) {
      return {
        'ingredient_name': line,
        'quantity': 1.0,
        'unit': 'unité',
        'optional': false,
      };
    }
    
    return null;
  }
  
  String _normalizeUnit(String unit) {
    final normalized = unit.toLowerCase().trim();
    final unitMap = {
      'cuillère': 'cuillère à soupe',
      'cuillères': 'cuillère à soupe',
      'c. à s.': 'cuillère à soupe',
      'cas': 'cuillère à soupe',
      'c. à c.': 'cuillère à café',
      'cac': 'cuillère à café',
      'pièce': 'pièce',
      'pièces': 'pièce',
      'unité': 'unité',
      'unités': 'unité',
      'tasse': 'tasse',
      'tasses': 'tasse',
    };
    
    return unitMap[normalized] ?? normalized;
  }
  
  List<Map<String, dynamic>> _extractSteps(List<String> lines) {
    final steps = <Map<String, dynamic>>[];
    bool inSteps = false;
    int stepNumber = 1;
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lower = line.toLowerCase();
      
      // Détecter le début de la section étapes
      if (lower.contains('étape') || lower.contains('step') || lower.contains('préparation') || lower.contains('preparation') || lower.contains('instruction')) {
        inSteps = true;
        continue;
      }
      
      if (inSteps) {
        // Ignorer les lignes vides
        if (line.trim().isEmpty) continue;
        
        // Ignorer les lignes qui sont clairement des ingrédients (contiennent des unités)
        if (RegExp(r'\b(g|kg|ml|L|cl|dl|tasse|cuillère|pièce|unité|boîte|paquet|bouteille|sachet)\b', caseSensitive: false).hasMatch(line)) {
          continue;
        }
        
        // Patterns: "1. instruction", "1) instruction", "- instruction", ou juste l'instruction
        String cleaned = line.replaceFirst(RegExp(r'^[-•\d+\.\)]\s*'), '').trim();
        
        // Si la ligne commence par un chiffre suivi d'un point ou parenthèse, c'est probablement une étape numérotée
        if (RegExp(r'^\d+[\.\)]').hasMatch(line)) {
          cleaned = line.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '').trim();
        }
        
        if (cleaned.isNotEmpty && cleaned.length > 10) {
          steps.add({
            'step_number': stepNumber++,
            'instruction': cleaned,
            'image_url': null,
          });
        }
      }
    }
    
    return steps;
  }
  
  Map<String, int?> _extractTimes(String text) {
    final prepTime = _extractTime(text, ['préparation', 'preparation', 'prep']);
    final cookTime = _extractTime(text, ['cuisson', 'cooking', 'cook']);
    
    return {'prep': prepTime, 'cook': cookTime};
  }
  
  int? _extractTime(String text, List<String> keywords) {
    for (final keyword in keywords) {
      // Pattern: "préparation: 15 min" ou "15 minutes de préparation"
      final patterns = [
        RegExp('$keyword[\\s:]+(\\d+)\\s*(?:min|minute|minutes)?', caseSensitive: false),
        RegExp('(\\d+)\\s*(?:min|minute|minutes)\\s+(?:de\\s+)?$keyword', caseSensitive: false),
        RegExp('(\\d+)\\s*(?:min|minute|minutes)', caseSensitive: false),
      ];
      
      for (final pattern in patterns) {
        final match = pattern.firstMatch(text);
        if (match != null) {
          final time = int.tryParse(match.group(1) ?? '');
          if (time != null && time > 0 && time < 1000) {
            return time;
          }
        }
      }
    }
    return null;
  }
  
  String? _extractDifficulty(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('facile') || lower.contains('easy') || lower.contains('simple')) return 'Facile';
    if (lower.contains('moyen') || lower.contains('medium') || lower.contains('intermédiaire') || lower.contains('intermediaire')) return 'Moyen';
    if (lower.contains('difficile') || lower.contains('hard') || lower.contains('difficult') || lower.contains('complexe')) return 'Difficile';
    return null;
  }
  
  int? _extractServings(String text) {
    // Pattern: "4 personnes", "pour 4", "serves 4", "4 portions"
    final patterns = [
      RegExp(r'(\d+)\s*(?:personne|personnes|portion|portions|serving|servings)', caseSensitive: false),
      RegExp(r'(?:pour|serves?)\s+(\d+)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final servings = int.tryParse(match.group(1) ?? '');
        if (servings != null && servings > 0 && servings < 100) {
          return servings;
        }
      }
    }
    return null;
  }
}

