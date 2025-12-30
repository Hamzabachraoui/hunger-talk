---
name: Stabilisation_fullstack_APK_push
overview: Corriger backend et app mobile (auth, stock, recettes, chat, notifications, prefs/offline, sécurité), livrer APK debug+release et pousser sur origin/main.
todos:
  - id: backend-audit
    content: Auditer backend/tests et erreurs actuelles
    status: completed
  - id: backend-auth-sec
    content: Corriger auth/permissions/validation/CORS
    status: completed
  - id: backend-features
    content: Fix stock/recettes/chat/notifications/prefs/offline
    status: completed
  - id: mobile-align
    content: Aligner mobile avec schémas/URLs backend
    status: completed
  - id: tests-apk-push
    content: Tests, build APK debug+release, push origin/main
    status: completed
---

# Plan backend + mobile + APK + push

- Backend audit & exécution locale : vérifier stack FastAPI (ex: `backend/`), variables d’env (.env), base URL exposée pour mobile ; lancer tests existants (`pytest`) et collecter 404/500 connus.
- Auth/ sécurité : valider login/register/logout, rafraîchissement/expiration token, hashing, permissions/403, CORS, validation stricte pydantic ; corriger 401/403 et sécuriser endpoints critiques.
- Stock/recettes/chat/notifications : tester endpoints (CRUD stock + stats, recettes/reco, chat IA, notifications). Corriger schémas pour matcher modèles mobile, éviter 307/redirects, gérer erreurs 4xx/5xx et timeouts.
- Préférences/offline : ajouter/fiabiliser endpoints préférences utilisateur, exposer données nécessaires au cache côté mobile (réponses complètes, etag/last-modified ou champs de version) si prévu ; documenter mode offline minimal.
- Sécurité additionnelle : validation d’entrée (limiter tailles, types), contrôle d’accès sur routes, limiter exposition d’infos sensibles dans réponses/logs.
- Alignement mobile : mettre à jour constantes/URL et mapping modèles si schémas changent ; garder base URL surprod par défaut + override `API_BASE_URL`; vérifier navigation et écrans liés (auth, stock, recettes, chat, notifications, prefs).
- Tests : backend (pytest ciblant auth/stock/recipes/chat/notifications), mobile (`flutter analyze` + `flutter test`), ajouter tests unitaires/API si manquants.
- Builds livrables : générer APK debug et APK release. Pour release, utiliser keystore fourni (ou à fournir : chemin, alias, mots de passe) et consigner commandes exécutées.