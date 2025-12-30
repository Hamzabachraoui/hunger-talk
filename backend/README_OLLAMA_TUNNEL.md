# 🚀 Guide Rapide : Ollama avec Tunnel (Projet Académique)

## 📋 Résumé

Votre backend est sur Railway, mais Ollama tourne sur votre PC local. On utilise un tunnel (ngrok) pour les connecter.

## ⚡ Démarrage Rapide (3 minutes)

### 1. Installer ngrok (une seule fois)

1. Téléchargez : https://ngrok.com/download
2. Décompressez dans un dossier (ex: `C:\ngrok`)
3. Créez un compte gratuit : https://ngrok.com
4. Récupérez votre token d'authentification
5. Dans PowerShell :
   ```powershell
   cd C:\ngrok
   .\ngrok.exe config add-authtoken VOTRE_TOKEN
   ```

### 2. Démarrer Ollama et le Tunnel

**Option A : Script automatique (Recommandé)**
```powershell
cd backend
.\demarrer_ollama_tunnel.ps1
```

**Option B : Manuel**
```powershell
# Terminal 1 : Démarrer Ollama
ollama serve

# Terminal 2 : Créer le tunnel
ngrok http 11434
```

### 3. Configurer Railway

1. Notez l'URL ngrok (ex: `https://abc123.ngrok-free.app`)
2. Railway Dashboard → Votre Service → Variables
3. Ajoutez : `OLLAMA_BASE_URL` = `https://abc123.ngrok-free.app`
4. Attendez le redéploiement (2-3 min)

### 4. Tester

Testez l'IA depuis votre application mobile !

## ⚠️ Points Importants

- ✅ **Gratuit** : ngrok plan gratuit fonctionne parfaitement
- ⚠️ **URL change** : L'URL ngrok change à chaque redémarrage
- ⚠️ **PC allumé** : Votre PC doit être allumé pendant la démo
- ✅ **Simple** : Parfait pour projet académique

## 🔄 Workflow pour Démonstration

1. **Avant la démo** :
   - Démarrer le script `demarrer_ollama_tunnel.ps1`
   - Copier l'URL ngrok
   - Mettre à jour Railway
   - Attendre 2-3 minutes

2. **Pendant la démo** :
   - Garder les fenêtres ouvertes
   - Tester que ça fonctionne

3. **Après la démo** :
   - Fermer ngrok et Ollama

## 📚 Documentation Complète

Voir `GUIDE_OLLAMA_TUNNEL.md` pour plus de détails.

