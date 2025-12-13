# Guide pour Tester l'Application sur Téléphone

## 📱 Prérequis

1. **Téléphone Android** connecté via USB
2. **Mode développeur activé** sur le téléphone
3. **Débogage USB activé** sur le téléphone
4. **Backend démarré** et accessible depuis le réseau local

## 🔧 Configuration

### 1. Trouver l'IP locale de votre PC

**Windows:**
```bash
ipconfig
```
Cherchez "Adresse IPv4" (ex: 192.168.1.100)

**Linux/Mac:**
```bash
ifconfig
# ou
ip addr show
```

### 2. Modifier l'URL du Backend

Dans `mobile/lib/core/constants/app_constants.dart`, remplacez:
```dart
static const String baseUrl = 'http://localhost:8000';
```

Par votre IP locale:
```dart
static const String baseUrl = 'http://192.168.1.100:8000';
```

### 3. Vérifier que le Backend est accessible

Sur votre PC, vérifiez que le backend écoute sur toutes les interfaces:
- Dans `docker-compose.yml`, le port doit être exposé: `8000:8000`
- Le backend FastAPI doit écouter sur `0.0.0.0:8000` (pas seulement `127.0.0.1`)

### 4. Vérifier le Firewall

Assurez-vous que le port 8000 est autorisé dans le firewall Windows:
1. Ouvrez "Pare-feu Windows Defender"
2. Paramètres avancés
3. Règles de trafic entrant
4. Autorisez le port 8000

## 📲 Étapes pour Tester

### 1. Connecter le Téléphone

1. Activez le **mode développeur**:
   - Allez dans Paramètres > À propos du téléphone
   - Appuyez 7 fois sur "Numéro de build"

2. Activez le **débogage USB**:
   - Paramètres > Options pour les développeurs
   - Activez "Débogage USB"

3. Connectez le téléphone via USB

4. Sur le téléphone, acceptez l'autorisation de débogage USB

### 2. Vérifier la Connexion

```bash
cd mobile
flutter devices
```

Vous devriez voir votre téléphone dans la liste.

### 3. Lancer l'Application

```bash
flutter run
```

Ou spécifiquement sur votre téléphone:
```bash
flutter run -d <device-id>
```

### 4. Tester l'Application

1. **Vérifier la connexion au backend:**
   - Ouvrez l'application
   - Essayez de vous inscrire ou vous connecter
   - Si ça ne fonctionne pas, vérifiez l'IP dans `app_constants.dart`

2. **Tester les fonctionnalités:**
   - Authentification
   - Gestion du stock
   - Recettes
   - Chat IA
   - Paramètres

## 🔍 Dépannage

### Le téléphone n'est pas détecté

1. Vérifiez que le débogage USB est activé
2. Installez les drivers USB pour votre téléphone
3. Essayez un autre câble USB
4. Redémarrez ADB:
   ```bash
   flutter doctor
   adb kill-server
   adb start-server
   ```

### L'application ne peut pas se connecter au backend

1. Vérifiez que le backend est démarré:
   ```bash
   docker-compose ps
   ```

2. Testez la connexion depuis le téléphone:
   - Ouvrez un navigateur sur le téléphone
   - Allez sur `http://VOTRE_IP:8000/docs`
   - Vous devriez voir Swagger UI

3. Vérifiez que le PC et le téléphone sont sur le même réseau WiFi

4. Vérifiez le firewall Windows

### Erreurs de compilation

1. Nettoyez le projet:
   ```bash
   flutter clean
   flutter pub get
   ```

2. Vérifiez les licences Android:
   ```bash
   flutter doctor --android-licenses
   ```

## 📦 Build APK pour Installation Directe

Si vous voulez installer l'APK directement:

```bash
flutter build apk --release
```

L'APK sera dans: `mobile/build/app/outputs/flutter-apk/app-release.apk`

Transférez-le sur votre téléphone et installez-le.

## ⚠️ Important

- **Pour la production**, utilisez une configuration d'environnement (fichier `.env` ou configuration par build)
- **Ne commitez jamais** l'IP locale dans le code
- Utilisez des variables d'environnement pour différents environnements (dev, staging, prod)

