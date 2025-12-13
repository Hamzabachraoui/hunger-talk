# 🔧 Solution Alternative - Railway sans Root Directory

## Si tu ne trouves pas "Root Directory" dans Settings

Railway a peut-être changé l'interface. Voici des alternatives :

---

## ✅ Solution 1 : Utiliser railway.json à la racine

Railway lit automatiquement `railway.json` à la racine du repository. On peut y spécifier le chemin.

### Modifier railway.json à la racine

```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS",
    "buildCommand": "cd backend && python3 -m pip install --upgrade pip && python3 -m pip install -r requirements.txt"
  },
  "deploy": {
    "startCommand": "cd backend && python3 -m uvicorn main:app --host 0.0.0.0 --port $PORT",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

---

## ✅ Solution 2 : Créer un fichier .railwayignore et déplacer les fichiers

Si Railway ne peut pas être configuré, on peut :
1. Créer un `.railwayignore` à la racine pour ignorer tout sauf `backend/`
2. Ou déplacer temporairement les fichiers nécessaires à la racine

---

## ✅ Solution 3 : Utiliser un Dockerfile personnalisé

Créer un `Dockerfile` à la racine qui copie et build depuis `backend/` :

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Copier seulement le dossier backend
COPY backend/ /app/

# Installer les dépendances
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Exposer le port
EXPOSE $PORT

# Démarrer l'application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## ✅ Solution 4 : Vérifier dans l'interface Railway

L'option "Root Directory" peut être :
- Dans **Settings** → **General** (tout en bas)
- Dans **Settings** → **Build & Deploy**
- Dans l'onglet **Variables** (parfois)
- Dans le menu **...** (trois points) du service

---

## 🎯 Solution Recommandée : Dockerfile

Si Root Directory n'est pas disponible, utiliser un **Dockerfile** est la solution la plus fiable.

**Dis-moi quelle solution tu veux essayer et je la configure !**
