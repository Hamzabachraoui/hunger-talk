# Docker pour Flutter Mobile - Hunger-Talk

## 📦 Utilisation

### Builder l'APK Android

Pour builder l'APK de release dans Docker :

```bash
docker-compose run --rm mobile flutter build apk --release
```

L'APK sera généré dans `mobile/build/app/outputs/flutter-apk/app-release.apk`

### Builder l'APK Bundle (AAB) pour Google Play

```bash
docker-compose run --rm mobile flutter build appbundle --release
```

Le bundle sera généré dans `mobile/build/app/outputs/bundle/release/app-release.aab`

### Vérifier le code

```bash
docker-compose run --rm mobile flutter analyze
```

### Installer les dépendances

```bash
docker-compose run --rm mobile flutter pub get
```

### Tester la compilation

```bash
docker-compose run --rm mobile flutter build apk --debug
```

## 🚀 Développement local (recommandé)

Pour le développement, il est recommandé d'utiliser Flutter localement plutôt que Docker :

```bash
cd mobile
flutter pub get
flutter run
```

Docker est principalement utile pour :
- Builder l'APK en production
- Environnements CI/CD
- Éviter les problèmes de compatibilité système

## 📝 Notes

- Le conteneur Docker utilise Flutter 3.24.0
- Les dépendances sont mises en cache dans un volume Docker
- Le code source est monté en volume pour faciliter les modifications

