# 📱 Utiliser l'APK sur Téléphone avec Railway

## 🎯 Situation

Avec Railway, **tu n'as plus besoin de démarrer le serveur sur ton PC**. L'APK sur ton téléphone devrait se connecter directement à Railway.

## ✅ Solution 1 : Compiler l'APK en Mode Production (RECOMMANDÉ)

Quand tu compiles l'APK en mode **release** (production), l'app utilise automatiquement l'URL Railway.

### Compiler l'APK en Production

```bash
cd mobile
flutter build apk --release
```

L'APK sera dans : `mobile/build/app/outputs/flutter-apk/app-release.apk`

**Avantage** : L'app utilisera automatiquement `https://hunger-talk-production.up.railway.app`

---

## ✅ Solution 2 : Configurer l'URL Manuellement dans l'App

Si ton APK est en mode debug, tu peux configurer l'URL Railway manuellement :

1. Ouvre l'app sur ton téléphone
2. Va dans **Paramètres** → **Configuration du serveur**
3. Entre l'URL : `https://hunger-talk-production.up.railway.app`
4. Sauvegarde

L'app utilisera cette URL même en mode debug.

---

## ✅ Solution 3 : Utiliser l'URL Railway en Développement

Si tu veux tester avec Railway même en mode debug, modifie temporairement `app_config.dart` :

```dart
// Dans initialize(), même en développement, utiliser Railway
_baseUrl = 'https://hunger-talk-production.up.railway.app';
```

---

## 🚀 Recommandation

**Compile l'APK en mode release** pour la production :
- L'app utilisera automatiquement Railway
- Pas besoin de configuration manuelle
- Pas besoin de démarrer le serveur local

```bash
cd mobile
flutter build apk --release
```

---

**Avec Railway, tu n'as plus besoin de démarrer quoi que ce soit sur ton PC !** 🎉
