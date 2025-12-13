# 🔍 Analyse complète de l'erreur 307 - Solution finale

## 📋 Problème identifié

**Erreur :** `Exception: Erreur 307` sur POST `/api/stock` et POST `/api/chat`

**Cause confirmée :**
- FastAPI redirige `/api/stock` → `/api/stock/` (307)
- FastAPI redirige `/api/chat` → `/api/chat/` (307)
- Le client HTTP de Flutter (`package:http`) **ne suit PAS** les redirections 307/308 pour POST/PUT

**Test backend confirmé :**
```bash
POST /api/stock → 307 (Location: /api/stock/)
POST /api/stock/ → 403 (pas de token, mais pas de redirection)
```

---

## ✅ Solutions appliquées (en cascade)

### **1. Liste explicite des routes racine**
```dart
static const List<String> _postRootEndpoints = [
  '/stock',
  '/chat',
  '/recipes',
  '/shopping-list',
  '/recommendations',
];
```

### **2. Détection automatique des routes racine**
- Vérifie si l'endpoint est dans la liste explicite
- OU si c'est une route à 1 seul segment
- Ajoute automatiquement le trailing slash

### **3. Vérification après Uri.parse()**
**NOUVEAU :** `Uri.parse()` peut potentiellement modifier l'URL. Ajout d'une vérification après parsing :

```dart
var url = Uri.parse(normalizedUrl);
final finalPath = url.path;

// Si le trailing slash a été perdu, le réajouter
if (shouldHaveTrailing && !finalPath.endsWith('/')) {
  url = url.replace(path: '$finalPath/');
}
```

### **4. Logs détaillés pour débogage**
- URL normalisée (string)
- URL après Uri.parse()
- Path après parsing
- Si le trailing slash est présent
- Si correction nécessaire

### **5. Détection explicite des redirections 307**
Si une redirection 307 est quand même détectée, l'erreur affiche :
- L'URL demandée
- L'URL de redirection (Location)
- Un message explicite

---

## 🔧 Fichiers modifiés

1. ✅ `api_service.dart`
   - Liste explicite des routes racine
   - Détection améliorée
   - **Vérification après Uri.parse()** (NOUVEAU)
   - Logs détaillés
   - Détection explicite des redirections 307

---

## 📊 Logs attendus

### **Si tout fonctionne :**
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
   URL normalisée (string): http://192.168.11.108:8000/api/stock/
   URL après Uri.parse(): http://192.168.11.108:8000/api/stock/
   Path après parsing: /api/stock/
   Path se termine par /: true
   Devrait avoir trailing: true
🌐 [API] POST http://192.168.11.108:8000/api/stock/
📥 [API] POST Response: 201
```

### **Si Uri.parse() enlève le trailing slash :**
```
   URL normalisée (string): http://192.168.11.108:8000/api/stock/
   URL après Uri.parse(): http://192.168.11.108:8000/api/stock
   Path après parsing: /api/stock
   Path se termine par /: false
   Devrait avoir trailing: true
   ⚠️ Trailing slash perdu après Uri.parse(), correction...
   ✅ URL corrigée: http://192.168.11.108:8000/api/stock/
```

### **Si erreur 307 persiste :**
```
⚠️ [API] Redirection 307 détectée!
   URL demandée: http://192.168.11.108:8000/api/stock
   Location: http://192.168.11.108:8000/api/stock/
```

---

## 🚀 APK mis à jour

**Emplacement :**
```
G:\EMSI\3eme annee\PFA\mobile\build\app\outputs\flutter-apk\app-release.apk
```

**Taille :** 23.0 MB

---

## 🧪 Test

1. **Installez le nouvel APK**
2. **Connectez votre téléphone en USB**
3. **Lancez les logs :**
   ```bash
   cd mobile
   flutter logs
   ```
4. **Essayez d'ajouter un produit**
5. **Regardez les logs et copiez :**
   - Toutes les lignes avec `🔧`
   - La ligne `URL après Uri.parse():`
   - La ligne `Path après parsing:`
   - La ligne `Path se termine par /:`
   - La ligne `📥 [API] POST Response:`
   - Toute ligne avec `⚠️` ou `❌`

---

## 🔍 Points de vérification

### **Si l'erreur 307 persiste, vérifiez :**

1. **Le trailing slash est-il ajouté dans `_normalizeUrl()` ?**
   - Regardez la ligne `✅ Trailing slash ajouté:`

2. **Le trailing slash est-il présent après `Uri.parse()` ?**
   - Regardez la ligne `Path se termine par /:`
   - Si `false`, la correction devrait s'activer

3. **L'URL finale utilisée est-elle correcte ?**
   - Regardez la ligne `🌐 [API] POST`
   - Elle devrait se terminer par `/`

4. **Le backend reçoit-il la bonne URL ?**
   - Regardez la ligne `📥 [API] POST Response:`
   - Si 307, regardez `URL demandée:` et `Location:`

---

## 💡 Si l'erreur persiste encore

Si après toutes ces corrections l'erreur 307 persiste, cela pourrait indiquer :

1. **Problème de cache** : L'ancien APK est peut-être encore installé
   - Désinstallez complètement l'application
   - Réinstallez le nouvel APK

2. **Problème de réseau** : Le téléphone n'atteint peut-être pas le bon backend
   - Vérifiez `AppConfig.baseUrl` dans les logs
   - Vérifiez que le backend est accessible depuis le téléphone

3. **Problème de proxy/redirection réseau** : Un proxy pourrait rediriger
   - Vérifiez les paramètres réseau du téléphone

4. **Le trailing slash est ajouté mais perdu ailleurs** : 
   - Les logs montreront exactement où

---

## ✅ Résultat attendu

Avec toutes ces corrections :
- ✅ POST `/api/stock/` → 201 Created (pas de redirection)
- ✅ POST `/api/chat/` → 200 OK (pas de redirection)
- ✅ PUT `/api/user/preferences` → 200 OK (fonctionne déjà)

---

## 📝 Partagez les logs

Si l'erreur persiste, partagez **TOUTES** les lignes de logs qui commencent par :
- `🔧`
- `🌐`
- `📥`
- `⚠️`
- `❌`

Ces logs permettront d'identifier exactement où le problème se situe.

