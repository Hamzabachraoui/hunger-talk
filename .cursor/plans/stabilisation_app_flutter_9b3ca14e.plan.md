---
name: Stabilisation App Flutter
overview: Audit complet et remise à niveau d’une app Flutter pour éliminer crashs runtime et erreurs API.
todos:
  - id: audit-repo
    content: Auditer structure et dépendances
    status: completed
  - id: reproduce-issues
    content: Reproduire crashs et erreurs API
    status: completed
  - id: fix-runtime
    content: Corriger crashs runtime (init/navigation/null safety)
    status: completed
  - id: fix-api
    content: Corriger couche API (base URL, modèles, erreurs)
    status: completed
  - id: tests-docs
    content: Ajouter tests clés et doc exécution
    status: completed
---

# Plan de stabilisation Flutter

- Audit rapide du projet (`pubspec.yaml`, dossiers `lib/`, `android/`, `ios/`) pour identifier stack, gestion d’env (base URL, clés), dépendances obsolètes et configuration de build.
- Reproduire les problèmes : exécuter `flutter analyze`, `flutter test` et un run sur l’émulateur/appareil pour capturer les crashs runtime et logs d’erreurs API (404/500).
- Corriger les crashs runtime : initialisation dans `main.dart`, configuration des services, routage/navigation, null-safety, injections et accès asynchrones (prefs/secure storage) avant usage.
- Assainir la couche API : vérifier services dans `lib/services/*` et modèles `lib/models/*`, aligner schémas de réponses, gérer timeouts/retry, mapping des erreurs, codes 401/403, refresh token si présent ; unifier base URL et secrets via configs d’environnement.
- Stabiliser les écrans critiques : auth, tableau de bord, formulaires ; états de chargement/erreur, validation, navigation cohérente.
- Renforcer les tests : unitaires sur services HTTP (mocks), widget tests sur les flux qui plantaient, smoke test de navigation ; relancer `flutter analyze`/`test` jusqu’au vert.