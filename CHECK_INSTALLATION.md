# ✅ Vérification de l'installation - Hunger-Talk

## Commande rapide

Pour vérifier quels outils sont installés, exécutez :

```powershell
powershell -ExecutionPolicy Bypass -File install_all_tools.ps1
```

## Résultat du dernier test

Selon le dernier test, voici l'état des outils :

- ✅ **Python 3.11.9** - Installé
- ✅ **pip** - Installé
- ✅ **Flutter** - Installé
- ❌ **PostgreSQL** - Non installé
- ❌ **Ollama** - Non installé
- ✅ **Git 2.50.1** - Installé

## Prochaines étapes

### 1. Installer PostgreSQL

📥 [Télécharger PostgreSQL](https://www.postgresql.org/download/windows/)

1. Télécharger et installer PostgreSQL
2. Noter le mot de passe du superutilisateur `postgres`
3. Créer la base de données `hungertalk_db`
4. Vérifier : `psql --version`

### 2. Installer Ollama

📥 [Télécharger Ollama](https://ollama.ai/download)

1. Télécharger et installer Ollama
2. Télécharger le modèle LLaMA :
   ```powershell
   ollama pull llama3.1:8b
   ```
3. Vérifier : `ollama list`

### 3. Vérifier à nouveau

Après avoir installé les outils manquants, réexécutez :

```powershell
powershell -ExecutionPolicy Bypass -File install_all_tools.ps1
```

## Documentation complète

Pour les instructions détaillées, voir :
- **docs/INSTALLATION_TOOLS.md** - Guide complet d'installation
- **INSTALLATION_RAPIDE.md** - Version condensée

---

**Dernière mise à jour** : Automatique via le script de vérification

