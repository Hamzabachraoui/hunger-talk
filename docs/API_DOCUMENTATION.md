# 📚 Documentation API - Hunger-Talk

Version de l'API : 1.0.0  
Base URL : `http://localhost:8000/api`

---

## 🔐 Authentification

L'API utilise JWT (JSON Web Tokens) pour l'authentification.  
Tous les endpoints protégés nécessitent un header :
```
Authorization: Bearer <token>
```

---

## 📋 Endpoints

### 🔑 Authentification

#### POST `/api/auth/register`

Inscription d'un nouvel utilisateur.

**Requête** :
```json
{
  "email": "user@example.com",
  "password": "MotDePasse123!",
  "first_name": "Jean",
  "last_name": "Dupont"
}
```

**Réponse 201** :
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "first_name": "Jean",
    "last_name": "Dupont"
  }
}
```

**Erreurs** :
- `400` : Données invalides (email déjà existant, mot de passe faible)
- `422` : Erreur de validation

---

#### POST `/api/auth/login`

Connexion d'un utilisateur.

**Requête** :
```json
{
  "email": "user@example.com",
  "password": "MotDePasse123!"
}
```

**Réponse 200** :
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "first_name": "Jean",
    "last_name": "Dupont"
  }
}
```

**Erreurs** :
- `401` : Identifiants incorrects
- `422` : Erreur de validation

---

#### POST `/api/auth/logout`

Déconnexion (invalidation du token).

**Headers** : `Authorization: Bearer <token>`

**Réponse 200** :
```json
{
  "message": "Déconnexion réussie"
}
```

---

### 👤 Utilisateur

#### GET `/api/user/profile`

Récupérer le profil de l'utilisateur connecté.

**Headers** : `Authorization: Bearer <token>`

**Réponse 200** :
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "first_name": "Jean",
  "last_name": "Dupont",
  "created_at": "2024-01-01T00:00:00Z",
  "last_login": "2024-01-15T10:30:00Z"
}
```

---

#### PUT `/api/user/profile`

Mettre à jour le profil utilisateur.

**Headers** : `Authorization: Bearer <token>`

**Requête** :
```json
{
  "first_name": "Jean",
  "last_name": "Dupont"
}
```

**Réponse 200** :
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "first_name": "Jean",
  "last_name": "Dupont",
  "updated_at": "2024-01-15T10:35:00Z"
}
```

---

### 📦 Gestion du Stock

#### GET `/api/stock`

Récupérer la liste du stock de l'utilisateur.

**Headers** : `Authorization: Bearer <token>`

**Query Parameters** :
- `category_id` (optionnel) : Filtrer par catégorie
- `sort` (optionnel) : `expiry_date` | `name` | `added_at` (défaut: `expiry_date`)
- `expiring_soon` (optionnel) : `true` pour ne voir que les produits expirant bientôt

**Réponse 200** :
```json
{
  "items": [
    {
      "id": "uuid",
      "name": "Pommes",
      "quantity": 5,
      "unit": "unité",
      "category": {
        "id": 1,
        "name": "Fruits",
        "icon": "🍎"
      },
      "expiry_date": "2024-01-20",
      "added_at": "2024-01-10T00:00:00Z",
      "notes": "Bio"
    }
  ],
  "total": 1,
  "expiring_soon_count": 1
}
```

---

#### POST `/api/stock`

Ajouter un produit au stock.

**Headers** : `Authorization: Bearer <token>`

**Requête** :
```json
{
  "name": "Pommes",
  "quantity": 5,
  "unit": "unité",
  "category_id": 1,
  "expiry_date": "2024-01-20",
  "notes": "Bio"
}
```

**Réponse 201** :
```json
{
  "id": "uuid",
  "name": "Pommes",
  "quantity": 5,
  "unit": "unité",
  "category_id": 1,
  "expiry_date": "2024-01-20",
  "added_at": "2024-01-10T00:00:00Z"
}
```

---

#### PUT `/api/stock/{item_id}`

Modifier un produit du stock.

**Headers** : `Authorization: Bearer <token>`

**Requête** :
```json
{
  "quantity": 3,
  "expiry_date": "2024-01-25"
}
```

**Réponse 200** : Item mis à jour

---

#### DELETE `/api/stock/{item_id}`

Supprimer un produit du stock.

**Headers** : `Authorization: Bearer <token>`

**Réponse 200** :
```json
{
  "message": "Produit supprimé avec succès"
}
```

**Erreurs** :
- `404` : Produit non trouvé
- `403` : Produit n'appartient pas à l'utilisateur

---

### 🤖 Chat avec l'IA

#### POST `/api/chat`

Envoyer un message à l'IA pour obtenir des recommandations de recettes.

**Headers** : `Authorization: Bearer <token>`

**Requête** :
```json
{
  "message": "J'ai envie de quelque chose de sucré avec ce que j'ai dans mon stock"
}
```

**Réponse 200** :
```json
{
  "response": "Avec votre stock actuel, je vous recommande...",
  "recipes": [
    {
      "id": "uuid",
      "name": "Tarte aux pommes",
      "match_score": 0.95,
      "available_ingredients": 8,
      "missing_ingredients": 2
    }
  ],
  "context_used": {
    "stock_items_count": 15,
    "preferences_applied": true
  },
  "response_time_ms": 1200
}
```

**Erreurs** :
- `503` : Service IA indisponible
- `408` : Timeout

---

### 🍽️ Recettes

#### GET `/api/recipes`

Récupérer la liste des recettes disponibles.

**Headers** : `Authorization: Bearer <token>`

**Query Parameters** :
- `category` (optionnel) : Filtrer par catégorie d'ingrédients
- `difficulty` (optionnel) : `Facile` | `Moyen` | `Difficile`
- `max_time` (optionnel) : Temps maximum en minutes
- `available_only` (optionnel) : `true` pour ne voir que les recettes réalisables
- `limit` (optionnel) : Nombre de résultats (défaut: 20)
- `offset` (optionnel) : Pagination (défaut: 0)

**Réponse 200** :
```json
{
  "recipes": [
    {
      "id": "uuid",
      "name": "Tarte aux pommes",
      "description": "Une délicieuse tarte aux pommes maison",
      "preparation_time": 30,
      "cooking_time": 45,
      "difficulty": "Moyen",
      "servings": 6,
      "nutrition": {
        "calories": 320,
        "proteins": 5,
        "carbohydrates": 50,
        "fats": 12
      },
      "is_available": true,
      "available_percentage": 85
    }
  ],
  "total": 50,
  "limit": 20,
  "offset": 0
}
```

---

#### GET `/api/recipes/{recipe_id}`

Récupérer les détails complets d'une recette.

**Headers** : `Authorization: Bearer <token>`

**Réponse 200** :
```json
{
  "id": "uuid",
  "name": "Tarte aux pommes",
  "description": "Une délicieuse tarte aux pommes maison",
  "preparation_time": 30,
  "cooking_time": 45,
  "total_time": 75,
  "difficulty": "Moyen",
  "servings": 6,
  "image_url": "https://...",
  "ingredients": [
    {
      "name": "Pommes",
      "quantity": 6,
      "unit": "unité",
      "optional": false,
      "in_stock": true,
      "stock_quantity": 8
    }
  ],
  "steps": [
    {
      "step_number": 1,
      "instruction": "Éplucher et couper les pommes en tranches"
    }
  ],
  "nutrition": {
    "calories": 320,
    "proteins": 5,
    "carbohydrates": 50,
    "fats": 12,
    "fiber": 4,
    "per_serving": true
  },
  "is_available": true,
  "missing_ingredients": []
}
```

---

#### POST `/api/recipes/{recipe_id}/cook`

Valider la cuisson d'une recette et mettre à jour le stock.

**Headers** : `Authorization: Bearer <token>`

**Requête** :
```json
{
  "servings_made": 6,
  "notes": "Très bon !"
}
```

**Réponse 200** :
```json
{
  "message": "Recette cuisinée avec succès",
  "stock_updated": true,
  "items_consumed": [
    {
      "item_id": "uuid",
      "name": "Pommes",
      "quantity_used": 6,
      "remaining": 2
    }
  ],
  "items_removed": []
}
```

**Erreurs** :
- `400` : Ingrédients manquants
- `404` : Recette non trouvée

---

### 📊 Nutrition

#### GET `/api/nutrition/daily`

Récupérer les statistiques nutritionnelles du jour.

**Headers** : `Authorization: Bearer <token>`

**Query Parameters** :
- `date` (optionnel) : Date au format YYYY-MM-DD (défaut: aujourd'hui)

**Réponse 200** :
```json
{
  "date": "2024-01-15",
  "stats": {
    "calories": 1850,
    "proteins": 85,
    "carbohydrates": 220,
    "fats": 65
  },
  "goals": {
    "calories": 2000,
    "proteins": 100,
    "carbohydrates": 250,
    "fats": 70
  },
  "progress": {
    "calories": 0.925,
    "proteins": 0.85,
    "carbohydrates": 0.88,
    "fats": 0.93
  },
  "recipes_cooked": [
    {
      "recipe_id": "uuid",
      "name": "Tarte aux pommes",
      "servings": 6
    }
  ]
}
```

---

#### GET `/api/nutrition/weekly`

Récupérer les statistiques nutritionnelles de la semaine.

**Headers** : `Authorization: Bearer <token>`

**Query Parameters** :
- `week_start` (optionnel) : Date de début de semaine (défaut: lundi de cette semaine)

**Réponse 200** :
```json
{
  "week_start": "2024-01-08",
  "daily_stats": [
    {
      "date": "2024-01-08",
      "calories": 1950,
      "proteins": 90,
      "carbohydrates": 230,
      "fats": 68
    }
  ],
  "weekly_averages": {
    "calories": 1920,
    "proteins": 88,
    "carbohydrates": 225,
    "fats": 67
  }
}
```

---

### 🔔 Notifications

#### GET `/api/notifications`

Récupérer les notifications de l'utilisateur.

**Headers** : `Authorization: Bearer <token>`

**Query Parameters** :
- `unread_only` (optionnel) : `true` pour ne voir que les non lues
- `limit` (optionnel) : Nombre de résultats (défaut: 20)

**Réponse 200** :
```json
{
  "notifications": [
    {
      "id": "uuid",
      "type": "expiry",
      "title": "Produits expirant bientôt",
      "message": "3 produits expireront dans les 2 prochains jours",
      "is_read": false,
      "related_item_id": "uuid",
      "created_at": "2024-01-15T10:00:00Z"
    }
  ],
  "unread_count": 5
}
```

---

#### POST `/api/notifications/{notification_id}/read`

Marquer une notification comme lue.

**Headers** : `Authorization: Bearer <token>`

**Réponse 200** :
```json
{
  "message": "Notification marquée comme lue"
}
```

---

### 🛒 Liste de Courses

#### GET `/api/shopping-list`

Récupérer la liste de courses.

**Headers** : `Authorization: Bearer <token>`

**Query Parameters** :
- `purchased_only` (optionnel) : `true` pour ne voir que les produits achetés

**Réponse 200** :
```json
{
  "items": [
    {
      "id": "uuid",
      "item_name": "Lait",
      "quantity": 2,
      "unit": "litre",
      "category": {
        "id": 4,
        "name": "Produits laitiers"
      },
      "is_purchased": false,
      "added_at": "2024-01-15T09:00:00Z"
    }
  ],
  "total": 1,
  "purchased_count": 0
}
```

---

#### POST `/api/shopping-list`

Ajouter un élément à la liste de courses.

**Headers** : `Authorization: Bearer <token>`

**Requête** :
```json
{
  "item_name": "Lait",
  "quantity": 2,
  "unit": "litre",
  "category_id": 4,
  "notes": "Bio si possible"
}
```

**Réponse 201** : Item créé

---

#### DELETE `/api/shopping-list/{item_id}`

Supprimer un élément de la liste de courses.

**Headers** : `Authorization: Bearer <token>`

**Réponse 200** :
```json
{
  "message": "Élément supprimé de la liste de courses"
}
```

---

### ⚙️ Préférences Utilisateur

#### GET `/api/user/preferences`

Récupérer les préférences de l'utilisateur.

**Headers** : `Authorization: Bearer <token>`

**Réponse 200** :
```json
{
  "dietary_restrictions": ["halal", "gluten-free"],
  "allergies": ["peanuts", "lactose"],
  "daily_calorie_goal": 2000,
  "daily_protein_goal": 100,
  "daily_carb_goal": 250,
  "daily_fat_goal": 70,
  "preferred_cuisines": ["french", "italian"],
  "disliked_ingredients": ["coriander"],
  "max_prep_time": 30,
  "max_cooking_time": 60
}
```

---

#### PUT `/api/user/preferences`

Mettre à jour les préférences utilisateur.

**Headers** : `Authorization: Bearer <token>`

**Requête** :
```json
{
  "dietary_restrictions": ["halal", "gluten-free"],
  "allergies": ["peanuts"],
  "daily_calorie_goal": 2000,
  "max_prep_time": 30
}
```

**Réponse 200** : Préférences mises à jour

---

## 📝 Modèles de Données (Pydantic Schemas)

### User
```python
{
    "id": UUID,
    "email": str,
    "first_name": Optional[str],
    "last_name": Optional[str],
    "created_at": datetime,
    "updated_at": datetime
}
```

### StockItem
```python
{
    "id": UUID,
    "user_id": UUID,
    "name": str,
    "quantity": float,
    "unit": str,
    "category_id": Optional[int],
    "expiry_date": Optional[date],
    "added_at": datetime,
    "notes": Optional[str]
}
```

### Recipe
```python
{
    "id": UUID,
    "name": str,
    "description": Optional[str],
    "preparation_time": Optional[int],
    "cooking_time": Optional[int],
    "difficulty": Optional[str],
    "servings": int,
    "ingredients": List[RecipeIngredient],
    "steps": List[RecipeStep],
    "nutrition": Optional[NutritionData]
}
```

---

## 🔢 Codes d'Erreur HTTP

- `200` : Succès
- `201` : Créé avec succès
- `400` : Requête invalide
- `401` : Non authentifié
- `403` : Accès interdit
- `404` : Ressource non trouvée
- `408` : Timeout
- `422` : Erreur de validation
- `500` : Erreur serveur
- `503` : Service indisponible

---

## 📖 Format des Erreurs

Toutes les erreurs suivent ce format :

```json
{
  "detail": "Message d'erreur",
  "code": "ERROR_CODE",
  "field": "champ_en_erreur" // si applicable
}
```

---

## 🔄 Pagination

Les endpoints qui retournent des listes supportent la pagination :

**Query Parameters** :
- `limit` : Nombre d'éléments par page (défaut: 20, max: 100)
- `offset` : Nombre d'éléments à sauter (défaut: 0)

**Réponse** :
```json
{
  "items": [...],
  "total": 100,
  "limit": 20,
  "offset": 0,
  "has_more": true
}
```

---

## 📅 Format des Dates

Toutes les dates sont au format ISO 8601 : `YYYY-MM-DD` ou `YYYY-MM-DDTHH:MM:SSZ`

---

## 🔐 Sécurité

- Tous les mots de passe sont hashés avec Bcrypt
- Les tokens JWT expirent après 30 minutes (configurable)
- Les tokens sont vérifiés à chaque requête protégée
- Les données utilisateur sont isolées par `user_id`

---

**Dernière mise à jour** : 2024-01-15

