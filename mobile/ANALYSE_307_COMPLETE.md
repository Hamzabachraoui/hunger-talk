# Analyse complète de l'erreur 307

## 🔍 Problème identifié

**Erreur :** `Exception: Erreur 307` sur POST `/api/stock` et POST `/api/chat`

**Cause racine :**
- FastAPI redirige automatiquement `/api/stock` → `/api/stock/` (307)
- FastAPI redirige automatiquement `/api/chat` → `/api/chat/` (307)
- Le client HTTP de Flutter (`package:http`) **ne suit PAS** les redirections 307/308 pour POST/PUT

**Pourquoi les préférences fonctionnent :**
- `/user/preferences` a **2 segments** (`user`, `preferences`)
- Ce n'est **pas une route racine**, donc pas de redirection
- FastAPI n'ajoute pas de trailing slash pour les routes avec plusieurs segments

## ✅ Solution appliquée

### **1. Liste explicite des routes racine**

Ajout d'une liste des endpoints POST qui nécessitent un trailing slash :
```dart
static const List<String> _postRootEndpoints = [
  '/stock',
  '/chat',
  '/recipes',
  '/shopping-list',
  '/recommendations',
];
```

### **2. Détection améliorée**

La fonction `_normalizeUrl()` vérifie maintenant :
1. Si l'endpoint est dans la liste explicite
2. OU si c'est une route à 1 seul segment
3. Si oui → ajoute le trailing slash automatiquement

### **3. Logs détaillés**

Ajout de logs pour voir exactement :
- L'endpoint original
- Les segments détectés
- Si c'est une route racine connue
- Si le trailing slash est ajouté
- L'URL finale utilisée

### **4. Détection explicite des redirections 307**

Si une redirection 307 est quand même détectée, l'erreur affiche :
- L'URL demandée
- L'URL de redirection (Location)
- Un message explicite

## 📋 Endpoints concernés

### **POST nécessitant trailing slash :**
- ✅ `/stock` → `/stock/`
- ✅ `/chat` → `/chat/`
- ✅ `/recipes` → `/recipes/` (si POST sur racine)
- ✅ `/shopping-list` → `/shopping-list/`
- ✅ `/recommendations` → `/recommendations/`

### **POST ne nécessitant PAS trailing slash :**
- ✅ `/user/preferences` (2 segments, pas de redirection)
- ✅ `/stock/123` (avec ID, pas de redirection)
- ✅ `/chat/history` (sous-route, pas de redirection)

## 🔧 Fichiers modifiés

1. ✅ `api_service.dart`
   - Liste explicite des routes racine
   - Détection améliorée
   - Logs détaillés
   - Détection explicite des redirections 307

## 🚀 APK mis à jour

**Emplacement :**
```
G:\EMSI\3eme annee\PFA\mobile\build\app\outputs\flutter-apk\app-release.apk
```

## 📊 Logs à vérifier

Lors de l'ajout d'un produit, vous devriez voir :
```
🔧 [API] POST Normalisation:
   Endpoint original: /stock
   Segments: [stock]
   Is root route: true
   🔧 Analyse: /stock
   🔧 Segments: [stock] (count: 1)
   🔧 Is known root: true
   🔧 Is single segment: true
   ✅ Trailing slash ajouté: /stock/
   🔧 URL finale: http://192.168.11.108:8000/api/stock/
🌐 [API] POST http://192.168.11.108:8000/api/stock/
📥 [API] POST Response: 201
```

## ✅ Résultat attendu

- ✅ POST `/api/stock/` → 201 Created (pas de redirection)
- ✅ POST `/api/chat/` → 200 OK (pas de redirection)
- ✅ PUT `/api/user/preferences` → 200 OK (fonctionne déjà)

## 🐛 Si l'erreur persiste

Si vous voyez encore 307 dans les logs, partagez :
1. Les lignes avec `🔧 [API] POST Normalisation:`
2. La ligne `URL finale:`
3. La ligne `📥 [API] POST Response:`
4. Toute ligne avec `⚠️` ou `❌`

Ces logs permettront d'identifier exactement où le problème se situe.

