# 🏠 Guide : Utiliser le Backend Local avec IP Locale

## 🎯 Votre Idée Excellente

Au lieu d'utiliser Railway, faire tourner le backend **localement** sur votre PC, et l'app mobile communique directement avec via l'IP locale (192.168.11.101:8000).

## ✅ Architecture Locale

```
Mobile App → Backend Local (192.168.11.101:8000) → Ollama Local (localhost:11434)
```

**Avantages** :
- ✅ Pas besoin de tunnel (Railway ↔ Ollama)
- ✅ Plus rapide (tout est local)
- ✅ Plus simple à configurer
- ✅ IP locale : `http://192.168.11.101:8000`
- ✅ Fonctionne tant que PC et téléphone sont sur le même WiFi

## 📋 Étapes de Configuration

### 1. Démarrer Ollama Local

Ollama doit être démarré et écouter sur `localhost:11434` (normalement déjà fait).

```powershell
# Vérifier qu'Ollama fonctionne
curl http://localhost:11434/api/tags
```

### 2. Démarrer le Backend Local

Utilisez le script existant :

```powershell
.\demarrer_serveur.ps1
```

Ou manuellement :

```powershell
cd backend
python -m uvicorn main:app --host 0.0.0.0 --port 8000
```

Le serveur écoutera sur toutes les interfaces (0.0.0.0), donc accessible via l'IP locale.

### 3. Configurer l'Application Mobile

**Option A : Modifier le code (pour démo permanente)**

Dans `mobile/lib/core/config/app_config.dart`, ligne 23 :

```dart
defaultValue: 'http://192.168.11.101:8000',  // Backend local
```

**Option B : Utiliser la découverte automatique**

Si le code supporte déjà la découverte, l'app devrait trouver automatiquement le serveur local.

**Option C : Paramètres dans l'app**

Si l'app permet de changer l'URL du serveur depuis les paramètres, utilisez :
- `http://192.168.11.101:8000`

### 4. Configuration Ollama dans le Backend Local

Le backend local peut utiliser `http://localhost:11434` directement (pas besoin de tunnel).

Dans `backend/config.py`, ligne 28 :
```python
OLLAMA_BASE_URL: str = "http://localhost:11434"
```

C'est déjà la valeur par défaut ! ✅

### 5. Vérifier que Tout Fonctionne

1. **Backend local** : http://192.168.11.101:8000/docs
2. **Ollama local** : http://localhost:11434/api/tags
3. **App mobile** : Doit pouvoir appeler le backend local

## ⚠️ À Propos de l'IP Locale

L'IP **192.168.11.101** peut changer si :
- Vous reconnectez le WiFi
- Le routeur redonne une nouvelle IP via DHCP

### Solution : IP Statique (Optionnel)

Pour avoir toujours la même IP :

1. Windows → Paramètres → Réseau et Internet → Wi-Fi
2. Cliquez sur votre réseau WiFi → Propriétés
3. Modifiez → "Édition"
4. Passer de "Automatique (DHCP)" à "Manuel"
5. Configurez :
   - Adresse IP : `192.168.11.101`
   - Masque de sous-réseau : `255.255.255.0`
   - Passerelle : `192.168.11.1` (ou celle de votre routeur)

**OU** : Utilisez simplement l'IP actuelle et mettez-la à jour si elle change.

## 🚀 Pour la Démo

Cette solution est **parfaite pour une démo** :
- Tout fonctionne localement
- Pas de problème de tunnel
- Plus rapide
- Plus fiable

Vous pouvez expliquer que :
- En production, le backend serait sur Railway/AWS/etc.
- Pour la démo, vous utilisez un backend local pour éviter les problèmes de réseau

---

**Recommandation** : Utilisez cette approche pour votre démo ! C'est la solution la plus simple et la plus fiable.

