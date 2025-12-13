# 📱 Comment voir les logs depuis votre téléphone

## 🎯 Méthode 1 : Flutter logs (RECOMMANDÉ - Le plus simple)

### Prérequis
1. **Connectez votre téléphone Android à votre PC via USB**
2. **Activez le Mode Développeur** sur votre téléphone :
   - Allez dans **Paramètres** → **À propos du téléphone**
   - Tapez **7 fois** sur **"Numéro de build"** ou **"Version MIUI"**
   - Un message apparaîtra : "Vous êtes maintenant développeur"
3. **Activez le Débogage USB** :
   - Retournez dans **Paramètres** → **Options développeur** (ou **Paramètres système** → **Options développeur**)
   - Activez **"Débogage USB"**
   - Activez **"Débogage USB (sécurité)"** si disponible
4. **Autorisez l'ordinateur** :
   - Une popup apparaîtra sur votre téléphone : "Autoriser le débogage USB ?"
   - Cochez **"Toujours autoriser depuis cet ordinateur"**
   - Cliquez sur **"Autoriser"**

### Voir les logs

**Option A : Script simple**
```bash
cd mobile
view_logs_simple.bat
```

**Option B : Commande directe**
```bash
cd mobile
flutter logs
```

Les logs s'afficheront en temps réel dans la console !

---

## 🎯 Méthode 2 : Vérifier que le téléphone est détecté

Avant de voir les logs, vérifiez que Flutter détecte votre téléphone :

```bash
cd mobile
flutter devices
```

Vous devriez voir quelque chose comme :
```
sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64  • Android 13 (API 33)
Chrome (web)                • chrome         • web-javascript • Google Chrome
```

Si votre téléphone n'apparaît pas :
1. Vérifiez que le débogage USB est activé
2. Débranchez et rebranchez le câble USB
3. Réessayez `flutter devices`

---

## 🎯 Méthode 3 : Utiliser ADB directement (si Flutter ne fonctionne pas)

Si `flutter logs` ne fonctionne pas, vous pouvez utiliser ADB directement.

### Trouver ADB

ADB se trouve généralement ici :
```
C:\Users\VotreNom\AppData\Local\Android\Sdk\platform-tools\adb.exe
```

### Commandes ADB

**Voir les logs Flutter uniquement :**
```bash
cd C:\Users\VotreNom\AppData\Local\Android\Sdk\platform-tools
adb logcat | findstr "flutter"
```

**Voir tous les logs :**
```bash
adb logcat
```

**Voir uniquement les erreurs :**
```bash
adb logcat *:E
```

**Filtrer par nom de package :**
```bash
adb logcat | findstr "hunger_talk"
```

---

## 🎯 Méthode 4 : Logs depuis l'application (si rien ne fonctionne)

Si vous ne pouvez pas connecter le téléphone, vous pouvez ajouter un système de logs dans l'application elle-même (fichier ou notification).

---

## 🔍 Ce que vous verrez dans les logs

Avec les améliorations, vous verrez :

### **Lors de l'ajout d'un produit :**
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

### **Lors de l'envoi d'un message :**
```
💬 [CHAT] Envoi de message: ...
🔧 [API] POST Normalisation:
   Endpoint original: /chat
   ...
   ✅ Trailing slash ajouté: /chat/
🌐 [API] POST http://192.168.11.108:8000/api/chat/
📥 [API] POST Response: 200
```

### **Si erreur 307 :**
```
⚠️ [API] Redirection 307 détectée!
   URL demandée: http://192.168.11.108:8000/api/stock
   Location: http://192.168.11.108:8000/api/stock/
```

---

## 🚨 Dépannage

### **"Aucun appareil détecté"**
1. Vérifiez que le débogage USB est activé
2. Autorisez l'ordinateur sur le téléphone
3. Essayez un autre câble USB
4. Redémarrez `adb` : `adb kill-server && adb start-server`

### **"adb n'est pas reconnu"**
- Utilisez `flutter logs` à la place (plus simple)
- Ou ajoutez ADB au PATH Windows

### **"Les logs ne s'affichent pas"**
- Assurez-vous que l'application est ouverte sur le téléphone
- Les logs s'affichent en temps réel pendant l'utilisation

---

## ✅ Solution rapide

**La méthode la plus simple :**
1. Connectez le téléphone en USB
2. Activez le débogage USB
3. Ouvrez PowerShell ou CMD
4. Tapez :
   ```bash
   cd "G:\EMSI\3eme annee\PFA\mobile"
   flutter logs
   ```
5. Utilisez l'application sur votre téléphone
6. Les logs apparaîtront en temps réel !

