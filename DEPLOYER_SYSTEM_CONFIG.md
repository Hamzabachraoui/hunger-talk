# 🚀 Déployer la Nouvelle Fonctionnalité SystemConfig

## ✅ Ce qui a été fait

1. ✅ Modèle `SystemConfig` créé
2. ✅ Endpoints API créés (`/api/system-config/ollama`)
3. ✅ Service de configuration créé
4. ✅ Migration Alembic créée
5. ✅ Code modifié pour utiliser l'IP depuis la DB

## 📋 Étapes de Déploiement

### 1. Commit et Push vers Git

```powershell
git add .
git commit -m "Ajout SystemConfig pour stocker IP Ollama automatiquement"
git push
```

### 2. Sur Railway

Railway va automatiquement :
- Détecter le nouveau code
- Redéployer l'application
- Mais la table `system_config` ne sera pas créée automatiquement

### 3. Créer la Table system_config

**Option A : Via Migration Alembic** (Recommandé)

Si Railway exécute les migrations automatiquement, la table sera créée.

Sinon, connectez-vous à la base de données PostgreSQL Railway et exécutez :

```sql
CREATE TABLE system_config (
    key VARCHAR(100) PRIMARY KEY,
    value VARCHAR(500) NOT NULL,
    description VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

CREATE INDEX ix_system_config_key ON system_config (key);
```

**Option B : Via Railway CLI**

Si vous avez Railway CLI installé :

```bash
railway run alembic upgrade head
```

### 4. Enregistrer l'IP Ollama

Une fois la table créée, exécutez le script local :

```powershell
.\enregistrer_ip_ollama.ps1
```

Ou manuellement via l'API :

```powershell
$token = "VOTRE_TOKEN_JWT"
$ip = "192.168.11.101"
$url = "http://$ip:11434"

Invoke-RestMethod -Uri "https://hunger-talk-production.up.railway.app/api/system-config/ollama/base-url?value=$url" -Method Put -Headers @{"Authorization"="Bearer $token"}
```

## 🔍 Vérification

1. **Vérifier que la table existe** :
   - Railway → PostgreSQL → Query
   - Exécuter : `SELECT * FROM system_config;`

2. **Vérifier l'endpoint** :
   - Ouvrir : `https://hunger-talk-production.up.railway.app/api/system-config/ollama`
   - Devrait retourner la configuration Ollama

3. **Tester le chat** :
   - Ouvrir l'app mobile
   - Envoyer un message au chat
   - Le backend devrait utiliser l'IP stockée dans la DB

## 📝 Notes

- L'IP doit être enregistrée **à chaque démarrage du PC** si elle change
- Pour automatiser, créez une tâche planifiée Windows qui exécute `enregistrer_ip_ollama.ps1`
- L'app mobile n'a pas besoin d'être modifiée (le backend gère tout)

---

**Une fois déployé, le système détectera et utilisera automatiquement l'IP Ollama locale !** 🎉

