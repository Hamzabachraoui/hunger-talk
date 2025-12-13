# Hunger-Talk Mobile App

Application mobile Flutter pour la gestion nutritionnelle et alimentaire.

## 🚀 Démarrage rapide

### Prérequis
- Flutter SDK 3.0.0 ou supérieur
- Android Studio / VS Code avec extensions Flutter
- Émulateur Android ou appareil physique

### Installation

1. Installer les dépendances :
```bash
flutter pub get
```

2. Générer les fichiers de sérialisation JSON :
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Lancer l'application :
```bash
flutter run
```

## 📁 Structure du projet

```
lib/
├── core/              # Configuration et utilitaires de base
│   ├── theme/         # Design System (couleurs, thème)
│   ├── constants/     # Constantes de l'application
│   └── utils/         # Fonctions utilitaires
├── data/              # Couche de données
│   ├── models/        # Modèles de données
│   ├── services/      # Services API
│   └── repositories/  # Repositories
├── presentation/      # Couche de présentation
│   ├── screens/       # Écrans de l'application
│   ├── widgets/      # Widgets réutilisables
│   └── providers/    # Gestion d'état (Provider)
└── main.dart         # Point d'entrée
```

## 🎨 Design System

L'application utilise Material Design 3 avec une palette de couleurs douces adaptée à une app nutritionnelle.

## 🔗 API Backend

L'application se connecte au backend FastAPI sur `http://localhost:8000` (développement) ou l'URL de production.

## 📱 Fonctionnalités

- ✅ Authentification (Login/Register)
- ✅ Gestion du stock alimentaire
- ✅ Chat avec IA (RAG)
- ✅ Recettes et recommandations
- ✅ Statistiques nutritionnelles
- ✅ Notifications
- ✅ Liste de courses
- ✅ Préférences utilisateur

