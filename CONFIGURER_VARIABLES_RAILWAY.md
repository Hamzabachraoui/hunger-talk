# 🔧 Configurer les Variables d'Environnement dans Railway

## ❌ Erreur Actuelle

```
ValidationError: 2 validation errors for Settings
DATABASE_URL - Field required
SECRET_KEY - Field required
```

L'application ne démarre pas car les variables d'environnement sont manquantes.

---

## ✅ Solution : Ajouter les Variables dans Railway

### Étape 1 : Aller dans les Variables

1. **Railway Dashboard** → Clique sur ton **Service** (backend)
2. Va dans l'onglet **"Variables"** (ou **"Environment Variables"**)
3. Clique sur **"+ New Variable"** ou **"Add Variable"**

### Étape 2 : Ajouter DATABASE_URL

1. **Nom** : `DATABASE_URL`
2. **Valeur** : Clique sur **"Add Reference"** (ou le bouton avec les accolades `{}`)
3. Sélectionne ta **base de données PostgreSQL** dans la liste
4. Sélectionne **"DATABASE_URL"** dans les variables disponibles
5. Railway va automatiquement remplir : `${{Postgres.DATABASE_URL}}`

**OU** si tu as déjà créé PostgreSQL :
- Va dans ton service **PostgreSQL**
- Copie l'URL de connexion complète
- Colle-la dans la valeur de `DATABASE_URL`

### Étape 3 : Ajouter SECRET_KEY

1. **Nom** : `SECRET_KEY`
2. **Valeur** : Génère une clé secrète (voir ci-dessous)

#### Générer SECRET_KEY

**Option 1 : Via PowerShell (sur ton PC)**
```powershell
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

**Option 2 : Via le script**
```powershell
.\generer_secret_key.ps1
```

**Option 3 : En ligne**
- Va sur https://randomkeygen.com/
- Utilise un "CodeIgniter Encryption Keys" (256 bits)

**Exemple de SECRET_KEY générée :**
```
3ocryCtmmAx32FUvLhHj3KD58E359TvaYT-jB2487XM
```

### Étape 4 : Ajouter ENVIRONMENT (Optionnel mais Recommandé)

1. **Nom** : `ENVIRONMENT`
2. **Valeur** : `production`

### Étape 5 : Vérifier PORT (Automatique)

Railway définit automatiquement `PORT`. Tu n'as pas besoin de l'ajouter manuellement.

---

## 📋 Checklist des Variables

Assure-toi d'avoir ces variables dans Railway :

| Variable | Valeur | Commentaire |
|----------|--------|-------------|
| `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` | Référence à PostgreSQL (automatique) |
| `SECRET_KEY` | `[ta clé générée]` | Clé secrète pour JWT (à générer) |
| `ENVIRONMENT` | `production` | Mode production (optionnel) |
| `PORT` | `${{PORT}}` | Automatique (ne pas ajouter) |

---

## 🔍 Vérifier que PostgreSQL est Créé

Si tu n'as pas encore créé PostgreSQL :

1. Dans Railway → **"+ New"** → **"Database"** → **"Add PostgreSQL"**
2. Railway va créer une base de données
3. Ensuite, tu peux ajouter `DATABASE_URL` comme référence

---

## 🚀 Après Configuration

Une fois les variables ajoutées :

1. **Railway va redéployer automatiquement**
2. Ou va dans **Deployments** → **Redeploy**
3. Vérifie les logs pour voir si l'application démarre correctement

---

## ✅ Test

Une fois déployé, teste l'API :
- `https://ton-app.up.railway.app/health`
- `https://ton-app.up.railway.app/docs`

Si tu vois la documentation Swagger → ✅ Ça marche !

---

## 🆘 Si ça Ne Fonctionne Pas

1. **Vérifie les logs** dans Railway → Deployments → Logs
2. **Vérifie que les variables sont bien définies** (pas de fautes de frappe)
3. **Vérifie que PostgreSQL est actif** (service vert dans Railway)

---

**Ajoute les variables et dis-moi si ça fonctionne !**
