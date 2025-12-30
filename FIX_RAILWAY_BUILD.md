# 🔧 Fix Build Failed Railway - Solutions

## 🔍 Causes Courantes d'Erreur de Build

### 1. Root Directory Non Configuré
**Erreur typique** : "No module named 'main'" ou "File not found"

**Solution** :
- Dans Railway → Service → Settings → Root Directory
- Mettre : `backend`
- Sauvegarder et redéployer

---

### 2. Dépendances Lourdes (sentence-transformers, faiss-cpu)
**Erreur typique** : Timeout lors du build ou erreur de mémoire

**Solution** : Ces dépendances sont très lourdes. Si tu ne les utilises pas activement, retire-les temporairement.

---

### 3. Version Python Incompatible
**Erreur typique** : "Python version not supported"

**Solution** : Vérifie que `runtime.txt` contient une version supportée par Railway.

---

### 4. Variables d'Environnement Manquantes
**Erreur typique** : "DATABASE_URL not found" ou "SECRET_KEY not found"

**Solution** : Ajoute toutes les variables requises dans Railway → Variables.

---

### 5. Problème avec les Imports
**Erreur typique** : "ModuleNotFoundError"

**Solution** : Vérifie que tous les fichiers nécessaires sont présents.

---

## 🚀 Solution Rapide - Requirements.txt Optimisé

Si le build échoue à cause des dépendances lourdes, crée un `requirements.txt` minimal pour commencer :

```txt
# Backend FastAPI - Hunger-Talk (Version Railway)
# Python 3.11+

# Framework web
fastapi==0.104.1
uvicorn[standard]==0.24.0
python-multipart==0.0.6

# Base de données
sqlalchemy==2.0.23
alembic==1.12.1
psycopg2-binary==2.9.9

# Authentification
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-dotenv==1.0.0

# Validation
pydantic==2.5.0
pydantic-settings==2.1.0

# Utilitaires
httpx==0.25.2
aiofiles==23.2.1
email-validator==2.1.0

# IA et LLM (optionnel - peut causer des problèmes de build)
# Décommente seulement si tu utilises vraiment ces fonctionnalités
# langchain==0.0.335
# ollama==0.1.5
# faiss-cpu==1.7.4
# sentence-transformers==2.2.2

# Tests (optionnel pour production)
# pytest==7.4.3
# pytest-asyncio==0.21.1
```

---

## 📋 Checklist de Vérification

1. ✅ **Root Directory** = `backend` dans Railway Settings
2. ✅ **Variables d'environnement** configurées :
   - `DATABASE_URL`
   - `SECRET_KEY`
   - `ENVIRONMENT=production`
3. ✅ **requirements.txt** présent dans `backend/`
4. ✅ **main.py** présent dans `backend/`
5. ✅ **Procfile** ou `railway.json` avec la bonne commande de démarrage

---

## 🔍 Comment Voir les Logs d'Erreur

1. Dans Railway Dashboard
2. Clique sur ton service
3. Onglet **"Deployments"**
4. Clique sur le dernier déploiement (celui qui a échoué)
5. Regarde les **logs** pour voir l'erreur exacte

---

## 💡 Solution Immédiate

Si tu veux que je crée une version optimisée de `requirements.txt` sans les dépendances lourdes, dis-moi et je le fais !
