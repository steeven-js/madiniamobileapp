# Documentation Technique Complète - Écosystème Madinia

**Version:** 2.0
**Date:** 2026-02-03
**Auteur:** Documentation générée automatiquement

---

## Table des Matières

1. [Vue d'Ensemble](#1-vue-densemble)
2. [Application Mobile iOS (MadiniaApp)](#2-application-mobile-ios-madiniaapp)
3. [Référence des Méthodes et Fonctions (Mobile)](#3-référence-des-méthodes-et-fonctions-mobile)
4. [API Web (madinia_web)](#4-api-web-madinia_web)
5. [Intégration Mobile ↔ API](#5-intégration-mobile--api)
6. [Services Externes](#6-services-externes)
7. [Sécurité](#7-sécurité)
8. [Annexes](#8-annexes)

---

# 1. Vue d'Ensemble

## 1.1 Architecture Globale

L'écosystème Madinia est composé de deux applications principales :

| Composant | Technologie | Rôle |
|-----------|-------------|------|
| **Application Mobile** | SwiftUI (iOS 17+) | Application native pour iOS |
| **API Web/Backend** | Laravel 12 + React/Inertia | Site web + API REST pour mobile |

### Diagramme d'Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        ÉCOSYSTÈME MADINIA                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐         ┌──────────────────────────────────┐  │
│  │  iOS App     │◄───────►│         Laravel API              │  │
│  │  (SwiftUI)   │  REST   │      (madinia_web)               │  │
│  │              │  API    │                                   │  │
│  └──────────────┘         │  ┌────────────┐ ┌────────────┐   │  │
│         │                 │  │  Filament  │ │   React    │   │  │
│         │                 │  │   Admin    │ │  Frontend  │   │  │
│         │                 │  └────────────┘ └────────────┘   │  │
│         │                 └──────────────────────────────────┘  │
│         │                              │                         │
│         │APNs                          │                         │
│         ▼                              ▼                         │
│  ┌──────────────┐         ┌──────────────────────────────────┐  │
│  │    Apple     │         │      Services Externes           │  │
│  │    Push      │         │  ┌──────┐ ┌────────┐ ┌────────┐  │  │
│  │  Notification│         │  │n8n   │ │Systeme │ │Supabase│  │  │
│  │   Service    │         │  │      │ │.io     │ │Storage │  │  │
│  └──────────────┘         │  └──────┘ └────────┘ └────────┘  │  │
│                           └──────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## 1.2 Domaines Fonctionnels

| Domaine | Description |
|---------|-------------|
| **Formations** | Catalogue de formations professionnelles (Starter, Performer, Master) |
| **Packs IA** | Formations en ligne via Systeme.io |
| **Blog** | Articles et contenus éditoriaux |
| **Services** | Conférences, audits, coaching |
| **Pré-inscriptions** | Gestion des demandes d'inscription aux formations |
| **Notifications Push** | Communication ciblée vers les utilisateurs mobiles |
| **Madi (IA Coach)** | Assistant IA pour recommandations de formations |

---

# 2. Application Mobile iOS (MadiniaApp)

## 2.1 Stack Technique

| Élément | Technologie |
|---------|-------------|
| **Langage** | Swift 5.9+ |
| **Framework UI** | SwiftUI |
| **Version iOS minimale** | iOS 17+ |
| **Architecture** | MVVM (Model-View-ViewModel) |
| **Concurrence** | Async/Await |
| **Gestion d'état** | @Observable (Swift 5.9+) |

**Chemin du projet:** `/Users/steeven/www/madinia/madiniamobileapp/MadiniaApp/`

## 2.2 Structure du Projet

```
MadiniaApp/
├── MadiniaApp.swift                 # Point d'entrée @main
├── AppDelegate.swift                # Push notifications & deep links
├── ContentView.swift                # Vue racine
│
├── Models/                          # Modèles de données
│   ├── Formation.swift              # Formations + FormationCategory
│   ├── Article.swift                # Articles blog + ArticleAuthor
│   ├── Service.swift                # Services
│   ├── PreRegistration.swift        # Pré-inscriptions
│   ├── LoadingState.swift           # État de chargement générique
│   └── MadiMessage.swift            # Messages du chat IA
│
├── Services/                        # Couche métier
│   ├── APIService.swift             # Client REST API (~695 lignes)
│   ├── APIError.swift               # Gestion des erreurs API
│   ├── AppDataRepository.swift      # Repository centralisé
│   ├── CacheService.swift           # Cache local JSON
│   ├── PushNotificationService.swift # Gestion APNs
│   ├── DeepLinkService.swift        # Universal links
│   ├── NavigationContext.swift      # Contexte de navigation
│   ├── ThemeManager.swift           # Mode sombre/clair
│   ├── FavoritesService.swift       # Formations sauvegardées
│   ├── PreRegistrationsService.swift # Limite 5 pré-inscriptions
│   ├── MadiService.swift            # Réponses IA coach
│   └── SecretsManager.swift         # Clé API (obfusquée)
│
├── Views/                           # Interface utilisateur
│   ├── Home/                        # Accueil + HomeViewModel
│   ├── Formations/                  # Catalogue + FormationsViewModel + PreRegistrationViewModel
│   ├── Blog/                        # Articles + BlogViewModel
│   ├── Search/                      # Recherche + SearchViewModel
│   ├── Madi/                        # Coach IA + MadiChatViewModel
│   ├── Settings/                    # Paramètres
│   ├── UserSpace/                   # Espace utilisateur
│   ├── Contact/                     # Contact + ContactViewModel
│   └── Shared/                      # Composants partagés + DesignSystem
│
├── ViewModels/                      # ViewModels partagés
│   ├── SavedFormationsViewModel.swift
│   └── MyPreRegistrationsViewModel.swift
│
└── MadiniaAppTests/                 # Tests unitaires
```

## 2.3 Modèles de Données

### Formation
**Fichier:** `Models/Formation.swift`

```swift
struct Formation: Codable, Identifiable, Hashable {
    let id: Int                      // Identifiant unique
    let title: String                // Titre de la formation
    let slug: String                 // URL-friendly slug
    let shortDescription: String?    // Description courte pour les cartes
    let duration: String             // Durée formatée (ex: "14 heures")
    let durationHours: Int?          // Durée en heures
    let level: String                // Code niveau (debutant, intermediaire, avance)
    let levelLabel: String           // Label lisible (Débutant, Intermédiaire, Avancé)
    let certification: Bool?         // Formation certifiante
    let certificationLabel: String?  // Label certification
    let imageUrl: String?            // URL de l'image
    let category: FormationCategory? // Catégorie associée

    // Champs détail uniquement (nil dans les listes)
    let description: String?         // Description complète (HTML)
    let objectives: String?          // Objectifs pédagogiques (HTML)
    let prerequisites: String?       // Prérequis (HTML)
    let program: String?             // Programme (HTML)
    let targetAudience: String?      // Public cible
    let trainingMethods: String?     // Méthodes pédagogiques
    let pdfFileUrl: String?          // URL du PDF
    let viewsCount: Int?             // Nombre de vues
    let publishedAt: String?         // Date de publication
}
```

**Impact:** Modèle central utilisé dans toutes les vues de formations, recherche, favoris et pré-inscriptions.

### FormationCategory
```swift
struct FormationCategory: Codable, Hashable, Identifiable {
    let id: Int
    let name: String                 // Nom de la catégorie
    let slug: String?                // Slug URL
    let description: String?         // Description
    let color: String?               // Couleur hex (#XXXXXX)
    let icon: String?                // Icône SF Symbols
    let formationsCount: Int?        // Nombre de formations
}
```

### Article
**Fichier:** `Models/Article.swift`

```swift
struct Article: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let slug: String
    let description: String?         // Description courte
    let category: String?            // Nom de la catégorie
    let categorySlug: String?        // Slug de la catégorie
    let readingTime: String?         // Temps de lecture (ex: "5 min")
    let tags: [String]?              // Tags associés
    let author: ArticleAuthor?       // Informations auteur
    let coverUrl: String?            // Image de couverture
    let publishedAt: String?         // Date de publication ISO8601
    let viewsCount: Int?             // Nombre de vues
    let likesCount: Int?             // Nombre de likes

    // Détail uniquement
    let content: String?             // Contenu complet (HTML)
    let heroUrl: String?             // Image héro
    let shortDescription: String?    // Description courte
}
```

### ArticleAuthor
```swift
struct ArticleAuthor: Codable, Hashable {
    let name: String                 // Nom de l'auteur
    let avatarUrl: String?           // URL de l'avatar
    let role: String?                // Rôle (ex: "Auteur")
    let bio: String?                 // Biographie
}
```

### PreRegistration
**Fichier:** `Models/PreRegistration.swift`

```swift
struct PreRegistration: Codable, Identifiable {
    let id: Int
    let firstName: String            // Prénom
    let lastName: String             // Nom
    let email: String                // Email
    let phone: String                // Téléphone
    let formationId: Int             // ID de la formation
    let fundingMethod: String        // CPF, personnel, employeur, autre
    let preferredFormat: String      // presentiel, distanciel, hybride
    let status: String               // Statut (en_attente, groupe_en_constitution, etc.)
    let source: String               // mobile, web
    let deviceUuid: String?          // UUID de l'appareil
    let createdAt: Date              // Date de création
}
```

### MadiMessage
**Fichier:** `Models/MadiMessage.swift`

```swift
struct MadiMessage: Identifiable {
    let id: UUID = UUID()
    let content: String              // Contenu du message
    let isFromUser: Bool             // true si message utilisateur
    let formationRecommendation: FormationRecommendation?  // Recommandation optionnelle
    let timestamp: Date = Date()     // Horodatage
}

struct FormationRecommendation {
    let formationId: Int
    let formationSlug: String
    let formationTitle: String
}
```

### LoadingState
**Fichier:** `Models/LoadingState.swift`

```swift
enum LoadingState<T> {
    case idle                        // État initial
    case loading                     // Chargement en cours
    case loaded(T)                   // Données chargées
    case error(String)               // Erreur avec message
}
```

**Impact:** Utilisé dans tous les ViewModels pour gérer les états de chargement de manière uniforme.

---

# 3. Référence des Méthodes et Fonctions (Mobile)

## 3.1 APIService

**Fichier:** `Services/APIService.swift`
**Responsabilité:** Client REST API pour toutes les communications avec le backend Laravel.

### Configuration

| Propriété | Valeur |
|-----------|--------|
| `baseURL` | `https://madinia.fr/api/v1` |
| `timeout` | 30 secondes |
| `maxRetries` | 3 |
| `baseRetryDelay` | 1.0 seconde (exponential backoff) |

### Méthodes Publiques

| Méthode | Signature | Rôle | Impact |
|---------|-----------|------|--------|
| `fetchFormations()` | `async throws -> [Formation]` | Récupère toutes les formations | Utilisé au lancement pour pré-charger les données |
| `fetchFormation(slug:)` | `async throws -> Formation` | Récupère une formation par slug | Affichage du détail formation |
| `fetchFormationWithRelated(slug:)` | `async throws -> (Formation, [Formation])` | Formation + formations liées | Détail avec suggestions |
| `fetchCategories()` | `async throws -> [FormationCategory]` | Liste des catégories | Filtrage et navigation |
| `fetchServices()` | `async throws -> [Service]` | Liste des services | Écran recherche |
| `fetchArticles()` | `async throws -> [Article]` | Liste des articles | Écran blog et accueil |
| `fetchArticle(slug:)` | `async throws -> Article` | Détail d'un article | Affichage contenu complet |
| `likeArticle(slug:)` | `async throws` | Like un article | Interaction utilisateur |
| `unlikeArticle(slug:)` | `async throws` | Unlike un article | Annulation like |
| `submitPreRegistration(...)` | `async throws -> PreRegistrationCreateResponse` | Soumet pré-inscription | Création pré-inscription |
| `fetchPreRegistrations(deviceUUID:)` | `async throws -> [PreRegistration]` | Mes pré-inscriptions | Espace utilisateur |
| `submitContact(...)` | `async throws` | Envoie message contact | Formulaire contact |
| `registerDeviceToken(token:preferences:)` | `async throws` | Enregistre token push | Notifications push |

### Méthodes Privées

| Méthode | Rôle |
|---------|------|
| `request<T>(endpoint:method:queryItems:)` | Requête GET générique avec retry |
| `postRequest<T,B>(endpoint:body:)` | Requête POST avec body JSON |
| `executeRequest<T>(_:)` | Exécution sans retry (utilisé en interne) |

### Stratégie de Retry

```
Tentative 1 → Échec → Attente 1s
Tentative 2 → Échec → Attente 2s
Tentative 3 → Échec → Erreur finale
```

**Erreurs retryables:** `networkError`, `timeout`, `serverError(5xx)`
**Erreurs non-retryables:** `decodingError`, `unauthorized(401)`, `notFound(404)`, `badRequest(400)`

---

## 3.2 AppDataRepository

**Fichier:** `Services/AppDataRepository.swift`
**Responsabilité:** Repository centralisé singleton pour toutes les données de l'application avec support cache.

### Propriétés Observables

| Propriété | Type | Description |
|-----------|------|-------------|
| `formations` | `[Formation]` | Toutes les formations |
| `categories` | `[FormationCategory]` | Toutes les catégories |
| `services` | `[Service]` | Tous les services |
| `articles` | `[Article]` | Tous les articles |
| `isLoading` | `Bool` | Chargement en cours |
| `isInitialized` | `Bool` | Initialisation terminée |
| `errorMessage` | `String?` | Message d'erreur |

### Propriétés Calculées

| Propriété | Type | Description |
|-----------|------|-------------|
| `hasData` | `Bool` | Au moins une donnée disponible |
| `highlightedFormations` | `[Formation]` | 3 premières formations (accueil) |
| `mostViewedFormations` | `[Formation]` | Top 5 par nombre de vues |
| `recentArticles` | `[Article]` | Articles triés par date (récent en premier) |

### Méthodes

| Méthode | Signature | Rôle | Impact |
|---------|-----------|------|--------|
| `preloadAllData()` | `@MainActor async` | Précharge toutes les données | Appelé durant le splash screen (1.5s) |
| `refresh()` | `@MainActor async` | Rafraîchit depuis l'API | Pull-to-refresh |
| `loadArticlesIfNeeded()` | `@MainActor async` | Charge articles si vide | Fallback lazy loading |
| `formation(bySlug:)` | `-> Formation?` | Recherche par slug | Navigation deep link |
| `formation(byId:)` | `-> Formation?` | Recherche par ID | Affichage détail |
| `filteredFormations(byCategory:)` | `-> [Formation]` | Filtre par catégorie | Liste filtrée |

### Flux de Données

```
┌─────────────────────────────────────────────────────────────────┐
│                     FLUX APPDATA REPOSITORY                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. init() → loadFromCache()                                     │
│     Charge données locales immédiatement                         │
│                                                                  │
│  2. SplashView → preloadAllData()                                │
│     ┌──────────────────────────────────────────────────────┐    │
│     │ async let formations = fetchFormations()              │    │
│     │ async let categories = fetchCategories()              │    │
│     │ async let services = fetchServices()                  │    │
│     │ async let articles = fetchArticles()                  │    │
│     │                                                        │    │
│     │ (Exécution parallèle)                                  │    │
│     └──────────────────────────────────────────────────────┘    │
│                          │                                       │
│                          ▼                                       │
│  3. Mise à jour des propriétés @Observable                       │
│     → Vues SwiftUI se mettent à jour automatiquement             │
│                                                                  │
│  4. Task.detached → saveToCache()                                │
│     Sauvegarde en arrière-plan                                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3.3 CacheService

**Fichier:** `Services/CacheService.swift`
**Responsabilité:** Persistance locale des données en JSON dans le répertoire cache.

### Stockage

**Répertoire:** `~/Library/Caches/MadiniaCache/`

| Fichier | Type de données |
|---------|-----------------|
| `formations.json` | `[Formation]` |
| `categories.json` | `[FormationCategory]` |
| `services.json` | `[Service]` |
| `articles.json` | `[Article]` |

### Méthodes

| Méthode | Signature | Rôle | Impact |
|---------|-----------|------|--------|
| `saveFormations(_:)` | `([Formation])` | Sauvegarde formations | Persistance locale |
| `loadFormations()` | `-> [Formation]?` | Charge formations | Démarrage rapide |
| `saveCategories(_:)` | `([FormationCategory])` | Sauvegarde catégories | Persistance locale |
| `loadCategories()` | `-> [FormationCategory]?` | Charge catégories | Démarrage rapide |
| `saveServices(_:)` | `([Service])` | Sauvegarde services | Persistance locale |
| `loadServices()` | `-> [Service]?` | Charge services | Démarrage rapide |
| `saveArticles(_:)` | `([Article])` | Sauvegarde articles | Persistance locale |
| `loadArticles()` | `-> [Article]?` | Charge articles | Démarrage rapide |
| `clearAll()` | `()` | Vide tout le cache | Réinitialisation |

**Impact global:** Permet un démarrage instantané avec les données en cache, puis mise à jour en arrière-plan.

---

## 3.4 PushNotificationService

**Fichier:** `Services/PushNotificationService.swift`
**Responsabilité:** Gestion des notifications push (permissions, tokens, préférences).

### Propriétés

| Propriété | Type | Description |
|-----------|------|-------------|
| `authorizationStatus` | `UNAuthorizationStatus` | Statut d'autorisation actuel |
| `isEnabled` | `Bool` | Notifications autorisées |
| `shouldPromptForPermission` | `Bool` | Doit afficher la demande |
| `deviceToken` | `String?` | Token APNs actuel |

### Préférences (AppStorage)

| Propriété | Clé UserDefaults | Description |
|-----------|------------------|-------------|
| `notifyNewFormations` | `notif_new_formations` | Nouvelles formations |
| `notifyNewArticles` | `notif_new_articles` | Nouveaux articles |
| `notifyReminders` | `notif_reminders` | Rappels |
| `notifyEngagement` | `notif_engagement` | Ré-engagement |

### Méthodes

| Méthode | Signature | Rôle | Impact |
|---------|-----------|------|--------|
| `checkAuthorizationStatus()` | `@MainActor async` | Vérifie le statut | Détermine si afficher prompt |
| `requestPermission()` | `@MainActor async -> Bool` | Demande permission | Affiche alerte système |
| `registerForRemoteNotifications()` | `@MainActor async` | Enregistre pour APNs | Obtient le token |
| `didRegisterForRemoteNotifications(deviceToken:)` | `(Data)` | Callback succès APNs | Convertit et enregistre token |
| `didFailToRegisterForRemoteNotifications(error:)` | `(Error)` | Callback échec APNs | Log l'erreur |
| `updatePreferences()` | `async` | Met à jour préférences | Sync avec backend |
| `openSettings()` | `()` | Ouvre paramètres iOS | Redirection utilisateur |
| `parseNotification(userInfo:)` | `-> NotificationPayload?` | Parse notification reçue | Extraction deep link |

### Structure NotificationPayload

```swift
struct NotificationPayload {
    enum ContentType: String {
        case formation    // Navigation vers formation
        case article      // Navigation vers article
        case service      // Navigation vers service
        case home         // Retour accueil
    }
    let type: ContentType
    let slug: String?
}
```

---

## 3.5 FavoritesService

**Fichier:** `Services/FavoritesService.swift`
**Responsabilité:** Gestion des formations sauvegardées (favoris) avec sync API.

### Propriétés

| Propriété | Type | Description |
|-----------|------|-------------|
| `favoriteFormationIds` | `Set<Int>` | IDs des formations favorites |
| `isSyncing` | `Bool` | Synchronisation en cours |
| `lastSyncError` | `String?` | Dernière erreur de sync |
| `deviceUUID` | `String` | UUID de l'appareil |

### Méthodes

| Méthode | Signature | Rôle | Impact |
|---------|-----------|------|--------|
| `isFavorite(formationId:)` | `-> Bool` | Vérifie si favori | Affichage icône coeur |
| `toggleFavorite(formationId:)` | `async` | Bascule favori | Action utilisateur |
| `addFavorite(formationId:)` | `async` | Ajoute aux favoris | Mise à jour locale + API |
| `removeFavorite(formationId:)` | `async` | Retire des favoris | Mise à jour locale + API |
| `syncWithServer()` | `async` | Synchronise avec serveur | Récupère état serveur |
| `fetchSavedFormations()` | `async throws -> [Formation]` | Récupère formations complètes | Écran "Mes formations" |

### Flux de Synchronisation

```
Utilisateur toggle favori
        │
        ▼
┌───────────────────┐
│ Mise à jour locale│ ← Immédiat (optimistic)
│ favoriteFormationIds │
│ saveToLocal()     │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│ API call async    │ ← En arrière-plan
│ POST/DELETE       │
└───────────────────┘
        │
    ┌───┴───┐
    ▼       ▼
 Succès   Échec
    │       │
    ▼       ▼
lastSyncError = nil  lastSyncError = message
```

---

## 3.6 PreRegistrationsService

**Fichier:** `Services/PreRegistrationsService.swift`
**Responsabilité:** Gestion des pré-inscriptions avec limite de 5 par appareil.

### Constantes

| Constante | Valeur | Description |
|-----------|--------|-------------|
| `maxPreRegistrations` | 5 | Maximum pré-inscriptions par appareil |

### Propriétés

| Propriété | Type | Description |
|-----------|------|-------------|
| `preRegistrations` | `[PreRegistration]` | Liste des pré-inscriptions |
| `preRegisteredFormationIds` | `Set<Int>` | IDs des formations pré-inscrites |
| `usedCount` | `Int` | Nombre utilisé |
| `remainingCount` | `Int` | Nombre restant (max - used) |
| `canCreateMore` | `Bool` | Peut créer plus de pré-inscriptions |

### Méthodes

| Méthode | Signature | Rôle | Impact |
|---------|-----------|------|--------|
| `getDeviceUUID()` | `-> String` | Retourne l'UUID appareil | Identification unique |
| `isPreRegistered(formationId:)` | `-> Bool` | Vérifie si déjà inscrit | Empêche doublon |
| `fetchPreRegistrations()` | `@MainActor async throws -> [PreRegistration]` | Récupère depuis API | Sync état serveur |
| `addPreRegistration(_:)` | `@MainActor (PreRegistration)` | Ajoute localement | Après succès API |
| `refresh()` | `@MainActor async` | Rafraîchit liste | Pull-to-refresh |

---

## 3.7 MadiService

**Fichier:** `Services/MadiService.swift`
**Responsabilité:** Service de chat IA local pour recommandations de formations.

### Méthodes

| Méthode | Signature | Rôle | Impact |
|---------|-----------|------|--------|
| `sendMessage(_:formations:)` | `async throws -> MadiMessage` | Envoie message à Madi | Génère réponse IA |

### Logique de Recommandation

```swift
// Mots-clés → Niveau de formation
starterKeywords = ["débuter", "commencer", "débutant", "bases", "initiation", "starter"]
performerKeywords = ["améliorer", "progresser", "intermédiaire", "approfondir", "performer"]
masterKeywords = ["expert", "avancé", "maîtriser", "master", "spécialiste"]
iaKeywords = ["ia", "intelligence artificielle", "ai", "chatgpt", "gpt", "claude"]
```

| Pattern Détecté | Formation Recommandée | Réponse Type |
|-----------------|----------------------|--------------|
| starterKeywords | Formation "Starter" | "Pour bien débuter..." |
| performerKeywords | Formation "Performer" | "Pour progresser efficacement..." |
| masterKeywords | Formation "Master" | "Pour atteindre un niveau expert..." |
| iaKeywords | Formation catégorie IA | "L'IA est un domaine passionnant..." |

### Questions Spéciales Gérées

- Différence entre packs/formations
- Questions sur les prix/tarifs
- Questions sur la durée
- Salutations (bonjour, salut)
- Remerciements

---

## 3.8 DeepLinkService

**Fichier:** `Services/DeepLinkService.swift`
**Responsabilité:** Parsing et gestion des Universal Links.

### Types de Destinations

```swift
enum DeepLinkDestination: Equatable {
    case formation(slug: String)   // /formations/{slug}
    case article(slug: String)     // /blog/{slug}
    case home                      // Fallback
}
```

### Méthodes

| Méthode | Signature | Rôle | Impact |
|---------|-----------|------|--------|
| `parse(url:)` | `-> DeepLinkDestination?` | Parse URL en destination | Navigation depuis lien externe |
| `formationURL(slug:)` | `-> URL` | Génère URL formation | Partage |
| `articleURL(slug:)` | `-> URL` | Génère URL article | Partage |

### Patterns URL Supportés

| Pattern URL | Destination |
|-------------|-------------|
| `/formations/{slug}` | `.formation(slug)` |
| `/formation/{slug}` | `.formation(slug)` |
| `/blog/{slug}` | `.article(slug)` |
| `/article/{slug}` | `.article(slug)` |
| `/articles/{slug}` | `.article(slug)` |
| Autre | `.home` |

---

## 3.9 NavigationContext

**Fichier:** `Services/NavigationContext.swift`
**Responsabilité:** Tracking du contexte de navigation pour pré-remplir le formulaire de contact.

### Propriétés

| Propriété | Type | Description |
|-----------|------|-------------|
| `currentContext` | `NavigationContextItem?` | Dernier élément consulté |
| `shouldNavigateToContact` | `Bool` | Flag navigation contact |
| `shouldNavigateToBlog` | `Bool` | Flag navigation blog |
| `shouldNavigateToSearch` | `Bool` | Flag navigation recherche |
| `shouldNavigateToEvents` | `Bool` | Flag navigation événements |

### Méthodes

| Méthode | Signature | Rôle | Impact |
|---------|-----------|------|--------|
| `setFormation(_:)` | `(Formation)` | Définit contexte formation | Pré-remplit contact |
| `setArticle(_:)` | `(Article)` | Définit contexte article | Pré-remplit contact |
| `setService(_:)` | `(Service)` | Définit contexte service | Pré-remplit contact |
| `navigateToContact(from:)` | `(Service)` | Navigation + contexte | Depuis service |
| `triggerContactNavigation()` | `()` | Déclenche navigation contact | Cross-tab |
| `triggerBlogNavigation()` | `()` | Déclenche navigation blog | Cross-tab |
| `triggerSearchNavigation()` | `()` | Déclenche navigation recherche | Cross-tab |
| `clear()` | `()` | Efface le contexte | Après soumission |
| `clearNavigationFlag()` | `()` | Reset flag contact | Après navigation |

### Propriétés Calculées

| Propriété | Description |
|-----------|-------------|
| `contextString` | String pour API ("Formation: Titre") |
| `suggestedSubject` | Sujet suggéré ("Question sur la formation") |
| `suggestedMessage` | Message pré-rempli avec titre |

---

## 3.10 APIError

**Fichier:** `Services/APIError.swift`
**Responsabilité:** Enum des erreurs API avec messages localisés en français.

### Types d'Erreurs

| Erreur | Code HTTP | Message FR | Retryable |
|--------|-----------|------------|-----------|
| `networkError(String)` | - | "Erreur de connexion..." | Oui |
| `decodingError(String)` | - | "Erreur lors du traitement..." | Non |
| `serverError(Int)` | 5xx | "Erreur serveur (code: X)..." | Oui |
| `invalidURL` | - | "URL invalide" | Non |
| `noData` | - | "Aucune donnée reçue..." | Non |
| `timeout` | - | "La requête a pris trop de temps..." | Oui |
| `unauthorized` | 401 | "Accès non autorisé" | Non |
| `notFound` | 404 | "Ressource non trouvée" | Non |
| `badRequest` | 400 | "Requête invalide" | Non |
| `forbidden` | 403 | "Accès interdit" | Non |

### Factory Methods

| Méthode | Description |
|---------|-------------|
| `from(_ urlError: URLError) -> APIError` | Convertit URLError |
| `from(statusCode: Int) -> APIError?` | Convertit code HTTP |

---

## 3.11 ViewModels

### HomeViewModel

**Fichier:** `Views/Home/HomeViewModel.swift`
**Responsabilité:** Gestion des données pour l'écran d'accueil.

| Propriété/Méthode | Type | Rôle |
|-------------------|------|------|
| `loadingState` | `LoadingState<[Formation]>` | État de chargement |
| `highlightedFormations` | `[Formation]` | 3 formations mises en avant |
| `mostViewedFormations` | `[Formation]` | Top 5 par vues |
| `allFormations` | `[Formation]` | Toutes les formations |
| `categories` | `[FormationCategory]` | Toutes les catégories |
| `recentArticles` | `[Article]` | Articles récents |
| `loadFormations()` | `@MainActor async` | Charge formations (no-op, déjà préchargé) |
| `retry()` | `@MainActor async` | Rafraîchit depuis API |

### MadiChatViewModel

**Fichier:** `Views/Madi/MadiChatViewModel.swift`
**Responsabilité:** Gestion du chat avec l'assistant IA Madi.

| Propriété/Méthode | Type | Rôle |
|-------------------|------|------|
| `messages` | `[MadiMessage]` | Historique conversation |
| `inputText` | `String` | Texte saisi |
| `isTyping` | `Bool` | Madi en train de répondre |
| `errorMessage` | `String?` | Erreur éventuelle |
| `formations` | `[Formation]` | Formations pour recommandations |
| `canSend` | `Bool` | Bouton envoi actif |
| `loadFormations()` | `@MainActor async` | Charge formations |
| `sendMessage()` | `@MainActor async` | Envoie message |
| `dismissError()` | `()` | Efface erreur |
| `resetConversation()` | `()` | Réinitialise chat |

### PreRegistrationViewModel

**Fichier:** `Views/Formations/PreRegistrationViewModel.swift`
**Responsabilité:** Gestion du formulaire de pré-inscription.

| Propriété/Méthode | Type | Rôle |
|-------------------|------|------|
| `state` | `SubmissionState` | idle, submitting, success, error |
| `firstName`, `lastName`, `email`, `phone` | `String` | Champs formulaire |
| `fundingMethod` | `FundingMethod?` | Mode de financement |
| `preferredFormat` | `PreferredFormat?` | Format préféré |
| `comments` | `String` | Commentaires |
| `canCreateMore` | `Bool` | Peut créer plus (< 5) |
| `remainingCount` | `Int` | Pré-inscriptions restantes |
| `isFormValid` | `Bool` | Formulaire valide |
| `isFirstNameValid`, `isLastNameValid`, etc. | `Bool` | Validations individuelles |
| `submit(formationId:)` | `@MainActor async` | Soumet pré-inscription |
| `reset()` | `()` | Reset état |
| `resetForm()` | `()` | Reset tous les champs |

### SearchViewModel

**Fichier:** `Views/Search/SearchViewModel.swift`
**Responsabilité:** Gestion de la recherche et du filtrage.

| Propriété/Méthode | Type | Rôle |
|-------------------|------|------|
| `searchQuery` | `String` | Texte de recherche |
| `services` | `[Service]` | Services (préchargés) |
| `formations` | `[Formation]` | Formations (préchargées) |
| `categories` | `[FormationCategory]` | Catégories (préchargées) |
| `loadingState` | `LoadingState<Void>` | État de chargement |
| `filteredServices` | `[Service]` | Services filtrés |
| `filteredFormations` | `[Formation]` | Formations filtrées |
| `filteredCategories` | `[FormationCategory]` | Catégories filtrées |
| `hasSearchResults` | `Bool` | Au moins un résultat |
| `isSearching` | `Bool` | Recherche active |
| `loadData()` | `@MainActor async` | Charge données (no-op) |
| `refresh()` | `@MainActor async` | Rafraîchit depuis API |

---

# 4. API Web (madinia_web)

## 4.1 Stack Technique

| Élément | Technologie |
|---------|-------------|
| **Framework Backend** | Laravel 12.x |
| **Langage** | PHP 8.2+ |
| **Base de données** | SQLite (dev) / PostgreSQL (prod) |
| **Frontend Web** | React 19 + Inertia.js |
| **Admin Panel** | Filament 3.x |
| **CSS** | Tailwind CSS 4.x |
| **Build Tool** | Vite |

**Chemin du projet:** `/Users/steeven/www/madinia/madinia_web/`

## 4.2 Structure du Projet

```
madinia_web/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── HomeController.php
│   │   │   ├── FormationsController.php
│   │   │   ├── BlogController.php
│   │   │   ├── ServicesController.php
│   │   │   ├── ContactController.php
│   │   │   ├── PreinscriptionFormationController.php
│   │   │   └── Api/V1/
│   │   │       ├── FormationController.php
│   │   │       ├── CategoryController.php
│   │   │       ├── ArticleController.php
│   │   │       ├── ServiceController.php
│   │   │       ├── DeviceController.php
│   │   │       ├── PreinscriptionController.php
│   │   │       ├── FavoriteController.php
│   │   │       ├── ContactController.php
│   │   │       ├── NotificationController.php
│   │   │       ├── N8nNotificationController.php
│   │   │       └── SystemeIoWebhookController.php
│   │   │
│   │   └── Middleware/
│   │       ├── VerifyApiKey.php
│   │       ├── VerifyN8nApiKey.php
│   │       └── HandleInertiaRequests.php
│   │
│   ├── Models/
│   │   ├── User.php
│   │   ├── Formation.php
│   │   ├── FormationCategory.php
│   │   ├── Pack.php
│   │   ├── Service.php
│   │   ├── DeviceToken.php
│   │   ├── NotificationLog.php
│   │   ├── NotificationDelivery.php
│   │   ├── PreinscriptionFormation.php
│   │   ├── ContactMessage.php
│   │   ├── Favorite.php
│   │   └── Blog/ (Post, Author, Category)
│   │
│   ├── Services/
│   │   ├── PushNotificationService.php
│   │   ├── SystemeIoService.php
│   │   ├── FormationService.php
│   │   └── PackService.php
│   │
│   ├── Jobs/
│   │   ├── SendBroadcastNotification.php
│   │   ├── SendPreRegistrationReminder.php
│   │   ├── SendSessionReminder.php
│   │   ├── SendEngagementReminder.php
│   │   └── CleanupInvalidDeviceTokens.php
│   │
│   └── Enums/
│       ├── StatutPreinscription.php
│       ├── FormatFormation.php
│       └── MoyenFinancement.php
│
├── routes/
│   ├── api.php                     # Routes API mobile
│   └── web.php                     # Routes frontend web
│
└── database/
    └── migrations/                 # 49 fichiers migration
```

## 4.3 Routes API Mobile (v1)

**Middleware:** `VerifyApiKey` (X-API-Key header)

### Formations & Catégories

| Méthode | Route | Throttle | Description |
|---------|-------|----------|-------------|
| GET | `/api/v1/categories` | 60/min | Liste des catégories |
| GET | `/api/v1/categories/{slug}` | 60/min | Détail catégorie |
| GET | `/api/v1/formations` | 60/min | Liste des formations |
| GET | `/api/v1/formations/{slug}` | 60/min | Détail formation |

### Articles

| Méthode | Route | Throttle | Description |
|---------|-------|----------|-------------|
| GET | `/api/v1/articles` | 60/min | Liste des articles |
| GET | `/api/v1/articles/{slug}` | 60/min | Détail article |
| POST | `/api/v1/articles/{slug}/like` | 60/min | Liker un article |
| POST | `/api/v1/articles/{slug}/unlike` | 60/min | Unliker un article |

### Services

| Méthode | Route | Throttle | Description |
|---------|-------|----------|-------------|
| GET | `/api/v1/services` | 60/min | Liste des services |
| GET | `/api/v1/services/{slug}` | 60/min | Détail service |

### Pré-inscriptions

| Méthode | Route | Throttle | Description |
|---------|-------|----------|-------------|
| POST | `/api/v1/pre-registrations` | **10/min** | Créer pré-inscription |
| GET | `/api/v1/pre-registrations` | 60/min | Mes pré-inscriptions |
| GET | `/api/v1/pre-registrations/{id}` | 60/min | Détail pré-inscription |

### Appareils (Push Notifications)

| Méthode | Route | Throttle | Description |
|---------|-------|----------|-------------|
| POST | `/api/v1/devices` | **30/min** | Enregistrer token |
| PUT | `/api/v1/devices/{token}/preferences` | 30/min | Mettre à jour préférences |
| DELETE | `/api/v1/devices/{token}` | 10/min | Supprimer token |

### Favoris

| Méthode | Route | Throttle | Description |
|---------|-------|----------|-------------|
| GET | `/api/v1/favorites` | 60/min | Liste des IDs favoris |
| GET | `/api/v1/favorites/formations` | 60/min | Formations favorites (détails) |
| POST | `/api/v1/favorites` | 60/min | Ajouter favori |
| DELETE | `/api/v1/favorites/{formationId}` | 60/min | Retirer favori |

### Contact

| Méthode | Route | Throttle | Description |
|---------|-------|----------|-------------|
| POST | `/api/v1/contact` | **10/min** | Envoyer message |

## 4.4 Services Backend

### PushNotificationService

**Fichier:** `app/Services/PushNotificationService.php`
**Intégration:** APNs HTTP/2 direct

| Méthode | Description |
|---------|-------------|
| `send(DeviceToken, title, body, data)` | Envoie notification à un appareil |
| `sendToAll(type, title, body)` | Broadcast à tous les appareils |
| `notifyNewFormation(title, slug)` | Notification nouvelle formation |
| `notifyNewArticle(title, slug)` | Notification nouvel article |
| `sendPreRegistrationReminder(...)` | Rappel pré-inscription |
| `sendSessionReminder(...)` | Rappel session |
| `sendEngagementReminder(...)` | Notification ré-engagement |

### SystemeIoService

**Fichier:** `app/Services/SystemeIoService.php`

| Méthode | Description |
|---------|-------------|
| `fetchCourses()` | Récupère cours Systeme.io |
| `syncCourses()` | Synchronise cours → Packs |
| `fetchContacts(...)` | Récupère contacts |
| `syncContacts(tagId)` | Synchronise contacts |
| `fetchTags()` | Récupère tags |
| `syncTags()` | Synchronise tags |
| `createEnrollment(courseId, contactId)` | Crée inscription |
| `syncAll()` | Synchronisation complète |

---

# 5. Intégration Mobile ↔ API

## 5.1 Flux d'Authentification

```
┌─────────────────┐                    ┌─────────────────┐
│   iOS App       │                    │   Laravel API   │
│                 │                    │                 │
│  ┌───────────┐  │    X-API-Key       │  ┌───────────┐  │
│  │APIService │──┼───────────────────►│  │VerifyApi  │  │
│  │           │  │                    │  │   Key     │  │
│  └───────────┘  │                    │  └───────────┘  │
│                 │                    │        │        │
│  ┌───────────┐  │    device_uuid     │        ▼        │
│  │Secrets    │  │    (body/query)    │  ┌───────────┐  │
│  │Manager    │  │◄──────────────────►│  │Controller │  │
│  └───────────┘  │                    │  └───────────┘  │
└─────────────────┘                    └─────────────────┘
```

## 5.2 Flux de Pré-inscription

```
1. Vérification limite (local)
   PreRegistrationsService.canCreateMore → max 5

2. Affichage formulaire
   PreRegistrationViewModel valide champs

3. Soumission API
   POST /api/v1/pre-registrations
   {
     "first_name": "Jean",
     "last_name": "Dupont",
     "email": "jean@example.com",
     "phone": "0612345678",
     "formation_id": 5,
     "funding_method": "cpf",
     "preferred_format": "distanciel",
     "device_uuid": "ABC123..."
   }

4. Réponse API
   {
     "success": true,
     "data": { ... },
     "remaining": 4,
     "total": 5
   }

5. Actions backend
   - Email confirmation utilisateur
   - Email notification admin
```

## 5.3 Flux Push Notifications

```
ENREGISTREMENT DU TOKEN
────────────────────────

iOS App                          Laravel
┌─────────────┐  APNs Token      ┌─────────────┐
│UNUserNotif- │────────────────► │DeviceToken  │
│icationCenter│                  │  Model      │
└─────────────┘                  └─────────────┘
      │
      ▼
POST /api/v1/devices
{
  "device_uuid": "...",
  "device_token": "APNs token...",
  "platform": "ios",
  "environment": "production",
  "app_version": "1.2.0",
  "preferences": {
    "new_formations": true,
    "new_articles": true,
    "reminders": true,
    "engagement": true
  }
}

ENVOI DE NOTIFICATION
─────────────────────

n8n Workflow ──► /api/v1/n8n/notifications/send-broadcast
      │                  │
      │                  ▼
      │         SendBroadcastNotification (Job)
      │                  │
      │                  ▼
      │         PushNotificationService
      │                  │
      │                  ▼
      │              APNs HTTP/2
      │                  │
      │                  ▼
      └──────────────► iOS Device
```

---

# 6. Services Externes

## 6.1 Apple Push Notification Service (APNs)

| Variable | Description |
|----------|-------------|
| `APN_KEY_ID` | ID de la clé dans Apple Developer |
| `APN_TEAM_ID` | ID de l'équipe Apple |
| `APN_BUNDLE_ID` | Bundle ID de l'app (fr.madinia.app) |
| `APN_PRIVATE_KEY_BASE64` | Clé .p8 encodée base64 |
| `APN_PRODUCTION` | true pour production |

## 6.2 Systeme.io

| Variable | Description |
|----------|-------------|
| `SYSTEME_IO_API_KEY` | Clé API Systeme.io |
| `SYSTEME_IO_API_URL` | `https://api.systeme.io/api` |

**Webhooks écoutés:**
- `contact.created`
- `contact.tagged`
- `contact.untagged`
- `enrollment.created`

## 6.3 Supabase Storage

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | URL du projet |
| `SUPABASE_KEY` | Clé publique |
| `SUPABASE_SECRET` | Clé secrète |

**Buckets:** formations, blog, services

## 6.4 n8n (Orchestration)

| Variable | Description |
|----------|-------------|
| `N8N_API_KEY` | Clé pour authentifier n8n |

**Workflows:** Notifications nouvelles formations/articles, rappels, ré-engagement

---

# 7. Sécurité

## 7.1 Authentification

### Application Mobile
- **Méthode:** API Key statique
- **Header:** `X-API-Key: <key>`
- **Stockage:** Obfusqué dans `SecretsManager`

### n8n Workflows
- **Méthode:** API Key dédiée
- **Header:** `X-N8N-API-Key: <key>`

### Panel Admin (Filament)
- **Méthode:** Email + Password
- **2FA:** Activé
- **Restriction:** Emails `@madinia.fr` uniquement

## 7.2 Rate Limiting

| Endpoint | Limite |
|----------|--------|
| API générale | 60 req/min |
| Pré-inscription | 10 req/min |
| Enregistrement device | 30 req/min |
| Contact | 10 req/min |
| n8n | 120 req/min |
| Webhooks Systeme.io | 100 req/min |

## 7.3 Validation des Données

### Mobile (Swift)

```swift
// EmailValidator
static func isValid(_ email: String) -> Bool {
    let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
}

// Phone validation
phone.count >= 8
```

### Backend (Laravel)

```php
$request->validate([
    'first_name' => 'required|string|max:255',
    'last_name' => 'required|string|max:255',
    'email' => 'required|email|max:255',
    'phone' => 'required|string|max:20',
    'formation_id' => 'required|exists:formations,id',
    'funding_method' => 'required|in:cpf,opco,france_travail,autofinancement,autre',
    'preferred_format' => 'required|in:presentiel,distanciel,hybride',
    'device_uuid' => 'required|string|max:255',
]);
```

---

# 8. Annexes

## 8.1 Variables d'Environnement

### Laravel (.env)

```env
# Application
APP_NAME=Madinia
APP_ENV=production
APP_URL=https://madinia.fr

# Base de données
DB_CONNECTION=pgsql
DB_HOST=localhost
DB_DATABASE=madinia

# API Keys
API_MOBILE_KEY=<64+ caractères>
N8N_API_KEY=<64+ caractères>

# APNs
APN_KEY_ID=***
APN_TEAM_ID=***
APN_BUNDLE_ID=fr.madinia.app
APN_PRIVATE_KEY_BASE64=***
APN_PRODUCTION=true

# Systeme.io
SYSTEME_IO_API_KEY=***

# Supabase
SUPABASE_URL=https://***.supabase.co
SUPABASE_KEY=***

# Mail
MAIL_MAILER=resend
RESEND_API_KEY=***

# Queue
QUEUE_CONNECTION=database
```

## 8.2 Commandes Artisan Utiles

```bash
# Synchronisation Systeme.io
php artisan systeme:sync-all
php artisan systeme:sync-courses
php artisan systeme:sync-contacts

# Notifications
php artisan notifications:process-scheduled
php artisan notifications:cleanup-tokens

# Cache
php artisan cache:clear
php artisan config:cache

# Queue
php artisan queue:work
```

## 8.3 Structure des Réponses API

### Succès

```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "current_page": 1,
    "total": 50,
    "per_page": 15
  }
}
```

### Erreur

```json
{
  "success": false,
  "message": "Message d'erreur lisible",
  "errors": {
    "email": ["Le champ email est obligatoire"]
  }
}
```

## 8.4 Codes d'Erreur HTTP

| Code | Signification | Action Mobile |
|------|---------------|---------------|
| 200 | Succès | Traiter données |
| 201 | Créé | Traiter données |
| 400 | Requête invalide | Afficher erreur |
| 401 | Non autorisé | Vérifier clé API |
| 403 | Interdit | Afficher erreur |
| 404 | Non trouvé | Afficher erreur |
| 422 | Validation échouée | Afficher erreurs champs |
| 429 | Trop de requêtes | Attendre et réessayer |
| 500 | Erreur serveur | Réessayer (3x max) |
| 503 | Service indisponible | Réessayer avec backoff |

## 8.5 Tests

### Mobile (XCTest)

```
MadiniaAppTests/
├── APIServiceTests.swift
├── HomeViewModelTests.swift
├── FormationsViewModelTests.swift
├── ProgressPathTests.swift
├── MainTabViewTests.swift
└── FormationTests.swift
```

### Laravel (PHPUnit)

```bash
php artisan test
php artisan test --filter=FormationTest
php artisan test --coverage
```

---

**Document généré le 2026-02-03**
**Version de l'écosystème: MadiniaApp iOS + madinia_web Laravel 12**
