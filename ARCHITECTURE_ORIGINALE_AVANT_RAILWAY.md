# 🏗️ Architecture Originale - Avant Railway

## 💡 L'Idée de Base

**Concept** : Faire tourner le backend **localement** sur votre PC, et l'app mobile communique directement avec via l'IP locale.

## 🏠 Architecture Locale (Avant Railway)

```
┌─────────────────┐
│  App Mobile     │
│  (Téléphone)    │
└────────┬────────┘
         │ WiFi local (même réseau)
         ↓
┌─────────────────────────┐
│  Backend Local          │
│  http://192.168.11.101:8000 │
│  (Sur votre PC)         │
└────────┬────────────────┘
         │ localhost
         ↓
┌─────────────────────────┐
│  Ollama Local           │
│  localhost:11434        │
│  (Sur votre PC)         │
└─────────────────────────┘
```

## 📋 Comment Ça Fonctionnait

### 1. Backend Local

- Le backend FastAPI tournait sur votre PC
- Écoutait sur `0.0.0.0:8000` (toutes les interfaces)
- Accessible via l'IP locale : `http://192.168.11.101:8000`
- Ollama tournait sur `localhost:11434`
- Le backend appelait Ollama directement (même machine)

### 2. App Mobile - Configuration de l'IP

L'app mobile avait **deux façons** de trouver l'adresse du backend :

#### Option A : Page de Configuration (Paramètres)

Dans l'app mobile, il y avait une page **"Configuration du Serveur"** (`server_config_screen.dart`) où vous pouviez :
- Entrer manuellement l'IP du backend : `http://192.168.11.101:8000`
- Tester la connexion
- Sauvegarder l'IP (stockée dans `SharedPreferences`)

#### Option B : Découverte Automatique

Le service `ServerDiscoveryService` pouvait :
- Scanner le réseau local pour trouver automatiquement le backend
- Essayer plusieurs IPs courantes (192.168.x.x)
- Tester la connexion avec `/health`

### 3. Stockage de l'IP

L'IP était stockée dans :
- **SharedPreferences** de l'app mobile
- Clé : `server_base_url`
- Valeur : `http://192.168.11.101:8000`

## 🔄 Flux Complet

1. **Démarrage du Backend Local** :
   ```powershell
   .\demarrer_serveur.ps1
   ```
   - Backend écoute sur `0.0.0.0:8000`
   - Accessible via `http://192.168.11.101:8000`

2. **Configuration dans l'App Mobile** :
   - Aller dans **Paramètres** → **Configuration du Serveur**
   - Entrer : `http://192.168.11.101:8000`
   - Tester la connexion
   - Sauvegarder

3. **Utilisation** :
   - L'app mobile appelle le backend local via l'IP
   - Le backend local appelle Ollama sur localhost
   - **Tout fonctionne en local !**

## ✅ Avantages de cette Architecture

- ✅ **Simple** : Pas besoin de cloud, de tunnel, etc.
- ✅ **Rapide** : Tout est sur le même réseau local
- ✅ **Fiable** : Pas de dépendance externe
- ✅ **Gratuit** : Pas de coût de cloud
- ✅ **Parfait pour démo** : Tout fonctionne localement

## ❌ Inconvénients

- ❌ Le PC doit être allumé et sur le même WiFi
- ❌ L'IP peut changer si vous changez de réseau
- ❌ Pas accessible depuis Internet (seulement réseau local)

## 📱 Fichiers Concernés

1. **`server_config_screen.dart`** : Écran de configuration dans l'app
2. **`config_service.dart`** : Service qui stocke/récupère l'IP
3. **`server_discovery_service.dart`** : Découverte automatique du serveur
4. **`app_config.dart`** : Configuration globale de l'app

## 🎯 Résumé

**L'idée originale** : Tout tourne en local !
- Backend local sur votre PC (accessible via IP locale)
- Ollama local sur votre PC
- App mobile configurée avec l'IP locale
- Communication via le réseau WiFi local
- Pas de cloud, pas de tunnel, tout simple !

**C'était parfait pour une démo locale !** 🎉

