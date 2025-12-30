# 🔧 Ajouter les Variables dans Railway

## 📍 Où Trouver les Variables

1. **Railway Dashboard** → Clique sur ton **Service** (celui qui contient ton backend)
2. Va dans l'onglet **"Variables"** (en haut, à côté de "Settings", "Deployments", etc.)
3. Clique sur **"+ New Variable"** ou **"Add Variable"**

---

## ✅ Variables à Ajouter

### 1. DATABASE_URL

**Nom** : `DATABASE_URL`

**Valeur** : 
- Clique sur le bouton **"Add Reference"** (ou le bouton avec `{}`)
- Sélectionne ton service **PostgreSQL** dans la liste
- Sélectionne **"DATABASE_URL"** dans les variables disponibles
- Railway va automatiquement remplir : `${{Postgres.DATABASE_URL}}`

**Si tu n'as pas encore PostgreSQL :**
- Clique sur **"+ New"** dans ton projet Railway
- Sélectionne **"Database"** → **"Add PostgreSQL"**
- Ensuite, ajoute `DATABASE_URL` comme référence

---

### 2. SECRET_KEY

**Nom** : `SECRET_KEY`

**Valeur** : Utilise cette clé (ou génère-en une nouvelle) :
```
79juEwjfulVuZskpnmtZM4pMrGe5LENNDhckNb60MHM
```

**Pour générer une nouvelle clé :**
```powershell
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

---

### 3. ENVIRONMENT (Optionnel mais Recommandé)

**Nom** : `ENVIRONMENT`

**Valeur** : `production`

---

## 🔍 Si tu ne Trouves Pas l'Onglet "Variables"

Parfois l'interface Railway change. Cherche :
- **"Environment Variables"**
- **"Env"**
- **"Config"**
- Dans **"Settings"** → **"Environment"**

---

## ✅ Après Ajout

Une fois les variables ajoutées :
- Railway va **redéployer automatiquement**
- Ou va dans **Deployments** → **Redeploy**
- Vérifie les logs pour voir si l'application démarre correctement

---

**Dis-moi si tu arrives à trouver l'onglet Variables !**
