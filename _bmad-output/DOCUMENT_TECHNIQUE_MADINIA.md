# Document Technique - Madinia Mobile & API

**Version:** 1.0
**Date:** 2 février 2026
**Projet:** Plateforme Madinia - Application Mobile iOS & API Backend

---

## Table des matières

1. [Vue d'ensemble](#1-vue-densemble)
2. [Architecture Globale](#2-architecture-globale)
3. [Application Mobile iOS](#3-application-mobile-ios)
4. [API Backend](#4-api-backend)
5. [Authentification & Sécurité](#5-authentification--sécurité)
6. [Notifications Push](#6-notifications-push)
7. [Intégrations Tierces](#7-intégrations-tierces)
8. [Modèles de Données](#8-modèles-de-données)
9. [Endpoints API](#9-endpoints-api)
10. [Diagrammes](#10-diagrammes)

---

## 1. Vue d'ensemble

### 1.1 Description du projet

Madinia est une plateforme de formation professionnelle spécialisée dans l'Intelligence Artificielle. Le système comprend :

- **Application Mobile iOS** : Application native SwiftUI pour iPhone/iPad
- **API REST** : Backend Laravel 12 fournissant les données et services
- **Système de notifications** : Push notifications via APNs orchestrées par n8n
- **CRM** : Intégration Systeme.io pour la gestion des contacts

### 1.2 Stack Technologique

| Composant | Technologie | Version |
|-----------|-------------|---------|
| Mobile iOS | Swift / SwiftUI | iOS 17+ |
| Backend | Laravel | 12.x |
| Base de données | PostgreSQL / SQLite | - |
| Notifications | APNs + n8n | 2.4.4 |
| Stockage fichiers | Supabase | - |
| Email | Resend | - |
| CRM | Systeme.io | - |

---

## 2. Architecture Globale

```
┌─────────────────────────────────────────────────────────────────┐
│                        UTILISATEURS                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    APPLICATION iOS                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │   SwiftUI   │  │  ViewModels │  │       Services          │  │
│  │    Views    │◄─┤   (MVVM)    │◄─┤  APIService, Cache...   │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTPS (API Key)
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API LARAVEL                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │ Controllers │  │   Services  │  │        Models           │  │
│  │   (API/V1)  │──┤  (Business) │──┤      (Eloquent)         │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
          │                   │                    │
          ▼                   ▼                    ▼
    ┌──────────┐       ┌──────────┐         ┌──────────┐
    │PostgreSQL│       │   APNs   │         │Systeme.io│
    │   (DB)   │       │  (Push)  │         │  (CRM)   │
    └──────────┘       └──────────┘         └──────────┘
                           ▲
                           │
                    ┌──────────┐
                    │   n8n    │
                    │(Orchestr)│
                    └──────────┘
```

---

## 3. Application Mobile iOS

### 3.1 Architecture MVVM

L'application suit le pattern **MVVM** (Model-View-ViewModel) avec SwiftUI :

```
MadiniaApp/
├── MadiniaApp.swift          # Point d'entrée (@main)
├── AppDelegate.swift         # Gestion Push Notifications
├── ContentView.swift         # Vue racine
├── Models/
│   ├── Formation.swift       # Modèle Formation
│   ├── Article.swift         # Modèle Article
│   ├── Service.swift         # Modèle Service
│   ├── PreRegistration.swift # Modèle Pré-inscription
│   └── LoadingState.swift    # États de chargement
├── Views/
│   ├── Home/                 # Écran d'accueil
│   ├── Formations/           # Catalogue formations
│   ├── Blog/                 # Articles blog
│   ├── Search/               # Recherche
│   ├── UserSpace/            # Espace utilisateur
│   ├── Contact/              # Formulaires contact
│   ├── Settings/             # Paramètres
│   ├── Madi/                 # Assistant IA (Madi)
│   └── Shared/               # Composants partagés
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── FormationsViewModel.swift
│   ├── BlogViewModel.swift
│   └── ...
└── Services/
    ├── APIService.swift      # Client HTTP
    ├── CacheService.swift    # Cache local
    ├── FavoritesService.swift
    ├── PushNotificationService.swift
    ├── DeepLinkService.swift
    └── ThemeManager.swift
```

### 3.2 Navigation

L'application utilise une **TabView personnalisée** avec 4 onglets principaux :

| Onglet | Nom | Description |
|--------|-----|-------------|
| 0 | Accueil | Dashboard avec formations mises en avant |
| 1 | Madin.IA | Hub avec blog, contact, calendrier |
| 2 | L'IA&Vous | Espace personnel (favoris, pré-inscriptions) |
| 3 | Recherche | Recherche formations et services |

**Adaptations iPad** : Layout avec NavigationSplitView (sidebar)

### 3.3 Design System

```swift
// Couleurs
MadiniaColors.accent      // Violet principal
MadiniaColors.background  // Fond adaptatif
MadiniaColors.surface     // Surfaces cartes

// Typographie
MadiniaTypography.title   // Titres
MadiniaTypography.body    // Corps de texte
MadiniaTypography.caption // Légendes

// Espacements
MadiniaSpacing.xs  // 4pt
MadiniaSpacing.sm  // 8pt
MadiniaSpacing.md  // 16pt
MadiniaSpacing.lg  // 24pt
MadiniaSpacing.xl  // 32pt
```

### 3.4 Service API (Client HTTP)

```swift
final class APIService: APIServiceProtocol {
    private let baseURL = "https://madinia.fr/api/v1"
    private let maxRetries = 3
    private let baseRetryDelay: TimeInterval = 1.0

    // Méthodes principales
    func fetchFormations() async throws -> [Formation]
    func fetchFormation(slug: String) async throws -> Formation
    func fetchCategories() async throws -> [FormationCategory]
    func fetchServices() async throws -> [Service]
    func fetchArticles() async throws -> [Article]
    func submitPreRegistration(...) async throws -> PreRegistrationCreateResponse
    func submitContact(...) async throws
    func registerDeviceToken(token: String, preferences: NotificationPreferences) async throws
}
```

**Caractéristiques :**
- Authentification via header `X-API-Key`
- Retry automatique avec backoff exponentiel (1s, 2s, 4s)
- Timeout de 30 secondes
- Décodage JSON ISO8601

### 3.5 Deep Links & Universal Links

L'application supporte les liens profonds pour :
- **Formations** : `madinia://formation/{slug}` ou `https://madinia.fr/formations/{slug}`
- **Articles** : `madinia://article/{slug}` ou `https://madinia.fr/blog/{slug}`
- **Services** : `madinia://service/{slug}`

---

## 4. API Backend

### 4.1 Architecture Laravel

```
madinia_web/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   └── Api/V1/
│   │   │       ├── FormationController.php
│   │   │       ├── ArticleController.php
│   │   │       ├── PreinscriptionController.php
│   │   │       ├── DeviceController.php
│   │   │       ├── FavoriteController.php
│   │   │       ├── ContactController.php
│   │   │       └── N8nNotificationController.php
│   │   └── Middleware/
│   │       ├── VerifyApiKey.php
│   │       └── VerifyN8nApiKey.php
│   ├── Models/
│   │   ├── Formation.php
│   │   ├── PreinscriptionFormation.php
│   │   ├── DeviceToken.php
│   │   ├── NotificationLog.php
│   │   ├── UserFavorite.php
│   │   └── Blog/Post.php
│   └── Services/
│       ├── PushNotificationService.php
│       ├── FormationService.php
│       ├── FavoriteService.php
│       └── SystemeIoService.php
├── routes/
│   └── api.php
└── config/
    └── services.php
```

### 4.2 Groupes de Routes

| Préfixe | Middleware | Rate Limit | Usage |
|---------|------------|------------|-------|
| `/api/v1` | `VerifyApiKey` | 60 req/min | App mobile |
| `/api/v1/n8n` | `VerifyN8nApiKey` | 120 req/min | Workflows n8n |
| `/webhooks/systeme-io` | Aucun | 100 req/min | Webhooks CRM |

---

## 5. Authentification & Sécurité

### 5.1 API Mobile (X-API-Key)

```php
// Middleware VerifyApiKey
class VerifyApiKey
{
    public function handle($request, $next)
    {
        $apiKey = $request->header('X-API-Key')
                  ?? str_replace('Bearer ', '', $request->header('Authorization'));

        if (!hash_equals(config('services.api.mobile_key'), $apiKey)) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        return $next($request);
    }
}
```

### 5.2 API n8n (X-N8N-API-Key)

Authentification séparée pour les workflows d'orchestration avec logging des accès.

### 5.3 Sécurité Mobile

- **API Key** stockée via `SecretsManager` (obfuscation)
- **Device UUID** (`identifierForVendor`) pour identification unique
- **Environnement** sandbox/production automatique selon build

---

## 6. Notifications Push

### 6.1 Architecture

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Laravel    │────▶│     APNs     │────▶│  iPhone/iPad │
│ PushService  │     │    (Apple)   │     │              │
└──────────────┘     └──────────────┘     └──────────────┘
       ▲
       │
┌──────────────┐
│     n8n      │
│  Workflows   │
└──────────────┘
```

### 6.2 Types de notifications

| Type | Description | Préférence |
|------|-------------|------------|
| `formation` | Nouvelle formation publiée | `new_formations` |
| `article` | Nouvel article blog | `new_articles` |
| `reminder` | Rappel pré-inscription/session | `reminders` |
| `engagement` | Ré-engagement utilisateurs inactifs | `engagement` |

### 6.3 Préférences utilisateur

```swift
struct NotificationPreferences: Encodable {
    let newFormations: Bool    // Nouvelles formations
    let newArticles: Bool      // Nouveaux articles
    let reminders: Bool        // Rappels
    let engagement: Bool       // Ré-engagement
}
```

### 6.4 Gestion des tokens (Backend)

```php
// Modèle DeviceToken
class DeviceToken extends Model
{
    protected $fillable = [
        'device_uuid',
        'token',
        'platform',           // ios/android
        'environment',        // sandbox/production
        'app_version',
        'preferences',        // JSON
        'email',
        'last_used_at',
        'last_engagement_at',
        'error_count',
        'is_valid',
        'last_error_reason'
    ];

    // Scopes
    public function scopeActive($query)    // Actifs (30 jours)
    public function scopeValid($query)     // Sans erreurs
    public function scopeIos($query)       // Plateforme iOS
}
```

---

## 7. Intégrations Tierces

### 7.1 n8n (Orchestration)

**Workflows disponibles :**

1. **Nouvelles Formations** : Détecte et notifie les nouvelles publications
2. **Nouveaux Articles** : Alerte blog automatique
3. **Rappels Sessions** : Rappels J-7, J-1 pour sessions planifiées
4. **Ré-engagement** : Cible utilisateurs inactifs (14+ jours)
5. **Webhooks Systeme.io** : Synchronisation CRM

**Endpoints n8n :**

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/n8n/notifications/send-broadcast` | POST | Diffusion à tous |
| `/n8n/notifications/send-targeted` | POST | Envoi ciblé |
| `/n8n/notifications/send-formation` | POST | Notif formation |
| `/n8n/notifications/send-article` | POST | Notif article |
| `/n8n/notifications/send-reminder` | POST | Rappels |
| `/n8n/notifications/send-engagement` | POST | Ré-engagement |
| `/n8n/stats` | GET | Statistiques |

### 7.2 Systeme.io (CRM)

**Webhooks reçus :**

- `contact-created` : Nouveau contact
- `contact-tagged` : Ajout de tag
- `contact-untagged` : Retrait de tag
- `enrollment-created` : Inscription formation

### 7.3 Supabase (Stockage)

Utilisé pour le stockage des images (formations, articles) via `SupabaseHelper`.

### 7.4 Calendly

Intégré dans l'app mobile via WebView pour la prise de rendez-vous.

---

## 8. Modèles de Données

### 8.1 Formation

```swift
// iOS
struct Formation: Codable, Identifiable {
    let id: Int
    let title: String
    let slug: String
    let shortDescription: String?
    let duration: String
    let durationHours: Int?
    let level: String              // debutant, intermediaire, avance
    let levelLabel: String
    let certification: Bool?
    let certificationLabel: String?
    let imageUrl: String?
    let category: FormationCategory?

    // Détail uniquement
    let description: String?       // HTML
    let objectives: String?        // HTML
    let prerequisites: String?     // HTML
    let program: String?           // HTML
    let targetAudience: String?
    let trainingMethods: String?
    let pdfFileUrl: String?
    let viewsCount: Int?
    let publishedAt: String?
}
```

### 8.2 PreinscriptionFormation

```php
// Laravel
class PreinscriptionFormation extends Model
{
    protected $fillable = [
        'prenom',
        'nom',
        'email',
        'telephone',
        'formation_id',
        'moyen_financement',      // cpf, opco, france_travail, autofinancement, autre
        'format_preference',       // presentiel, distanciel, hybride
        'commentaires',
        'statut',                  // en_attente, groupe_en_constitution, session_planifiee, inscrit, annule
        'date_session_planifiee',
        'device_uuid',
        'source'
    ];

    use SoftDeletes;
}
```

### 8.3 Article

```swift
// iOS
struct Article: Codable, Identifiable {
    let id: Int
    let title: String
    let slug: String
    let description: String?
    let category: String?
    let categorySlug: String?
    let readingTime: String?
    let tags: [String]?
    let author: ArticleAuthor?
    let coverUrl: String?
    let publishedAt: String?
    let viewsCount: Int?
    let likesCount: Int?

    // Détail uniquement
    let content: String?           // HTML
    let heroUrl: String?
}
```

### 8.4 DeviceToken

```php
// Laravel
class DeviceToken extends Model
{
    protected $casts = [
        'preferences' => 'array',
        'is_valid' => 'boolean',
        'last_used_at' => 'datetime',
        'last_engagement_at' => 'datetime',
        'last_error_at' => 'datetime'
    ];
}
```

---

## 9. Endpoints API

### 9.1 API Mobile (v1)

#### Formations

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/formations` | Liste des formations publiées |
| GET | `/formations/{slug}` | Détail formation + related |
| GET | `/formations/category/{slug}` | Formations par catégorie |

#### Catégories

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/categories` | Liste des catégories |
| GET | `/categories/{slug}` | Détail catégorie |

#### Articles

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/articles` | Liste des articles publiés |
| GET | `/articles/{slug}` | Détail article + related |
| POST | `/articles/{slug}/like` | Liker un article |
| POST | `/articles/{slug}/unlike` | Unliker un article |

#### Services

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/services` | Liste des services |
| GET | `/services/{slug}` | Détail service |

#### Pré-inscriptions

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/pre-registrations` | Liste (filtre: device_uuid) |
| GET | `/pre-registrations/{id}` | Détail |
| POST | `/preinscription` | Créer (rate limit: 10/min) |

**Limites :** Max 5 pré-inscriptions par device, pas de doublons.

#### Favoris

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/favorites` | IDs des formations favorites |
| GET | `/favorites/formations` | Formations favorites complètes |
| POST | `/favorites` | Ajouter favori |
| DELETE | `/favorites/{formationId}` | Retirer favori |

#### Devices (Push)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/devices` | Enregistrer/MAJ token |
| PUT | `/devices/{token}/preferences` | MAJ préférences |
| DELETE | `/devices/{token}` | Désinscription |

#### Contact

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/contact` | Envoyer message (rate limit: 10/min) |

### 9.2 Formats de réponse

#### Succès (liste)
```json
{
    "success": true,
    "data": [...]
}
```

#### Succès (détail)
```json
{
    "success": true,
    "data": {...},
    "related": [...]
}
```

#### Erreur
```json
{
    "success": false,
    "message": "Description de l'erreur",
    "errors": {...}
}
```

---

## 10. Diagrammes

### 10.1 Flux de pré-inscription

```
┌──────────┐    ┌───────────────┐    ┌──────────┐    ┌───────────┐
│  Mobile  │───▶│ POST /preinsc │───▶│  Laravel │───▶│ PostgreSQL│
│   App    │    │               │    │ Validate │    │   Save    │
└──────────┘    └───────────────┘    └──────────┘    └───────────┘
                                           │
                                           ▼
                                    ┌──────────────┐
                                    │ Email Confirm│
                                    │   (Resend)   │
                                    └──────────────┘
```

### 10.2 Flux de notification push

```
┌──────────┐    ┌───────────────┐    ┌──────────┐    ┌───────────┐
│   n8n    │───▶│POST /n8n/send │───▶│  Laravel │───▶│   APNs    │
│ Workflow │    │   -broadcast  │    │PushServce│    │  (Apple)  │
└──────────┘    └───────────────┘    └──────────┘    └───────────┘
                                                           │
                                                           ▼
                                                    ┌───────────┐
                                                    │  iPhone   │
                                                    │   App     │
                                                    └───────────┘
```

### 10.3 Cycle de vie du token device

```
┌─────────────────────────────────────────────────────────────────┐
│                    ENREGISTREMENT TOKEN                          │
├─────────────────────────────────────────────────────────────────┤
│  1. App demande permission notifications                         │
│  2. APNs retourne device token                                   │
│  3. App envoie POST /devices avec token + préférences           │
│  4. Backend stocke/met à jour DeviceToken                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    ENVOI NOTIFICATION                            │
├─────────────────────────────────────────────────────────────────┤
│  1. n8n déclenche workflow (nouvelle formation, article, etc.)  │
│  2. Appel API /n8n/notifications/send-*                         │
│  3. PushNotificationService construit payload APNs              │
│  4. Envoi à APNs avec JWT authentication                        │
│  5. Log résultat dans notification_logs                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    GESTION ERREURS                               │
├─────────────────────────────────────────────────────────────────┤
│  - BadDeviceToken → marquer is_valid = false                    │
│  - Unregistered → soft delete token                             │
│  - ExpiredToken → invalider et notifier                         │
│  - Autres → incrémenter error_count                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## Annexes

### A. Variables d'environnement requises

```env
# API Keys
API_MOBILE_KEY=xxx
N8N_API_KEY=xxx

# APNs
APNS_KEY_ID=xxx
APNS_TEAM_ID=xxx
APNS_BUNDLE_ID=fr.madinia.app
APNS_KEY_PATH=/path/to/AuthKey.p8

# Systeme.io
SYSTEME_IO_API_KEY=xxx

# Database
DB_CONNECTION=pgsql
DB_HOST=xxx
DB_DATABASE=madinia

# Email
RESEND_API_KEY=xxx
```

### B. Dépendances iOS (Package.swift)

L'application utilise uniquement les frameworks Apple natifs :
- SwiftUI
- SwiftData
- UserNotifications
- Foundation

### C. Versioning API

L'API utilise un versioning par préfixe URL (`/api/v1`). Les futures versions seront accessibles via `/api/v2`, etc.

---

**Document rédigé par BMad Master pour Madinia**
*Dernière mise à jour : 2 février 2026*
