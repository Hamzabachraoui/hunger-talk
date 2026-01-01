# Solution : IP Ollama via Railway

## 🎯 Approche Simplifiée

Au lieu de scanner le réseau ou d'utiliser un serveur PC local, l'application mobile récupère maintenant l'IP Ollama directement depuis Railway !

## ✨ Avantages

- ✅ **Plus rapide** : Récupération instantanée depuis Railway (pas de scan réseau)
- ✅ **Plus fiable** : Pas besoin de serveur PC local ou de scan réseau
- ✅ **Plus simple** : Un seul script à exécuter sur le PC
- ✅ **Fonctionne toujours** : Même si l'IP change, il suffit de ré-exécuter le script

## 📋 Comment ça fonctionne

1. **Sur le PC** : Un script PowerShell enregistre l'IP Ollama dans Railway
2. **Sur le téléphone** : L'application récupère l'IP depuis Railway automatiquement
3. **C'est tout !** Pas besoin de scan réseau ni de serveur local

## 🚀 Utilisation

### Étape 1 : Enregistrer l'IP dans Railway

Sur votre PC, exécutez :

```powershell
.\enregistrer_ip_ollama_railway.ps1 -Email "votre@email.com" -Password "votre_mot_de_passe"
```

Ou si vous avez déjà un token JWT :

```powershell
.\enregistrer_ip_ollama_railway.ps1 -Token "votre_token_jwt"
```

Le script :
- Détecte automatiquement l'IP locale du PC
- Vérifie qu'Ollama fonctionne
- Enregistre l'IP dans Railway via l'API

### Étape 2 : Utiliser l'application mobile

L'application mobile récupère automatiquement l'IP depuis Railway au démarrage. Aucune configuration nécessaire !

## 🔄 Quand ré-enregistrer l'IP ?

Vous devez ré-exécuter le script si :
- L'IP du PC change (nouveau WiFi, redémarrage, etc.)
- Vous changez de réseau WiFi

**Note** : Si Ollama est démarré avec `configurer_et_demarrer_ollama.ps1`, vous pouvez créer un script qui enregistre automatiquement l'IP dans Railway au démarrage.

## 📝 Scripts Disponibles

- `enregistrer_ip_ollama_railway.ps1` - Enregistre l'IP Ollama dans Railway
- `configurer_et_demarrer_ollama.ps1` - Démarre Ollama avec accès réseau

## 🔍 Vérification

Pour vérifier que l'IP est bien enregistrée dans Railway :

1. Connectez-vous à Railway
2. Allez dans votre base de données
3. Vérifiez la table `system_config` avec la clé `ollama_base_url`

Ou testez via l'API :

```powershell
curl https://hunger-talk-production.up.railway.app/api/system-config/ollama
```

## ⚠️ Notes Importantes

- Le script nécessite une authentification (email/password ou token JWT)
- L'IP doit être accessible depuis le réseau local (Ollama doit écouter sur 0.0.0.0)
- Le PC et le téléphone doivent être sur le même réseau WiFi

