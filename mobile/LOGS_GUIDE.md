# Guide pour voir les logs de l'application Flutter

## Méthode 1 : Logs Flutter en temps réel (Recommandé) ⭐

### Prérequis
1. Connectez votre téléphone Android à votre PC via USB
2. Activez le **Mode Développeur** et le **Débogage USB** sur votre téléphone
3. Vérifiez que votre téléphone est détecté : `flutter devices`

### Voir les logs en temps réel

**Option A : Script simple (RECOMMANDÉ)**
```bash
cd mobile
view_logs_simple.bat
```

**Option B : Commande directe**
```bash
# Depuis le dossier mobile/
cd mobile

# Voir les logs Flutter (fonctionne toujours, même sans ADB dans PATH)
flutter logs

# Ou filtrer uniquement les logs de votre app
flutter logs | findstr "hunger_talk"
```

### Lancer l'app avec logs

```bash
# Lancer l'app et voir les logs directement
flutter run --release

# Ou en mode debug (plus de logs)
flutter run
```

## Méthode 2 : Logs Android (adb logcat)

### Voir tous les logs Android

```bash
# Logs en temps réel
adb logcat

# Filtrer par nom de package
adb logcat | findstr "com.example.hunger_talk"

# Filtrer par niveau (Error, Warning, Info)
adb logcat *:E  # Erreurs uniquement
adb logcat *:W  # Warnings et erreurs
adb logcat *:I  # Info, warnings et erreurs
```

### Filtrer les logs Flutter spécifiquement

```bash
# Logs Flutter uniquement
adb logcat | findstr "flutter"

# Logs avec tag spécifique
adb logcat -s flutter
```

## Méthode 3 : Logs depuis l'application (Debug)

L'application affiche maintenant automatiquement les logs dans la console avec :
- 🌐 Requêtes API (GET, POST, etc.)
- 📥 Réponses du serveur
- ❌ Erreurs réseau
- ⚠️ Erreurs API
- 🔒 Erreurs d'authentification

## Méthode 4 : Vérifier la connexion au backend

### Tester la connexion

```bash
# Vérifier que le backend est accessible depuis votre PC
curl http://192.168.11.108:8000/api/health

# Ou depuis le navigateur
# http://192.168.11.108:8000/docs
```

### Vérifier l'IP du backend

L'IP configurée dans l'app est : `http://192.168.11.108:8000`

Pour changer l'IP, modifiez `mobile/lib/core/config/app_config.dart`

## Commandes utiles

### Vérifier les appareils connectés
```bash
flutter devices
adb devices
```

### Nettoyer et reconstruire
```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

### Voir les logs d'erreur uniquement
```bash
flutter logs | findstr "Error\|Exception\|Failed"
```

## Dépannage

### Si les logs ne s'affichent pas :
1. Vérifiez que le débogage USB est activé
2. Réinstallez l'application : `flutter install`
3. Redémarrez adb : `adb kill-server && adb start-server`

### Si l'app ne se connecte pas au backend :
1. Vérifiez que le backend tourne : `http://192.168.11.108:8000/docs`
2. Vérifiez que le téléphone et le PC sont sur le même réseau Wi-Fi
3. Vérifiez l'IP dans `app_config.dart`
4. Vérifiez les logs pour voir les erreurs de connexion

