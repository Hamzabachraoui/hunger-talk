# 🚀 Bienvenue dans Hunger-Talk - Point de départ

Ce fichier vous guide pour démarrer le projet Hunger-Talk.

## 📍 Où en êtes-vous ?

### Si vous venez de commencer :

1. **Lire ce fichier** ✅ (vous êtes ici)
2. **Installer tous les outils** → Voir section ci-dessous
3. **Configurer l'environnement** → Utiliser les scripts fournis
4. **Commencer le développement** → Suivre `details.txt`

---

## 🛠️ Installation rapide (30-45 minutes)

### Option 1 : Script automatique (recommandé)

```powershell
.\COMPLETE_SETUP.bat
```

Ce script vous guide à travers toutes les étapes.

### Option 2 : Étapes individuelles

1. **Vérifier les outils installés** :
   ```powershell
   powershell -ExecutionPolicy Bypass -File install_all_tools.ps1
   ```

2. **Installer PostgreSQL** :
   ```powershell
   .\setup_postgresql.bat
   ```
   - Ou suivre : `docs/GUIDE_CONFIGURATION_COMPLETE.md`

3. **Installer Ollama** :
   ```powershell
   .\setup_ollama.bat
   ```
   - Ou suivre : `docs/GUIDE_CONFIGURATION_COMPLETE.md`

4. **Configurer le backend** :
   ```powershell
   cd backend
   .\init_setup.bat
   ```

---

## 📚 Documentation disponible

| Fichier | Description |
|---------|-------------|
| `README.md` | Vue d'ensemble du projet |
| `details.txt` | Plan détaillé complet (toutes les phases) |
| `CHECKLIST_CONFIGURATION.md` | Checklist pour suivre la configuration |
| `docs/GUIDE_CONFIGURATION_COMPLETE.md` | Guide détaillé d'installation |
| `docs/INSTALLATION_TOOLS.md` | Guide d'installation des outils |
| `INSTALLATION_RAPIDE.md` | Version condensée de l'installation |

---

## ✅ Checklist rapide

- [ ] Python 3.10+ installé
- [ ] Flutter installé
- [ ] PostgreSQL installé + base `hungertalk_db` créée
- [ ] Ollama installé + modèle `llama3.1:8b` téléchargé
- [ ] Git installé
- [ ] Environnement virtuel Python créé (`backend/venv`)
- [ ] Dépendances backend installées (`pip install -r requirements.txt`)
- [ ] Fichier `.env` configuré dans `backend/`

---

## 🎯 Après la configuration

Une fois tout configuré :

1. **Vérifier** : Exécutez `install_all_tools.ps1` - tout doit être ✅
2. **Suivre le plan** : Consultez `details.txt` pour les prochaines étapes
3. **Commencer la PHASE 1** : Conception et Design
4. **Puis la PHASE 2** : Développement Backend

---

## 🆘 Besoin d'aide ?

1. **Installation** : Voir `docs/GUIDE_CONFIGURATION_COMPLETE.md`
2. **Problèmes** : Section "Résolution des problèmes" dans le guide
3. **Vérification** : Utiliser `install_all_tools.ps1`

---

## 📞 Commandes utiles

```powershell
# Vérifier les outils
powershell -ExecutionPolicy Bypass -File install_all_tools.ps1

# Configurer PostgreSQL
.\setup_postgresql.bat

# Configurer Ollama
.\setup_ollama.bat

# Configurer tout
.\COMPLETE_SETUP.bat

# Initialiser le backend
cd backend
.\init_setup.bat
```

---

**Bon développement ! 🍽️✨**

*Hunger-Talk - Application mobile intelligente de gestion nutritionnelle*

