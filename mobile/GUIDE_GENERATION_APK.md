# 📱 Guide : Génération de l'APK

## ⚡ Méthode Rapide (Recommandée)

### Option 1 : Script PowerShell (Windows)

```powershell
cd mobile
.\generer_apk.ps1
```

### Option 2 : Script Batch (Windows)

```cmd
cd mobile
generer_apk.bat
```

### Option 3 : Commande Flutter Directe

```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

## 📍 Emplacement de l'APK

Une fois généré, l'APK se trouve dans :
```
mobile/build/app/outputs/flutter-apk/app-release.apk
```

## 📋 Installation sur Téléphone

### 1. Transférer l'APK
- Connectez votre téléphone Android à votre PC
- Copiez l'APK sur votre téléphone
- OU envoyez-le par email/WhatsApp à vous-même

### 2. Autoriser l'installation
- Allez dans **Paramètres** → **Sécurité**
- Activez **Sources inconnues** ou **Installer des applications inconnues**
- Sélectionnez votre navigateur/email (selon comment vous avez transféré l'APK)

### 3. Installer
- Ouvrez le fichier APK sur votre téléphone
- Suivez les instructions d'installation

## ⚠️ Notes Importantes

- **Taille** : L'APK fait environ 30-50 MB
- **Première installation** : Peut prendre quelques secondes
- **Permissions** : L'app demandera les permissions nécessaires au premier lancement

## 🔧 Dépannage

### Erreur : "Flutter n'est pas installé"
- Installez Flutter : https://flutter.dev/docs/get-started/install/windows
- Ajoutez Flutter au PATH

### Erreur : "Gradle build failed"
- Vérifiez que Java JDK est installé
- Vérifiez la connexion Internet (Gradle télécharge des dépendances)

### Erreur : "SDK not found"
- Installez Android Studio
- Configurez les SDK Android via Android Studio

## ✅ Vérification

Après installation, testez que :
- ✅ L'application se lance
- ✅ La connexion à Railway fonctionne
- ✅ L'IA répond (si ngrok est actif)

---

**C'est tout ! Votre APK est prêt !** 🎉

