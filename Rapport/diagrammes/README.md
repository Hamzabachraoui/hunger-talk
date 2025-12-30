# Diagrammes PlantUML - Système SRM-MS

Ce dossier contient les diagrammes de cas d'utilisation pour le système de gestion intelligente des pannes SRM-MS, basés sur le code réel des deux plateformes développées.

## 📊 Diagrammes Disponibles

### 1. `cas_utilisation_plateforme_admin.puml`
**Plateforme d'Administration SRM-MS** - Vue d'ensemble de la plateforme interne.

**Acteurs :**
- **Administrateur** : Gestion complète du système
- **Responsable** : Coordination et planification
- **Technicien** : Interventions sur le terrain
- **Systèmes externes** : SCADA, IA

**Fonctionnalités :**
- Gestion des comptes et rôles
- Dashboard et analytics
- Gestion des pannes et interventions
- Prédiction et IA
- Gestion des équipes
- Gestion des clients
- Configuration système

### 2. `cas_utilisation_portail_client.puml`
**Portail Client SRM-MS** - Interface publique pour les clients.

**Acteurs :**
- **Client** : Utilisateur authentifié
- **Visiteur** : Utilisateur non authentifié
- **Système** : Notifications

**Fonctionnalités :**
- Accueil et navigation
- Authentification client
- Déclaration de pannes
- Suivi des pannes
- Notifications
- Support et chat

### 3. `cas_utilisation_systeme_complet.puml`
**Système Complet SRM-MS** - Vue d'ensemble de l'interaction entre les plateformes.

**Intégrations :**
- **Plateforme d'Administration** : Gestion interne
- **Portail Client** : Interface publique
- **Systèmes Externes** : SCADA, IA, Notifications

## 🎨 Légende des Couleurs

### Plateforme d'Administration
- **Jaune clair** : Actions Administrateur
- **Bleu clair** : Actions Responsable
- **Vert clair** : Actions Technicien
- **Gris clair** : Systèmes externes

### Portail Client
- **Bleu clair** : Actions Client
- **Vert clair** : Actions Visiteur
- **Gris clair** : Systèmes

## 🔧 Comment Utiliser ces Diagrammes

### Option 1 : PlantUML Online
1. Copier le contenu d'un fichier .puml
2. Aller sur [PlantUML Online](http://www.plantuml.com/plantuml/uml/)
3. Coller le code et générer l'image
4. Télécharger l'image (PNG, SVG, etc.)

### Option 2 : Extension VS Code
1. Installer l'extension "PlantUML" dans VS Code
2. Ouvrir un fichier .puml
3. Utiliser Ctrl+Shift+P et "PlantUML: Preview Current Diagram"

### Option 3 : Plugin LaTeX
Si vous utilisez LaTeX, vous pouvez intégrer PlantUML directement avec des packages comme `plantuml`.

## 📋 Intégration dans le Rapport

Pour intégrer ces diagrammes dans votre rapport LaTeX :

```latex
\begin{figure}[H]
    \centering
    \includegraphics[width=\textwidth]{diagrammes/cas_utilisation_plateforme_admin.png}
    \caption{Diagramme de cas d'utilisation - Plateforme d'Administration SRM-MS}
    \label{fig:cas_utilisation_admin}
\end{figure}

\begin{figure}[H]
    \centering
    \includegraphics[width=\textwidth]{diagrammes/cas_utilisation_portail_client.png}
    \caption{Diagramme de cas d'utilisation - Portail Client SRM-MS}
    \label{fig:cas_utilisation_client}
\end{figure}

\begin{figure}[H]
    \centering
    \includegraphics[width=\textwidth]{diagrammes/cas_utilisation_systeme_complet.png}
    \caption{Diagramme de cas d'utilisation - Système Complet SRM-MS}
    \label{fig:cas_utilisation_complet}
\end{figure}
```

## 🏗️ Architecture des Fonctionnalités

### Plateforme d'Administration
- **7 packages fonctionnels** couvrant les aspects essentiels
- **23 cas d'utilisation** principaux
- **3 rôles utilisateurs** avec permissions différenciées
- **Intégration** avec systèmes externes

### Portail Client
- **6 packages fonctionnels** pour l'expérience client
- **20 cas d'utilisation** principaux
- **2 types d'utilisateurs** (client/visiteur)
- **Interface moderne** avec notifications

### Système Complet
- **3 packages d'intégration** montrant les interactions
- **15 cas d'utilisation** principaux
- **Flux de données** entre plateformes
- **Architecture distribuée** avec systèmes externes

## 📈 Fonctionnalités Clés

### Intelligence Artificielle
- Prédiction de pannes
- Génération d'alertes
- Modèles d'apprentissage

### Gestion des Pannes
- Détection automatique
- Assignation d'équipes
- Suivi en temps réel

### Communication Client
- Notifications multi-canal
- Chat support
- Suivi personnalisé

### Analytics
- Dashboard temps réel
- KPIs et statistiques
- Rapports exportables 