# 📋 Commandes pour Push GitHub - À exécuter manuellement

## 📂 Chemin du projet
```
G:\EMSI\3eme annee\PFA
```

## 🔧 Commandes à exécuter dans PowerShell

### 1. Aller dans le répertoire du projet
```powershell
cd "G:\EMSI\3eme annee\PFA"
```

### 2. Vérifier l'état Git
```powershell
git status
```

### 3. Vérifier les commits à pousser
```powershell
git log origin/main..HEAD --oneline
```

### 4. Push vers GitHub
```powershell
git push origin main
```

## 🔄 Si le push échoue (timeout), essayez :

### Option A : Réessayer directement
```powershell
git push origin main
```

### Option B : Push avec plus de buffer
```powershell
git config http.postBuffer 1048576000
git push origin main
```

### Option C : Push avec verbose pour voir la progression
```powershell
git push origin main --progress
```

## ✅ Vérifier que le push a réussi

Après le push, vérifiez avec :
```powershell
git fetch origin
git log origin/main..HEAD --oneline
```

Si cette commande ne retourne rien, c'est que tout est bien poussé !

## 📦 Vérifier l'état actuel

Pour voir ce qui doit être poussé :
```powershell
git status
```

## 🔗 Repository GitHub

Votre repository : https://github.com/Hamzabachraoui/hunger-talk.git

