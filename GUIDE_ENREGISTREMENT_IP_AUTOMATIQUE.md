# 🔄 Guide : Enregistrement Automatique de l'IP Ollama

## 🎯 Solution Implémentée

Vous avez demandé que le système détecte automatiquement l'IP locale d'Ollama et l'enregistre dans la base de données Railway, pour que l'app mobile puisse la récupérer automatiquement.

## ✅ Ce qui a été fait

### 1. Modèle de Base de Données

- **Nouveau modèle** : `SystemConfig` dans `backend/app/models/system_config.py`
- Table `system_config` avec les colonnes :
  - `key` : Clé unique (ex: "ollama_base_url")
  - `value` : Valeur (ex: "http://192.168.11.101:11434")
  - `description` : Description de la configuration
  - `created_at`, `updated_at` : Timestamps

### 2. API Endpoints

**GET `/api/system-config/ollama`**
- Récupère la configuration Ollama (URL + modèle)
- **Utilisé par l'app mobile** pour obtenir l'IP automatiquement
- Réponse :
```json
{
  "ollama_base_url": "http://192.168.11.101:11434",
  "ollama_model": "llama3.1:8b",
  "updated_at": "2025-12-30T20:00:00Z"
}
```

**PUT `/api/system-config/ollama/base-url?value=...`**
- Met à jour l'URL Ollama dans la base
- Nécessite une authentification (token JWT)
- **Appelé par un script local** pour enregistrer l'IP automatiquement

### 3. Service de Configuration

- **Service** : `backend/app/services/system_config_service.py`
- Fonctions :
  - `get_ollama_base_url(db)` : Récupère l'URL depuis la DB
  - `set_ollama_base_url(db, url)` : Enregistre l'URL dans la DB

### 4. Modification d'OllamaService

- `OllamaService` accepte maintenant une `base_url` optionnelle
- Le router `chat.py` récupère l'URL depuis la DB avant d'appeler Ollama
- **Le backend Railway utilise maintenant l'IP stockée dans la DB**

## 📋 Utilisation

### Pour Enregistrer l'IP Localement

**Option 1 : Script PowerShell** (Recommandé)

J'ai créé `enregistrer_ip_ollama.ps1` qui :
1. Détecte automatiquement votre IP locale
2. Vérifie qu'Ollama fonctionne
3. Enregistre l'IP dans Railway via l'API

```powershell
# Avec authentification (vous devrez fournir un token JWT)
.\enregistrer_ip_ollama.ps1
```

**Option 2 : Appel API Direct**

Depuis votre PC local, avec un token JWT :

```powershell
$token = "VOTRE_TOKEN_JWT"
$ip = "192.168.11.101"
$url = "http://$ip:11434"

Invoke-RestMethod -Uri "https://hunger-talk-production.up.railway.app/api/system-config/ollama/base-url?value=$url" -Method Put -Headers @{"Authorization"="Bearer $token"}
```

**Option 3 : Via l'App Mobile**

L'app mobile peut appeler cet endpoint si vous ajoutez une fonctionnalité d'administration.

### Pour Récupérer l'IP dans l'App Mobile

L'app mobile doit appeler :

```
GET https://hunger-talk-production.up.railway.app/api/system-config/ollama
```

Puis utiliser `ollama_base_url` pour configurer l'appel à Ollama.

## ⚠️ Note Importante

**L'architecture actuelle** :
- App Mobile → Railway Backend → Ollama Local (via IP dans DB)

Si vous voulez que l'app mobile appelle Ollama **directement**, il faudrait :
1. L'app mobile récupère l'IP depuis Railway
2. L'app mobile appelle Ollama directement avec cette IP
3. **Mais** : vous perdez le contexte RAG, l'authentification, etc. qui sont dans le backend

**Recommandation** : Gardez l'architecture actuelle. Le backend Railway récupère l'IP depuis la DB et appelle Ollama local directement.

## 🔄 Automatisation au Démarrage

Pour enregistrer automatiquement l'IP au démarrage du PC :

1. Créer une tâche planifiée Windows
2. Exécuter `enregistrer_ip_ollama.ps1` au démarrage
3. **OU** créer un service Windows qui détecte les changements d'IP

### Tâche Planifiée

```powershell
# Créer une tâche planifiée (en tant qu'administrateur)
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"G:\EMSI\3eme annee\PFA\enregistrer_ip_ollama.ps1`""
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -TaskName "Enregistrer IP Ollama" -Action $action -Trigger $trigger
```

## 📝 Prochaines Étapes

1. **Déployer sur Railway** : Les changements doivent être déployés
2. **Créer la table** : La migration Alembic ou la création manuelle de la table `system_config`
3. **Tester** : Appeler l'endpoint pour enregistrer une IP
4. **Modifier l'app mobile** : Ajouter l'appel à `/api/system-config/ollama` si nécessaire

---

**Cette solution permet une détection et un enregistrement automatiques de l'IP Ollama !** 🎉

