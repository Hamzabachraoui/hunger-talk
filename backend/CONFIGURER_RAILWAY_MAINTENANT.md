# ✅ Configuration Railway - URL ngrok

## Votre URL ngrok :
```
https://lyndsey-figgier-suzanna.ngrok-free.dev
```

## 📋 Étapes dans Railway (2 minutes)

### 1. Allez sur Railway
1. Ouvrez : https://railway.app
2. Connectez-vous à votre compte
3. Sélectionnez votre projet **Hunger-Talk**
4. Cliquez sur votre **service backend**

### 2. Ajoutez la Variable d'Environnement
1. Cliquez sur l'onglet **Variables** (en haut)
2. Cliquez sur **+ New Variable**
3. Remplissez :
   - **Name** : `OLLAMA_BASE_URL`
   - **Value** : `https://lyndsey-figgier-suzanna.ngrok-free.dev`
   - ⚠️ **IMPORTANT** : Pas de `/` à la fin !
4. Cliquez sur **Add**

### 3. Attendez le Redéploiement
- Railway va automatiquement redéployer votre service
- Attendez **2-3 minutes**
- Vous verrez "Deploying..." puis "Active"

### 4. Vérifiez les Logs
1. Allez dans l'onglet **Deployments**
2. Cliquez sur le dernier déploiement
3. Vérifiez qu'il n'y a pas d'erreurs

## ✅ Test

Une fois le déploiement terminé :
1. Ouvrez votre application mobile
2. Allez dans le Chat IA
3. Envoyez un message de test
4. L'IA devrait répondre ! 🎉

## ⚠️ Important

- **Gardez ngrok ouvert** : Ne fermez pas la fenêtre ngrok pendant que vous utilisez l'IA
- **Gardez Ollama ouvert** : Ne fermez pas Ollama
- **URL change** : Si vous redémarrez ngrok, l'URL change et il faudra mettre à jour Railway

---

**C'est tout ! Dites-moi quand c'est fait et on teste ensemble !** 🚀

