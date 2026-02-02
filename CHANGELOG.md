# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Versioning Sémantique](https://semver.org/spec/v2.0.0.html).

## [0.1.2] - 2026-02-02

### 🚀 Nouvelles fonctionnalités

#### Deep Links & Notifications Push
- **feat(ios)**: Support des deep links pour les services
  - Navigation vers le détail d'un service depuis une notification push
  - Ajout du type 'service' dans NotificationPayload
  - Gestion via environment key deepLinkServiceSlug

- **feat(ios)**: Reset du badge et tracking device UUID
  - Remise à zéro du badge à l'ouverture de l'app
  - Identification stable des appareils via device_uuid

- **fix(ios)**: Stockage du deep link en attente au lancement depuis notification

#### Interface utilisateur
- **feat(ios)**: Amélioration de l'affichage des articles sur Home avec navigation WhatsNew
- **feat(ios)**: Cartes Actualités cliquables avec nouveaux sous-titres
- **feat(ios)**: Suppression de l'onglet Actualités, redirection vers Blog
- **feat(ios)**: Rendu HTML pour les descriptions de services

#### Performance
- **perf(ios)**: Affichage instantané des articles avec tracking en arrière-plan
- **feat(ios)**: Amélioration UX avec préchargement données, cache images et thème adaptatif

### 🐛 Corrections de bugs

- **fix(ios)**: Seules les cartes teaser disponibles sont cliquables
- **fix(ios)**: Navigation HomeView avec binding correct
- **fix(ios)**: Tap cartes et sous-titre "Conseils d'experts" restauré
- **fix(ios)**: Crash NavigationStack imbriqué dans ContactView
- **fix(ios)**: Simplification du rendu HTML
- **fix(ios)**: Couleur accent pour "Voir tout" dans SectionHeader
- **fix(ios)**: Prévention des sheets empilés pour formations liées
- **fix(ios)**: Navigation dans AllFormationsListView
- **fix(ios)**: Navigation et réactivité des taps améliorées

---

## [0.1.1] - 2026-01-29

### 🚀 Nouvelles fonctionnalités

#### Structure de l'application
- **feat(ios)**: Initialisation du projet MadiniaApp avec SwiftUI
- **feat(ios)**: Tab bar style App Store avec réorganisation des onglets
- **feat(ios)**: Remplacement de l'onglet Blog par Madinia Hub
- **feat(ios)**: Onglet Search avec services et catégories
- **feat(ios)**: Onglet L'IA&Vous (espace utilisateur)

#### Interface utilisateur
- **feat(ios)**: Splash screen avec logo et assets
- **feat(ios)**: Icône d'application et intégration Assets.xcassets
- **feat(ios)**: Support mode clair/sombre avec bouton settings global
- **feat(ios)**: Splash screen suit le réglage dark mode
- **feat(ios)**: Carousels teaser et correction layout bouton CTA
- **feat(ios)**: UI/UX redesign avec branding Madin.IA

#### Formations
- **feat(ios)**: Section Top Rated sur HomeView
- **feat(ios)**: Section catégories avec intégration API et navigation
- **feat(ios)**: Vue détail unifiée avec cache et préchargement
- **feat(ios)**: Visionneuse d'images plein écran avec gestes de zoom
- **feat(ios)**: Onglet formations liées avec comportement de remplacement sheet
- **feat(ios)**: Système de favoris avec navigation améliorée
- **feat(ios)**: Bouton recherche dans la vue formations sauvegardées vide

#### Pré-inscriptions
- **feat(ios)**: Formulaire de pré-inscription complet avec tous les champs
- **feat(ios)**: Vue pré-inscriptions avec limite de 5 enforced

#### Notifications Push
- **feat(ios)**: Intégration complète des notifications push avec backend
- **feat(ios)**: Prompt de permission automatique au premier lancement

#### Performance
- **feat(ios)**: Préchargement des données, cache d'images et thème adaptatif

### 🐛 Corrections de bugs

- **fix(ios)**: Navigation dans AllFormationsListView
- **fix(ios)**: Prévention des sheets empilés pour formations liées
- **fix(ios)**: Couleur accent pour "Voir tout" dans SectionHeader
- **fix(ios)**: Décodage pré-inscriptions et bannière Madi coming soon
- **fix(ios)**: Gestion durée int et états vides/erreur pré-inscriptions
- **fix(ios)**: Navigation arrière catégories vers grille
- **fix(ios)**: Chargement catégories à l'apparition CategoriesGridView
- **fix(ios)**: Padding bas pour tab bar sur vues scrollables
- **fix(ios)**: Padding bas vue succès Contact
- **fix(ios)**: Navigation vers onglet Contact depuis MadiniaHubView
- **fix(ios)**: Navigation et réactivité des taps améliorées
- **fix(ios)**: Crash NavigationStack imbriqué simplifié
- **fix(ios)**: Rendu HTML des descriptions services
- **fix(ios)**: Tap cartes et sous-titre "Conseils d'experts" restauré
- **fix(ios)**: Navigation HomeView avec binding correct
- **fix(ios)**: Seules les cartes teaser disponibles cliquables

### 📚 Documentation

- **docs**: Diagrammes d'architecture Mermaid
- **docs**: Amélioration qualité et lisibilité des diagrammes

### ⚙️ Configuration

- **chore**: Ajout .gitignore pour exclure fichiers sensibles
- **refactor**: Renommage Assets 2.xcassets en Assets.xcassets
