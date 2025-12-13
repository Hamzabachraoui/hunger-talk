# 🚀 Guide de Déploiement Professionnel

## 📱 Le Problème Actuel

Actuellement, ton app mobile cherche le serveur sur le réseau local avec une IP qui change. **C'est OK pour tester localement, mais PAS pour publier sur le Play Store !**

Les utilisateurs qui téléchargent ton app depuis le Play Store ne seront **jamais** sur le même réseau Wi-Fi que toi. Ils ne pourront jamais se connecter au serveur.

---

## ✅ Solution : Déployer sur le Cloud

### Les Applications Professionnelles Utilisent :

1. **URLs Fixes** : `https://api.monapp.com` (ne change jamais)
2. **Services Cloud** : Railway, Render, Firebase, AWS, etc.
3. **Pas d'IP locale** : Tout est accessible depuis Internet

---

## 🎯 Solution Recommandée : Railway

### Pourquoi Railway ?

✅ **Gratuit** : $5 de crédit par mois (suffisant pour un PFA)  
✅ **Simple** : Déploiement en 5 minutes  
✅ **URL Fixe** : `ton-app.up.railway.app` (ne change jamais)  
✅ **Automatique** : Déploie à chaque push GitHub  
✅ **PostgreSQL** : Base de données incluse  

---

## 📝 Étapes pour Déployer

### 1. Créer un compte Railway

1. Va sur [railway.app](https://railway.app)
2. Clique sur "Start a New Project"
3. Connecte-toi avec GitHub

### 2. Déployer le Backend

1. Dans Railway, clique sur "New Project"
2. Sélectionne "Deploy from GitHub repo"
3. Choisis ton repository
4. Railway détecte automatiquement Python/FastAPI
5. Il déploie et te donne une URL : `ton-app.up.railway.app`

### 3. Configurer les Variables d'Environnement

Dans Railway, ajoute ces variables :
```
DATABASE_URL=postgresql://... (Railway génère ça automatiquement)
SECRET_KEY=ton-secret-key-super-long
OLLAMA_BASE_URL=http://localhost:11434 (si Ollama reste local)
```

### 4. Mettre à Jour l'App Mobile

Dans `mobile/lib/core/config/app_config.dart`, remplace :

```dart
// Ligne 23 - Remplace par ton URL Railway
defaultValue: 'https://ton-app.up.railway.app',
```

### 5. Recompiler l'App

```bash
cd mobile
flutter build apk --release
```

---

## 🔄 Alternative : Render (Gratuit aussi)

Si Railway ne te convient pas :

1. Va sur [render.com](https://render.com)
2. Crée un compte
3. "New" → "Web Service"
4. Connecte GitHub
5. Render déploie et donne : `ton-app.onrender.com`

**Note** : Render s'endort après 15 min d'inactivité (gratuit). Railway reste actif.

---

## 🎓 Pour Ton PFA

### Option 1 : Déployer sur Railway (RECOMMANDÉ)
- ✅ Gratuit
- ✅ URL fixe permanente
- ✅ Parfait pour démonstration

### Option 2 : Garder Local + ngrok (Pour démo uniquement)
- ⚠️ URL change à chaque redémarrage
- ⚠️ Limité (40 connexions/min)
- ✅ OK pour présentation rapide

### Option 3 : Utiliser Firebase/Supabase
- ✅ Backend complet géré
- ✅ Gratuit avec quota généreux
- ⚠️ Nécessite de réécrire certaines parties

---

## 📋 Checklist Avant Publication

- [ ] Backend déployé sur Railway/Render
- [ ] URL fixe configurée dans `app_config.dart`
- [ ] Base de données migrée vers le cloud
- [ ] Testé avec l'app depuis un autre réseau
- [ ] SSL/HTTPS activé (automatique avec Railway)
- [ ] Variables d'environnement configurées
- [ ] App compilée en mode release

---

## 💡 Résumé

**AVANT (Local)** :
```
App Mobile → 192.168.11.102:8000 (IP locale qui change)
❌ Ne fonctionne que sur ton réseau Wi-Fi
```

**APRÈS (Cloud)** :
```
App Mobile → https://ton-app.up.railway.app (URL fixe)
✅ Fonctionne partout dans le monde
```

---

## 🆘 Besoin d'Aide ?

1. **Railway ne déploie pas ?**
   - Vérifie que `requirements.txt` existe
   - Vérifie que `main.py` est à la racine du backend

2. **L'app ne se connecte pas ?**
   - Vérifie l'URL dans `app_config.dart`
   - Vérifie que le serveur répond : `https://ton-app.up.railway.app/health`

3. **Base de données vide ?**
   - Exporte les données locales
   - Importe dans Railway PostgreSQL

---

**Une fois déployé, ton app fonctionnera pour TOUS les utilisateurs, peu importe où ils sont ! 🎉**
