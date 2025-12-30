# Guide : Configuration Ollama avec Tunnel Local (Gratuit)

Ce guide explique comment exposer votre Ollama local via un tunnel pour que Railway puisse y accéder.

## ⚠️ Important pour Projet Académique

Cette solution fonctionne mais nécessite que votre ordinateur soit allumé et connecté à Internet. Pour une démonstration, c'est parfait !

## Option 1 : Ngrok (Recommandé - Gratuit)

### Étape 1 : Installer Ngrok

1. Téléchargez ngrok depuis : https://ngrok.com/download
2. Décompressez l'archive
3. Créez un compte gratuit sur https://ngrok.com (nécessaire pour obtenir un token)

### Étape 2 : Configurer Ngrok

1. Connectez-vous à votre compte ngrok
2. Récupérez votre token d'authentification
3. Dans un terminal, exécutez :
   ```bash
   ngrok config add-authtoken VOTRE_TOKEN_ICI
   ```

### Étape 3 : Démarrer Ollama

Assurez-vous qu'Ollama est démarré sur votre machine :
```bash
ollama serve
```

Vérifiez qu'il fonctionne :
```bash
curl http://localhost:11434/api/tags
```

### Étape 4 : Créer le Tunnel

Dans un nouveau terminal, exécutez :
```bash
ngrok http 11434
```

Vous obtiendrez une URL comme : `https://abc123.ngrok-free.app`

**⚠️ IMPORTANT :** Notez cette URL, vous en aurez besoin !

### Étape 5 : Configurer Railway

1. Allez sur Railway Dashboard → Votre Service → Variables
2. Ajoutez la variable d'environnement :
   ```
   OLLAMA_BASE_URL=https://abc123.ngrok-free.app
   ```
   (Remplacez par votre URL ngrok)

3. Redéployez le service Railway

### Étape 6 : Tester

Testez depuis Railway que l'IA fonctionne via l'application mobile.

## Option 2 : Cloudflare Tunnel (Alternative Gratuite)

### Étape 1 : Installer Cloudflared

Téléchargez depuis : https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation/

### Étape 2 : Créer le Tunnel

```bash
cloudflared tunnel --url http://localhost:11434
```

Vous obtiendrez une URL comme : `https://abc123.trycloudflare.com`

### Étape 3 : Configurer Railway

Même procédure que pour ngrok, mais avec l'URL Cloudflare.

## ⚠️ Limitations

1. **Votre PC doit être allumé** : Le tunnel ne fonctionne que si votre ordinateur est démarré
2. **URL change à chaque démarrage** : Avec le plan gratuit, l'URL change à chaque fois
   - **Solution** : Utilisez un compte ngrok payant OU mettez à jour la variable Railway à chaque fois
3. **Connexion Internet requise** : Votre PC doit avoir Internet

## 🔄 Workflow pour Démonstration

1. **Avant la démo** :
   - Démarrer Ollama : `ollama serve`
   - Démarrer ngrok : `ngrok http 11434`
   - Copier l'URL ngrok
   - Mettre à jour `OLLAMA_BASE_URL` dans Railway
   - Attendre le redéploiement (2-3 minutes)

2. **Pendant la démo** :
   - Garder Ollama et ngrok ouverts
   - Tester que tout fonctionne

3. **Après la démo** :
   - Vous pouvez arrêter ngrok et Ollama

## 🚀 Script Automatique (Optionnel)

Un script PowerShell est fourni pour automatiser le démarrage : `demarrer_ollama_tunnel.ps1`

## 📝 Notes Importantes

- L'URL ngrok change à chaque redémarrage (plan gratuit)
- Pour une URL fixe, utilisez un compte ngrok payant (5$/mois) ou Cloudflare Tunnel avec configuration
- Cette solution est parfaite pour un projet académique et une démonstration

