# 🧹 Guide de Nettoyage Complet et Build Propre

Ce guide explique comment nettoyer complètement votre projet Flutter pour forcer une compilation propre, comme si c'était la première fois.

## 🚀 Méthode Rapide (Recommandée)

### Option 1 : Script PowerShell (Windows)
```powershell
cd mobile
.\clean_build.ps1 -Build
```

### Option 2 : Script Batch (Windows)
```cmd
cd mobile
clean_build.bat
```

Ces scripts vont :
1. ✅ Nettoyer le cache Flutter global
2. ✅ Supprimer le dossier `build/`
3. ✅ Supprimer `.dart_tool/`
4. ✅ Supprimer les fichiers de plugins (`.flutter-plugins`, etc.)
5. ✅ Nettoyer le cache pub
6. ✅ Récupérer les dépendances à nouveau
7. ✅ Nettoyer le cache Gradle Android
8. ✅ Construire l'APK en mode release

---

## 📋 Méthode Manuelle (Étape par Étape)

Si vous préférez exécuter les commandes manuellement :

### 1. Aller dans le dossier mobile
```powershell
cd mobile
```

### 2. Nettoyer le cache Flutter
```powershell
flutter clean
```

### 3. Supprimer les dossiers de build
```powershell
# Supprimer le dossier build principal
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue

# Supprimer .dart_tool
Remove-Item -Recurse -Force .dart_tool -ErrorAction SilentlyContinue

# Supprimer les fichiers de plugins
Remove-Item -Force .flutter-plugins -ErrorAction SilentlyContinue
Remove-Item -Force .flutter-plugins-dependencies -ErrorAction SilentlyContinue
Remove-Item -Force .packages -ErrorAction SilentlyContinue
```

### 4. Nettoyer le cache pub
```powershell
flutter pub cache clean
```

### 5. Nettoyer le cache Gradle (Android)
```powershell
# Cache Gradle local
Remove-Item -Recurse -Force android\.gradle -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force android\build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force android\app\build -ErrorAction SilentlyContinue

# Cache Gradle global (optionnel mais recommandé pour un nettoyage complet)
Remove-Item -Recurse -Force $env:USERPROFILE\.gradle\caches -ErrorAction SilentlyContinue
```

### 6. Récupérer les dépendances
```powershell
flutter pub get
```

### 7. Construire l'APK
```powershell
flutter build apk --release
```

---

## 🔍 Vérification

Après le nettoyage, vérifiez que tout est OK :

```powershell
flutter doctor -v
```

---

## ⚠️ Problèmes Courants

### L'APK ne change toujours pas

Si après le nettoyage l'APK semble identique :

1. **Vérifiez le cache Gradle global** :
   ```powershell
   Remove-Item -Recurse -Force $env:USERPROFILE\.gradle\caches
   ```

2. **Vérifiez le cache Flutter global** :
   ```powershell
   flutter clean
   flutter pub cache clean
   ```

3. **Supprimez l'APK existant** :
   ```powershell
   Remove-Item -Force build\app\outputs\flutter-apk\app-release.apk -ErrorAction SilentlyContinue
   ```

4. **Rebuild avec verbose pour voir ce qui se passe** :
   ```powershell
   flutter build apk --release --verbose
   ```

### Erreurs de dépendances après nettoyage

Si vous avez des erreurs de dépendances :

```powershell
flutter pub get
flutter pub upgrade
```

### Erreurs Gradle

Si vous avez des erreurs Gradle :

```powershell
cd android
.\gradlew clean
cd ..
flutter clean
flutter build apk --release
```

---

## 📝 Notes Importantes

- ⏱️ Le nettoyage complet peut prendre 5-10 minutes
- 💾 Le cache Gradle peut être volumineux (plusieurs GB)
- 🔄 Après le nettoyage, la première compilation sera plus lente (normal)
- ✅ Les compilations suivantes seront plus rapides grâce au cache

---

## 🎯 Commandes Rapides

### Nettoyage minimal (rapide)
```powershell
flutter clean
flutter pub get
flutter build apk --release
```

### Nettoyage complet (recommandé pour résoudre les problèmes)
```powershell
.\clean_build.ps1 -Build
```

---

## 📱 Emplacement de l'APK

Après la construction, l'APK se trouve à :
```
mobile\build\app\outputs\flutter-apk\app-release.apk
```

---

**💡 Astuce** : Utilisez le script `clean_build.ps1` ou `clean_build.bat` pour automatiser tout le processus !
