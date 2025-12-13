# 🧠 Conception du Système RAG - Hunger-Talk

## 📋 Vue d'ensemble

Le système RAG (Retrieval Augmented Generation) permet à l'IA de fournir des recommandations de recettes pertinentes basées sur :
- Le stock actuel de l'utilisateur
- Ses préférences alimentaires
- Ses objectifs nutritionnels
- Les recettes disponibles dans la base

---

## 🔄 Flux du Système RAG

```
1. Utilisateur envoie un message
   ↓
2. Récupération du contexte :
   - Stock actuel formaté
   - Préférences utilisateur
   - Recettes disponibles
   - Objectifs nutritionnels
   ↓
3. Construction du prompt RAG
   ↓
4. Envoi à Ollama (LLaMA 3.1:8b)
   ↓
5. Parsing de la réponse
   ↓
6. Extraction des recettes suggérées
   ↓
7. Retour à l'utilisateur + sauvegarde
```

---

## 📊 Format du Contexte

### 1. Stock Actuel Formaté

```json
{
  "stock": {
    "items": [
      {
        "name": "Pommes",
        "quantity": 8,
        "unit": "unité",
        "category": "Fruits",
        "expiry_date": "2024-01-20",
        "days_until_expiry": 5
      }
    ],
    "summary": {
      "total_items": 15,
      "categories": ["Fruits", "Légumes", "Viande"],
      "expiring_soon": 3
    }
  }
}
```

**Format texte pour l'IA** :
```
Stock actuel de l'utilisateur :
- Pommes : 8 unités (expire le 2024-01-20, dans 5 jours)
- Carottes : 500g (expire le 2024-01-18, dans 3 jours)
- Poulet : 2 unités (expire le 2024-01-22, dans 7 jours)
...
Total : 15 produits, 3 expirant bientôt (dans moins de 3 jours)
```

---

### 2. Préférences Utilisateur Formatées

```json
{
  "preferences": {
    "dietary_restrictions": ["halal", "gluten-free"],
    "allergies": ["peanuts", "lactose"],
    "preferred_cuisines": ["french", "italian"],
    "disliked_ingredients": ["coriander"],
    "time_constraints": {
      "max_prep_time": 30,
      "max_cooking_time": 60
    }
  }
}
```

**Format texte pour l'IA** :
```
Préférences alimentaires :
- Restrictions : halal, sans gluten
- Allergies : arachides, lactose
- Cuisines préférées : française, italienne
- Ingrédients à éviter : coriandre
- Contraintes de temps : préparation max 30min, cuisson max 60min
```

---

### 3. Objectifs Nutritionnels Formatés

```json
{
  "nutrition_goals": {
    "daily_calorie_goal": 2000,
    "daily_protein_goal": 100,
    "daily_carb_goal": 250,
    "daily_fat_goal": 70,
    "today_progress": {
      "calories": 1200,
      "proteins": 60,
      "carbohydrates": 150,
      "fats": 40
    }
  }
}
```

**Format texte pour l'IA** :
```
Objectifs nutritionnels quotidiens :
- Calories : 2000 kcal (1200/2000 aujourd'hui, 800 restantes)
- Protéines : 100g (60/100 aujourd'hui, 40g restantes)
- Glucides : 250g (150/250 aujourd'hui, 100g restantes)
- Lipides : 70g (40/70 aujourd'hui, 30g restantes)
```

---

### 4. Recettes Disponibles Formatées

```json
{
  "recipes": [
    {
      "id": "uuid",
      "name": "Tarte aux pommes",
      "difficulty": "Moyen",
      "total_time": 75,
      "servings": 6,
      "ingredients": ["Pommes", "Farine", "Beurre", "Sucre"],
      "nutrition": {
        "calories": 320,
        "proteins": 5,
        "carbohydrates": 50,
        "fats": 12
      },
      "match_score": 0.95,
      "available_ingredients": 4,
      "missing_ingredients": 0
    }
  ],
  "top_matches": 5
}
```

**Format texte pour l'IA** :
```
Recettes disponibles (top 5) :
1. Tarte aux pommes (Compatible à 95%)
   - Ingrédients : Pommes, Farine, Beurre, Sucre
   - Tous les ingrédients disponibles
   - Temps : 75min, Difficulté : Moyen
   - Nutrition : 320 kcal, 5g protéines, 50g glucides, 12g lipides

2. Salade de carottes (Compatible à 90%)
   ...
```

---

## 📝 Prompt Système

```
Tu es un assistant culinaire intelligent pour l'application Hunger-Talk. 
Ton rôle est d'aider les utilisateurs à cuisiner avec les ingrédients qu'ils ont déjà dans leur stock.

CONTEXTE FOURNI :
- Stock actuel de l'utilisateur (produits disponibles avec quantités et dates d'expiration)
- Préférences alimentaires (restrictions, allergies, cuisines préférées)
- Objectifs nutritionnels quotidiens
- Recettes disponibles compatibles avec le stock

INSTRUCTIONS :
1. Analyse le stock disponible et les préférences de l'utilisateur
2. Recommande des recettes pertinentes en priorisant :
   - Les recettes avec tous les ingrédients disponibles
   - Les produits expirant bientôt
   - Les objectifs nutritionnels de l'utilisateur
   - Les préférences alimentaires
3. Si des ingrédients manquent, suggère des alternatives ou des produits à acheter
4. Adapte les recommandations au contexte du message de l'utilisateur
5. Formate ta réponse de manière claire et engageante
6. Inclus les informations nutritionnelles pertinentes

FORMAT DE RÉPONSE :
- Réponse naturelle et conversationnelle
- Liste des recettes recommandées avec leurs IDs
- Explication de pourquoi ces recettes sont recommandées
- Suggestions d'alternatives si nécessaire

IMPORTANT :
- Respecte absolument les allergies et restrictions alimentaires
- Priorise les produits expirant bientôt pour réduire le gaspillage
- Considère les objectifs nutritionnels quotidiens
- Sois créatif mais pratique
```

---

## 🔍 Exemple de Contexte Complet

```
[STOCK ACTUEL]
Produits disponibles :
- Pommes : 8 unités (expire le 2024-01-20, dans 5 jours)
- Carottes : 500g (expire le 2024-01-18, dans 3 jours) ⚠️ Expire bientôt
- Poulet : 2 unités (expire le 2024-01-22, dans 7 jours)
- Farine : 1kg
- Beurre : 250g
- Oeufs : 6 unités

Total : 6 produits, 1 expirant bientôt

[PRÉFÉRENCES]
- Restrictions : halal
- Allergies : arachides
- Cuisines préférées : française, italienne
- Temps max : préparation 30min, cuisson 60min

[OBJECTIFS NUTRITIONNELS]
Calories restantes aujourd'hui : 800/2000
Protéines restantes : 40g/100g

[RECETTES DISPONIBLES]
1. Tarte aux pommes (ID: abc-123)
   Compatible : 95%, Tous ingrédients disponibles
   Temps : 75min, Calories : 320/portion

2. Salade de carottes (ID: def-456)
   Compatible : 90%, Tous ingrédients disponibles
   Temps : 15min, Calories : 150/portion

[MESSAGE UTILISATEUR]
"J'ai envie de quelque chose de sucré avec ce que j'ai"
```

---

## 📤 Format de Réponse Attendue

L'IA doit retourner une réponse dans ce format :

```json
{
  "response": "Avec votre stock actuel, je vous recommande une délicieuse tarte aux pommes ! Vous avez tous les ingrédients nécessaires et vos pommes expirent dans 5 jours, c'est le moment parfait pour les utiliser...",
  "recipes_recommended": [
    {
      "recipe_id": "abc-123",
      "name": "Tarte aux pommes",
      "reason": "Tous les ingrédients disponibles, utilise vos pommes qui expirent bientôt, satisfait votre envie de sucré"
    }
  ],
  "suggestions": [
    "Vous pourriez aussi préparer une salade de carottes en entrée pour utiliser vos carottes qui expirent dans 3 jours"
  ]
}
```

---

## 🎯 Extraction des Recettes

### Méthode 1 : Parsing de la réponse texte

L'IA mentionne les IDs de recettes dans sa réponse :
```
"Je recommande la recette [ID: abc-123] Tarte aux pommes..."
```

### Méthode 2 : Format structuré

L'IA retourne directement les IDs dans un format JSON :
```json
{
  "recipes": ["abc-123", "def-456"]
}
```

### Méthode 3 : Matching par nom

Si l'IA mentionne seulement les noms, on fait un matching avec la base :
```python
# Extraire les noms mentionnés
recipe_names = extract_recipe_names(ai_response)

# Rechercher dans la base
recipes = db.query(Recipe).filter(Recipe.name.in_(recipe_names)).all()
```

---

## 🔧 Utilisation de FAISS (Optionnel pour plus tard)

Pour améliorer la pertinence, on peut utiliser FAISS pour :

1. **Vectorisation des recettes** :
   - Convertir chaque recette en vecteur (ingrédients, nutrition, difficulté, temps)
   - Stocker dans un index FAISS

2. **Recherche vectorielle** :
   - Vectoriser la requête utilisateur
   - Trouver les recettes les plus similaires
   - Limiter le contexte envoyé à l'IA aux top N recettes

3. **Avantages** :
   - Recherche plus rapide
   - Meilleure pertinence
   - Réduction du contexte (moins de tokens)

---

## 📝 Exemples de Prompts Utilisateur

### Exemple 1 : Envie spécifique
```
Utilisateur : "J'ai envie de quelque chose de sucré"
→ IA doit prioriser les desserts et recettes sucrées
```

### Exemple 2 : Produits expirant
```
Utilisateur : "Que puis-je faire avec mes produits qui expirent bientôt ?"
→ IA doit identifier les produits expirant bientôt et proposer des recettes
```

### Exemple 3 : Objectif nutritionnel
```
Utilisateur : "J'ai besoin de plus de protéines aujourd'hui"
→ IA doit prioriser les recettes riches en protéines
```

### Exemple 4 : Contrainte de temps
```
Utilisateur : "Quelque chose de rapide, j'ai 20 minutes"
→ IA doit filtrer par temps total < 20 minutes
```

---

## ⚙️ Paramètres de Configuration

```python
RAG_CONFIG = {
    "max_recipes_in_context": 10,  # Nombre max de recettes dans le contexte
    "max_tokens_context": 2000,    # Nombre max de tokens dans le contexte
    "temperature": 0.7,             # Créativité de l'IA (0-1)
    "max_tokens_response": 500,     # Longueur max de la réponse
    "timeout_seconds": 30,          # Timeout pour la requête IA
    "use_faiss": False,             # Utiliser FAISS pour la recherche (futur)
    "min_match_score": 0.7          # Score minimum pour inclure une recette
}
```

---

## 🐛 Gestion des Erreurs

### IA non disponible
```json
{
  "error": "Le service IA est temporairement indisponible",
  "fallback": "Voici les 5 recettes les plus compatibles avec votre stock",
  "recipes": [...]
}
```

### Timeout
```json
{
  "error": "La requête a pris trop de temps",
  "recipes": [...]  // Recettes basées sur le matching simple
}
```

### Aucune recette trouvée
```json
{
  "message": "Aucune recette complète avec votre stock actuel",
  "suggestions": [
    "Ajoutez ces ingrédients pour préparer...",
    "Voici des recettes alternatives avec substitutions..."
  ]
}
```

---

## 📊 Métriques à Tracker

Pour améliorer le système :
- Temps de réponse moyen
- Taux de satisfaction (via ratings)
- Nombre de recettes suggérées vs cuisinées
- Précision des recommandations

---

**Ce système RAG sera implémenté dans la PHASE 2 : Développement Backend**

