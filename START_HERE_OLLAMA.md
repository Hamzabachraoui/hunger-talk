# 🚀 Démarrage Rapide - Ollama avec Accès Réseau

## ✅ État Actuel

**Ollama fonctionne et est accessible sur le réseau !**

- ✅ Ollama répond sur `localhost:11434`
- ✅ Ollama est accessible sur `192.168.11.101:11434` depuis le réseau
- ✅ Modèle `llama3.1:8b` disponible
- ⚠️ Serveur IP (port 8001) optionnel mais recommandé

## 🎯 Pour Démarrer Tout l'Environnement

### Option 1 : Script Unique (Recommandé)

```powershell
.\DEMARRER_TOUT.ps1
```

Ce script démarre automatiquement :
1. Ollama avec accès réseau
2. Le serveur IP Ollama (pour découverte rapide)

### Option 2 : Scripts Séparés

#### 1. Démarrer Ollama avec accès réseau

```powershell
.\configurer_et_demarrer_ollama.ps1
```

#### 2. Démarrer le serveur IP (optionnel mais recommandé)

```powershell
.\demarrer_ollama_ip_server.ps1
```

## 📱 Configuration pour l'Application Mobile

Votre application mobile peut maintenant se connecter à :

**URL Ollama :** `http://192.168.11.101:11434`

L'application détectera automatiquement cette IP au démarrage grâce au système de découverte automatique que nous avons implémenté.

## 🔍 Vérification

Pour vérifier que tout fonctionne :

```powershell
# Test 1: Ollama sur localhost
curl http://localhost:11434/api/tags

# Test 2: Ollama sur IP réseau
curl http://192.168.11.101:11434/api/tags

# Test 3: Serveur IP (si démarré)
curl http://localhost:8001/ollama-ip
```

## ⚠️ Notes Importantes

1. **Ollama doit rester démarré** - Laissez la fenêtre PowerShell ouverte
2. **Même réseau WiFi** - Le PC et le téléphone doivent être sur le même réseau
3. **Firewall Windows** - Si ça ne fonctionne pas, vérifiez que le port 11434 n'est pas bloqué

## 🛠️ En Cas de Problème

### Ollama ne répond pas sur le réseau

1. Vérifiez qu'Ollama écoute sur `0.0.0.0:11434` :
   ```powershell
   Get-NetTCPConnection -LocalPort 11434 | Format-Table
   ```

2. Redémarrez Ollama avec le script :
   ```powershell
   .\configurer_et_demarrer_ollama.ps1
   ```

### L'application mobile ne trouve pas Ollama

1. Vérifiez que le PC et le téléphone sont sur le même WiFi
2. Démarrez le serveur IP pour une détection plus rapide :
   ```powershell
   .\demarrer_ollama_ip_server.ps1
   ```
3. Vérifiez les logs de l'application pour voir où la découverte échoue

## 📝 Fichiers Créés

- `configurer_et_demarrer_ollama.ps1` - Configure et démarre Ollama avec accès réseau
- `demarrer_ollama_ip_server.ps1` - Démarre le serveur IP Ollama
- `DEMARRER_TOUT.ps1` - Script principal qui démarre tout
- `ollama_ip_server.py` - Serveur HTTP Python pour exposer l'IP
- `mobile/lib/data/services/ollama_discovery_service.dart` - Service de découverte dans l'app

