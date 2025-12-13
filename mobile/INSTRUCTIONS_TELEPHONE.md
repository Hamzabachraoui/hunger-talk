# 📱 Instructions pour Tester sur Téléphone

## ⚡ Démarrage Rapide

### 1. Modifier l'URL du Backend

Ouvrez `mobile/lib/core/config/app_config.dart` et vérifiez/modifiez l'IP:

```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://192.168.11.108:8000', // Votre IP locale
);
```

**Si cette IP ne fonctionne pas**, trouvez votre IP avec:
```bash
ipconfig
```
Cherchez "Adresse IPv4" de votre carte réseau principale (pas Docker/WSL).

### 2. Connecter votre Téléphone

1. **Activez le mode développeur:**
   - Paramètres > À propos du téléphone
   - Appuyez 7 fois sur "Numéro de build"

2. **Activez le débogage USB:**
   - Paramètres > Options pour les développeurs
   - Activez "Débogage USB"

3. **Connectez via USB** et acceptez l'autorisation

### 3. Vérifier la Connexion

```bash
cd mobile
flutter devices
```

Vous devriez voir votre téléphone dans la liste.

### 4. Démarrer le Backend

```bash
cd ..
docker-compose up -d
```

Vérifiez que le backend est accessible:
- Sur PC: http://localhost:8000/docs
- Sur téléphone (même WiFi): http://VOTRE_IP:8000/docs

### 5. Lancer l'Application

```bash
cd mobile
flutter run
```

Flutter détectera automatiquement votre téléphone et lancera l'app.

## 🔧 Configuration Alternative

Si vous voulez changer l'URL sans modifier le code:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.11.108:8000
```

## ✅ Vérifications

1. **Backend accessible depuis téléphone:**
   - Ouvrez Chrome sur le téléphone
   - Allez sur `http://VOTRE_IP:8000/docs`
   - Vous devriez voir Swagger UI

2. **Application fonctionne:**
   - L'app se lance sans erreur
   - Vous pouvez vous inscrire/connecter
   - Les appels API fonctionnent

## 🐛 Dépannage

### Téléphone non détecté
```bash
adb devices
# Si vide, essayez:
adb kill-server
adb start-server
```

### Erreur de connexion au backend
1. Vérifiez que PC et téléphone sont sur le même WiFi
2. Vérifiez le firewall Windows (port 8000)
3. Vérifiez l'IP dans `app_config.dart`

### Erreurs de compilation
```bash
flutter clean
flutter pub get
flutter run
```

## 📦 Build APK

Pour installer directement sur le téléphone:

```bash
flutter build apk --release
```

L'APK sera dans: `build/app/outputs/flutter-apk/app-release.apk`

Transférez-le sur le téléphone et installez-le.

