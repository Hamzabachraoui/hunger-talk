# 🍽️ Hunger-Talk

Application mobile intelligente de gestion nutritionnelle et alimentaire avec IA.

## 📱 Description

Hunger-Talk est une application mobile Flutter qui permet de :
- Gérer son stock alimentaire
- Recevoir des recommandations de recettes basées sur le stock disponible
- Interagir avec une IA pour obtenir des suggestions personnalisées
- Suivre ses objectifs nutritionnels

## 🏗️ Architecture

- **Backend** : FastAPI (Python) avec PostgreSQL
- **Mobile** : Flutter (Dart)
- **IA** : Ollama avec LLaMA 3.1
- **Base de données** : PostgreSQL

## 🚀 Déploiement

### Backend sur Railway

Le backend est configuré pour être déployé sur Railway. Voir `backend/DEPLOIEMENT_RAILWAY.md` pour les instructions complètes.

### Configuration Rapide

1. Créer un compte sur [railway.app](https://railway.app)
2. Connecter le repository GitHub
3. Ajouter PostgreSQL
4. Configurer les variables d'environnement
5. Railway déploie automatiquement !

## 📚 Documentation

- **Déploiement Railway** : `backend/DEPLOIEMENT_RAILWAY.md`
- **Guide GitHub** : `GUIDE_GITHUB.md`
- **Configuration complète** : `docs/DEPLOIEMENT_PROFESSIONNEL.md`

## 🛠️ Développement Local

### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload
```

### Mobile

```bash
cd mobile
flutter pub get
flutter run
```

## 📝 License

Projet académique - PFA
