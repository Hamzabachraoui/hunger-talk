# 🚀 Guide de Déploiement sur Railway

Ce guide explique comment déployer le backend sur Railway après avoir fait des modifications locales.

## 📋 Prérequis

1. Avoir un compte Railway
2. Avoir le projet connecté à Railway
3. Avoir Git configuré

## 🔄 Méthode 1 : Déploiement Automatique (Recommandé)

Si votre projet est connecté à un repository Git (GitHub, GitLab, etc.) :

### 1. Commiter les modifications
```bash
cd backend
git add .
git commit -m "Fix: Correction authentification endpoint /api/stock"
git push
```

### 2. Railway déploiera automatiquement
Railway détectera automatiquement le push et redéploiera l'application.

### 3. Vérifier le déploiement
- Aller sur Railway Dashboard
- Vérifier que le déploiement est en cours
- Attendre la fin du déploiement
- Vérifier les logs pour s'assurer qu'il n'y a pas d'erreurs

---

## 🔄 Méthode 2 : Déploiement Manuel via Railway CLI

### 1. Installer Railway CLI
```bash
npm i -g @railway/cli
```

### 2. Se connecter
```bash
railway login
```

### 3. Lier le projet
```bash
cd backend
railway link
```

### 4. Déployer
```bash
railway up
```

---

## 🔄 Méthode 3 : Déploiement via Railway Dashboard

### 1. Aller sur Railway Dashboard
- Ouvrir https://railway.app
- Sélectionner votre projet

### 2. Déclencher un nouveau déploiement
- Cliquer sur votre service backend
- Cliquer sur "Deploy" ou "Redeploy"
- Railway redéploiera la dernière version du code

---

## ✅ Vérification après Déploiement

### 1. Vérifier que l'API fonctionne
```bash
curl https://hunger-talk-production.up.railway.app/health
```

### 2. Vérifier les logs
- Aller sur Railway Dashboard
- Cliquer sur votre service
- Aller dans l'onglet "Logs"
- Vérifier qu'il n'y a pas d'erreurs

### 3. Tester l'endpoint problématique
```bash
# Tester avec un token valide
curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://hunger-talk-production.up.railway.app/api/stock
```

---

## 🐛 Résolution de Problèmes

### Le déploiement échoue

1. **Vérifier les logs Railway** :
   - Aller dans Railway Dashboard → Logs
   - Chercher les erreurs

2. **Vérifier les variables d'environnement** :
   - Railway Dashboard → Variables
   - S'assurer que `DATABASE_URL` est configuré
   - S'assurer que `SECRET_KEY` est configuré

3. **Vérifier les dépendances** :
   - S'assurer que `requirements.txt` est à jour
   - Vérifier que toutes les dépendances sont listées

### L'API ne répond pas après déploiement

1. **Vérifier que le service est en cours d'exécution** :
   - Railway Dashboard → Vérifier l'état du service

2. **Vérifier les variables d'environnement** :
   - S'assurer que `PORT` est configuré (Railway le définit automatiquement)

3. **Vérifier la connexion à la base de données** :
   - Vérifier que `DATABASE_URL` pointe vers la bonne base de données

---

## 📝 Notes Importantes

- ⚠️ **Toujours tester localement avant de déployer**
- ⚠️ **Vérifier les logs après chaque déploiement**
- ⚠️ **S'assurer que toutes les variables d'environnement sont configurées**
- ✅ **Railway redéploie automatiquement à chaque push sur la branche principale**

---

## 🔗 Liens Utiles

- [Documentation Railway](https://docs.railway.app/)
- [Railway Dashboard](https://railway.app/dashboard)
