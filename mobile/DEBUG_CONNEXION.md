# Guide de débogage de la connexion

## Problème : Erreur "type 'Null' is not a subtype of type 'Map<String, dynamic>'"

## Étapes de débogage

### 1. Vérifier l'URL du backend

L'application utilise actuellement : `http://192.168.11.108:8000`

**Pour vérifier/modifier l'URL :**
- Ouvrez : `mobile/lib/core/config/app_config.dart`
- Modifiez la ligne 19 si nécessaire

**Pour trouver votre IP locale :**
```bash
ipconfig
# Cherchez "Adresse IPv4" dans la section de votre connexion Wi-Fi
```

### 2. Tester la connexion depuis le navigateur du téléphone

1. Ouvrez le navigateur sur votre téléphone
2. Allez à : `http://192.168.11.108:8000/docs`
3. Vous devriez voir la documentation Swagger
4. Testez l'endpoint `/api/auth/login` avec :
   ```json
   {
     "email": "test@hungertalk.com",
     "password": "Test1234!"
   }
   ```

### 3. Voir les logs détaillés

**Option A : Via Flutter (Recommandé)**
```bash
cd mobile
flutter logs
```

**Option B : Via le script**
```bash
cd mobile
view_logs_simple.bat
```

**Ce que vous verrez dans les logs :**
- 🌐 `[API] POST` : La requête envoyée
- 📥 `[API] Response` : Le code de statut HTTP
- 📦 `[API] Parsed result` : La réponse parsée
- 🔐 `[AUTH]` : Les étapes de l'authentification
- ❌ `[AUTH] Error` : Les erreurs détaillées

### 4. Vérifier les informations de connexion

**Créer un utilisateur de test :**

Si vous n'avez pas encore d'utilisateur, créez-en un via Swagger :
1. Allez à `http://192.168.11.108:8000/docs`
2. Utilisez l'endpoint `POST /api/auth/register`
3. Créez un compte avec :
   - Email : `test@hungertalk.com`
   - Password : `Test1234!`
   - first_name : `Test`
   - last_name : `User`

### 5. Vérifier que le backend est accessible

**Depuis votre PC :**
```bash
curl http://192.168.11.108:8000/api/health
```

**Depuis le navigateur du téléphone :**
- Allez à : `http://192.168.11.108:8000/docs`

### 6. Problèmes courants

**Problème : "Réponse null"**
- Le backend ne répond pas
- Vérifiez que le backend tourne : `docker-compose ps`
- Vérifiez l'URL dans `app_config.dart`

**Problème : "Format de réponse invalide"**
- Le backend retourne un format inattendu
- Regardez les logs pour voir la réponse exacte
- Vérifiez que le backend retourne bien JSON

**Problème : "access_token manquant"**
- Le backend retourne une réponse mais sans token
- Vérifiez les logs pour voir la structure de la réponse
- Vérifiez que l'email/mot de passe sont corrects

### 7. Logs à rechercher

Quand vous essayez de vous connecter, cherchez dans les logs :

```
🔐 [AUTH] Tentative de connexion pour: ...
🌐 [API] POST http://192.168.11.108:8000/api/auth/login
📥 [API] POST Response: 200
📦 [API] POST Parsed result: {access_token: ..., token_type: bearer}
🔐 [AUTH PROVIDER] Réponse reçue: ...
✅ [AUTH PROVIDER] Token récupéré: ...
```

Si vous voyez une erreur, notez :
- Le code de statut HTTP
- Le body de la réponse
- Le type de la réponse parsée

### 8. Réinstaller l'APK

Après avoir reconstruit l'APK :
1. Désinstallez l'ancienne version sur votre téléphone
2. Installez la nouvelle : `mobile/build/app/outputs/flutter-apk/app-release.apk`
3. Réessayez de vous connecter
4. Regardez les logs en temps réel

