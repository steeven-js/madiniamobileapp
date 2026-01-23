---
stepsCompleted: [1, 2, 3, 4]
workflow_completed: true
completed_date: '2026-01-23'
inputDocuments:
  - "_bmad-output/planning-artifacts/prd.md"
  - "_bmad-output/planning-artifacts/architecture.md"
  - "_bmad-output/planning-artifacts/ux-design-specification.md"
date: 2026-01-23
author: Steeven
project_name: "Madinia Mobile"
---

# Madinia Mobile - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for Madinia Mobile, decomposing the requirements from the PRD, UX Design, and Architecture into implementable stories.

## Requirements Inventory

### Functional Requirements

**Navigation & Découverte (FR1-FR4):**
- FR1: L'utilisateur peut naviguer entre 4 onglets principaux (Accueil, Formations, Blog, Contact)
- FR2: L'utilisateur peut explorer l'app sans créer de compte
- FR3: L'utilisateur peut voir un écran d'accueil avec highlights et accès rapides
- FR4: L'utilisateur peut voir le parcours visuel Starter→Performer→Master

**Catalogue Formations (FR5-FR9):**
- FR5: L'utilisateur peut voir la liste des formations disponibles
- FR6: L'utilisateur peut voir les infos clés d'une formation (Durée, Niveau, Prix, Prochaine session) en moins de 5 secondes
- FR7: L'utilisateur peut consulter le détail complet d'une formation
- FR8: L'utilisateur peut comprendre la progression entre les packs (Starter→Performer→Master)
- FR9: L'utilisateur peut voir les formations par catégorie/objectif

**Pré-inscription (FR10-FR13):**
- FR10: L'utilisateur peut se pré-inscrire à une formation en 2 taps maximum
- FR11: L'utilisateur peut fournir son email pour la pré-inscription
- FR12: L'utilisateur reçoit une confirmation après pré-inscription
- FR13: Le système envoie la pré-inscription à Madinia (API/email)

**Blog & Contenu (FR14-FR17):**
- FR14: L'utilisateur peut voir le feed des articles de blog
- FR15: L'utilisateur peut lire un article complet
- FR16: L'utilisateur peut voir le CTA vers la formation liée à la fin d'un article
- FR17: L'utilisateur peut naviguer du blog vers une fiche formation

**Contact (FR18-FR21):**
- FR18: L'utilisateur peut envoyer un message de contact à Madinia
- FR19: Le formulaire de contact se pré-remplit avec le contexte de navigation (formation consultée)
- FR20: L'utilisateur reçoit une confirmation d'envoi du message
- FR21: Le système transmet le message avec contexte à Madinia

**Madi Coach IA (FR22-FR27):**
- FR22: L'utilisateur peut activer/désactiver Madi (coach IA)
- FR23: L'utilisateur peut poser des questions à Madi sur les formations
- FR24: Madi peut recommander une formation basée sur les objectifs de l'utilisateur
- FR25: Madi peut expliquer les différences entre les packs
- FR26: L'utilisateur peut naviguer vers une formation recommandée par Madi
- FR27: Madi reste non-intrusif (jamais de pop-up imposé)

**Push Notifications (FR28-FR32):**
- FR28: L'utilisateur peut autoriser/refuser les notifications push
- FR29: L'utilisateur reçoit des notifications pour les nouveautés (formations, articles)
- FR30: L'utilisateur reçoit des notifications de rappel pré-inscription
- FR31: L'utilisateur peut cliquer une notification pour ouvrir l'écran pertinent
- FR32: L'utilisateur peut gérer ses préférences de notifications

**Deep Links & Intégration (FR33-FR35):**
- FR33: L'utilisateur peut ouvrir l'app depuis un lien web Madinia
- FR34: Le deep link ouvre directement la page pertinente (formation, article)
- FR35: L'utilisateur peut partager un lien vers une formation depuis l'app

**Système & API (FR36-FR40):**
- FR36: Le système récupère les formations depuis l'API Laravel
- FR37: Le système récupère les articles de blog depuis l'API Laravel
- FR38: Le système envoie les pré-inscriptions à l'API Laravel
- FR39: Le système envoie les messages de contact à l'API Laravel
- FR40: Le système enregistre le device token pour les push notifications

### NonFunctional Requirements

**Performance (NFR1-5):**
- NFR1: Démarrage app à froid < 3 secondes
- NFR2: Chargement liste formations < 2 secondes
- NFR3: Ouverture fiche formation < 1 seconde
- NFR4: Réponse Madi (premier message) < 3 secondes
- NFR5: Scroll et animations 60 FPS constant

**Security (NFR6-9):**
- NFR6: Communications réseau HTTPS/TLS 1.3 obligatoire
- NFR7: Stockage données locales via Keychain pour tokens sensibles
- NFR8: Validation entrées (sanitization email + messages)
- NFR9: Protection API (rate limiting + validation serveur)

**Accessibility (NFR10-13):**
- NFR10: VoiceOver support 100% des éléments interactifs labellisés
- NFR11: Dynamic Type tailles de texte iOS respectées
- NFR12: Contrastes ratio minimum 4.5:1 (WCAG AA)
- NFR13: Zones tactiles minimum 44x44 points

**Integration (NFR14-17):**
- NFR14: API Laravel timeout max 10s, retry automatique
- NFR15: Push APNs livraison en < 5 minutes
- NFR16: Deep Links Universal Links iOS fonctionnels
- NFR17: Madi AI fallback gracieux si service indisponible

**Reliability (NFR18-20):**
- NFR18: Crash-free rate > 99.5% des sessions
- NFR19: Disponibilité API 99% uptime (hors maintenance planifiée)
- NFR20: Gestion hors-ligne états d'erreur clairs, retry manuel

### Additional Requirements

**Architecture Requirements:**
- Starter Template: Xcode iOS App with SwiftUI + SwiftData
- Architecture Pattern: MVVM with @Observable (iOS 17+)
- Project Structure: Feature-based organization in Views/
- Services Layer: APIService, MadiService, PushNotificationService, KeychainService
- Naming Conventions: PascalCase types, camelCase properties
- Error Handling: APIError enum with LoadingState
- Async Patterns: async/await exclusively, no completion handlers

**UX Design Requirements:**
- Custom Components: FormationCard, ProgressPath, InfoBadge, MadiButton, PreRegistrationSheet, MadiChatView
- User Flows: 4 documented flows (Lucas découvre, Sophie trouve, Marc évalue, Lucas revient)
- Accessibility: WCAG 2.1 AA compliance, VoiceOver, Dynamic Type
- Design Tokens: Colors, typography (SF Pro), spacing system defined
- Navigation: TabView 4 onglets + NavigationStack + Sheet overlays

### FR Coverage Map

| FR | Epic | Description |
|----|------|-------------|
| FR1 | Epic 1 | Navigation 4 onglets |
| FR2 | Epic 1 | Exploration sans compte |
| FR3 | Epic 2 | Écran d'accueil highlights |
| FR4 | Epic 2 | Parcours visuel Starter→Master |
| FR5 | Epic 2 | Liste formations |
| FR6 | Epic 2 | Infos clés < 5 secondes |
| FR7 | Epic 2 | Détail formation |
| FR8 | Epic 2 | Progression packs |
| FR9 | Epic 2 | Formations par catégorie |
| FR10 | Epic 3 | Pré-inscription 2 taps |
| FR11 | Epic 3 | Email pré-inscription |
| FR12 | Epic 3 | Confirmation pré-inscription |
| FR13 | Epic 3 | Envoi pré-inscription API |
| FR14 | Epic 4 | Feed articles blog |
| FR15 | Epic 4 | Lecture article |
| FR16 | Epic 4 | CTA formation liée |
| FR17 | Epic 4 | Navigation blog → formation |
| FR18 | Epic 5 | Message contact |
| FR19 | Epic 5 | Pré-remplissage contexte |
| FR20 | Epic 5 | Confirmation envoi |
| FR21 | Epic 5 | Transmission contexte API |
| FR22 | Epic 6 | Activer/désactiver Madi |
| FR23 | Epic 6 | Questions à Madi |
| FR24 | Epic 6 | Recommandations Madi |
| FR25 | Epic 6 | Explications packs |
| FR26 | Epic 6 | Navigation vers recommandation |
| FR27 | Epic 6 | Madi non-intrusif |
| FR28 | Epic 7 | Autoriser notifications |
| FR29 | Epic 7 | Notifications nouveautés |
| FR30 | Epic 7 | Rappels pré-inscription |
| FR31 | Epic 7 | Deep link notification |
| FR32 | Epic 7 | Préférences notifications |
| FR33 | Epic 8 | Ouvrir depuis lien web |
| FR34 | Epic 8 | Deep link page pertinente |
| FR35 | Epic 8 | Partager formation |
| FR36 | Epic 2 | API formations |
| FR37 | Epic 4 | API articles |
| FR38 | Epic 3 | API pré-inscriptions |
| FR39 | Epic 5 | API contacts |
| FR40 | Epic 7 | API device token |

## Epic List

### Epic 1: Foundation & Navigation
L'utilisateur peut ouvrir l'app et naviguer entre les 4 onglets principaux.
**FRs couverts:** FR1, FR2

### Epic 2: Découverte des Formations
L'utilisateur peut explorer le catalogue de formations et comprendre le parcours Starter→Performer→Master.
**FRs couverts:** FR3, FR4, FR5, FR6, FR7, FR8, FR9, FR36

### Epic 3: Pré-inscription
L'utilisateur peut se pré-inscrire à une formation en 2 taps maximum.
**FRs couverts:** FR10, FR11, FR12, FR13, FR38

### Epic 4: Blog & Contenu
L'utilisateur peut lire les articles de blog et découvrir les formations associées.
**FRs couverts:** FR14, FR15, FR16, FR17, FR37

### Epic 5: Contact Contextuel
L'utilisateur peut contacter Madinia avec le contexte de navigation pré-rempli.
**FRs couverts:** FR18, FR19, FR20, FR21, FR39

### Epic 6: Madi Coach IA
L'utilisateur peut obtenir des recommandations personnalisées via le coach IA optionnel.
**FRs couverts:** FR22, FR23, FR24, FR25, FR26, FR27

### Epic 7: Push Notifications
L'utilisateur peut recevoir et gérer les notifications push.
**FRs couverts:** FR28, FR29, FR30, FR31, FR32, FR40

### Epic 8: Deep Links & Partage
L'utilisateur peut ouvrir l'app depuis un lien web Madinia et partager des formations.
**FRs couverts:** FR33, FR34, FR35

---

## Epic 1: Foundation & Navigation

L'utilisateur peut ouvrir l'app et naviguer entre les 4 onglets principaux.

### Story 1.1: Project Setup & Base Structure

As a **developer**,
I want **the Xcode project initialized with SwiftUI and proper folder structure**,
So that **I have a solid foundation for building the app**.

**Acceptance Criteria:**

**Given** a new Xcode project
**When** initialized with SwiftUI App template
**Then** the project compiles without errors
**And** folder structure matches architecture (Models/, Views/, ViewModels/, Services/, etc.)
**And** iOS 17+ deployment target is configured
**And** SwiftData is enabled

### Story 1.2: Tab Navigation Implementation

As a **user**,
I want **to navigate between 4 main tabs (Accueil, Formations, Blog, Contact)**,
So that **I can easily access different sections of the app**.

**Acceptance Criteria:**

**Given** the app is launched
**When** the main screen appears
**Then** I see a tab bar with 4 tabs: Accueil, Formations, Blog, Contact
**And** each tab has an appropriate SF Symbol icon
**And** the Accueil tab is selected by default
**And** tapping a tab switches to that section
**And** the tab bar remains visible on all main screens

### Story 1.3: Placeholder Views for All Tabs

As a **user**,
I want **each tab to show its dedicated screen**,
So that **I can see the app structure is working**.

**Acceptance Criteria:**

**Given** I'm on any tab
**When** I tap another tab
**Then** the content area changes to that tab's view
**And** each view displays its section name (placeholder)
**And** navigation works without requiring login (FR2)

---

## Epic 2: Découverte des Formations

L'utilisateur peut explorer le catalogue de formations et comprendre le parcours Starter→Performer→Master.

### Story 2.1: API Service & Formation Model

As a **developer**,
I want **an API service that fetches formations from the Laravel backend**,
So that **the app can display real formation data**.

**Acceptance Criteria:**

**Given** the APIService is implemented
**When** `fetchFormations()` is called
**Then** it returns a list of Formation objects
**And** Formation model includes: id, title, description, duration, level, price, nextSession, category
**And** errors are handled with APIError enum
**And** the service uses async/await pattern

### Story 2.2: Home View with Highlights

As a **user**,
I want **to see an engaging home screen with highlights and quick access**,
So that **I can quickly discover what Madinia offers** (FR3).

**Acceptance Criteria:**

**Given** I'm on the Accueil tab
**When** the view loads
**Then** I see a welcome section with Madinia branding
**And** I see highlighted formations or promotions
**And** I see quick access buttons to key sections
**And** loading state is shown while fetching data
**And** error state is shown if fetch fails with retry option

### Story 2.3: Progress Path Component

As a **user**,
I want **to see a visual progression path Starter→Performer→Master**,
So that **I understand the learning journey** (FR4, FR8).

**Acceptance Criteria:**

**Given** I'm viewing the home or formations screen
**When** the ProgressPath component is displayed
**Then** I see 3 connected steps: Starter, Performer, Master
**And** each step shows the pack name and brief description
**And** tapping a step navigates to that formation's detail
**And** the visual design follows UX specification

### Story 2.4: Formations List View

As a **user**,
I want **to see a list of all available formations**,
So that **I can browse the catalog** (FR5).

**Acceptance Criteria:**

**Given** I'm on the Formations tab
**When** the view loads
**Then** I see a list of FormationCard components
**And** each card shows: title, level, duration, price
**And** I can scroll through all formations
**And** tapping a card navigates to formation detail
**And** pull-to-refresh updates the list

### Story 2.5: Formation Card & Info Badge Components

As a **user**,
I want **formation cards to show key info at a glance**,
So that **I understand a formation in less than 5 seconds** (FR6).

**Acceptance Criteria:**

**Given** a FormationCard is displayed
**When** I look at it
**Then** I see InfoBadges for: Durée, Niveau, Prix, Prochaine session
**And** the layout is scannable in under 5 seconds
**And** visual hierarchy emphasizes the most important info
**And** components follow UX design tokens (colors, spacing)

### Story 2.6: Formation Detail View

As a **user**,
I want **to see complete details about a formation**,
So that **I can make an informed decision** (FR7).

**Acceptance Criteria:**

**Given** I tap on a formation card
**When** the detail view opens
**Then** I see full description, objectives, prerequisites
**And** I see all InfoBadges (Durée, Niveau, Prix, Session)
**And** I see a prominent "Pré-inscription" CTA button
**And** I can navigate back to the list
**And** the view follows NavigationStack pattern

### Story 2.7: Formations by Category/Objective

As a **user**,
I want **to filter or view formations by category or objective**,
So that **I find relevant formations faster** (FR9).

**Acceptance Criteria:**

**Given** I'm on the Formations list
**When** I select a category or objective filter
**Then** the list updates to show matching formations
**And** I can clear filters to see all formations
**And** filter state is preserved during navigation

---

## Epic 3: Pré-inscription

L'utilisateur peut se pré-inscrire à une formation en 2 taps maximum.

### Story 3.1: Pre-registration Sheet UI

As a **user**,
I want **a simple pre-registration form that appears as a sheet**,
So that **I can quickly express my interest** (FR10).

**Acceptance Criteria:**

**Given** I'm on a formation detail view
**When** I tap the "Pré-inscription" button (tap 1)
**Then** a sheet slides up with a simple form
**And** the form shows the formation name for context
**And** the form has an email input field
**And** the form has a "Confirmer" button (tap 2)
**And** I can dismiss the sheet by swiping down

### Story 3.2: Email Input & Validation

As a **user**,
I want **to enter my email with real-time validation**,
So that **I know my email is correct before submitting** (FR11).

**Acceptance Criteria:**

**Given** the pre-registration sheet is open
**When** I type in the email field
**Then** the field validates email format in real-time
**And** invalid email shows inline error message
**And** valid email shows green checkmark
**And** the "Confirmer" button is disabled until email is valid
**And** keyboard type is `.emailAddress`

### Story 3.3: Pre-registration API Submission

As a **system**,
I want **to send pre-registration data to the Laravel API**,
So that **Madinia receives the lead** (FR13, FR38).

**Acceptance Criteria:**

**Given** a valid email is entered
**When** user taps "Confirmer"
**Then** the system sends POST to `/api/v1/pre-registrations`
**And** payload includes: email, formation_id, timestamp
**And** loading state is shown during submission
**And** errors are handled gracefully with retry option
**And** network errors show appropriate message

### Story 3.4: Confirmation & Success State

As a **user**,
I want **to see a confirmation after pre-registration**,
So that **I know my interest was recorded** (FR12).

**Acceptance Criteria:**

**Given** pre-registration is submitted successfully
**When** API returns success
**Then** I see a success animation (checkmark)
**And** I see a confirmation message "Merci ! Nous vous contacterons bientôt."
**And** haptic feedback (success) is triggered
**And** the sheet auto-dismisses after 2 seconds
**And** I return to the formation detail view

---

## Epic 4: Blog & Contenu

L'utilisateur peut lire les articles de blog et découvrir les formations associées.

### Story 4.1: API Service for Articles

As a **developer**,
I want **an API service that fetches blog articles from Laravel**,
So that **the app can display blog content** (FR37).

**Acceptance Criteria:**

**Given** the APIService is extended
**When** `fetchArticles()` is called
**Then** it returns a list of Article objects
**And** Article model includes: id, title, excerpt, content, publishedAt, imageURL, relatedFormationId
**And** errors are handled with APIError enum
**And** the service uses async/await pattern

### Story 4.2: Blog Feed View

As a **user**,
I want **to see a feed of blog articles**,
So that **I can browse content and learn about AI** (FR14).

**Acceptance Criteria:**

**Given** I'm on the Blog tab
**When** the view loads
**Then** I see a scrollable list of ArticleCard components
**And** articles are sorted by most recent first
**And** loading state is shown while fetching
**And** pull-to-refresh updates the list
**And** error state shows retry option if fetch fails

### Story 4.3: Article Card Component

As a **user**,
I want **article cards to show key info attractively**,
So that **I can decide what to read**.

**Acceptance Criteria:**

**Given** an ArticleCard is displayed
**When** I look at it
**Then** I see the article title prominently
**And** I see a short excerpt (2-3 lines max)
**And** I see the publication date
**And** I see a thumbnail image if available
**And** tapping the card navigates to article detail

### Story 4.4: Article Detail View

As a **user**,
I want **to read the full article content**,
So that **I can learn from Madinia's expertise** (FR15).

**Acceptance Criteria:**

**Given** I tap on an article card
**When** the detail view opens
**Then** I see the full article title
**And** I see the publication date and reading time
**And** I see the full article content with proper formatting
**And** images are displayed inline
**And** I can scroll through long content
**And** I can navigate back to the blog feed

### Story 4.5: CTA to Related Formation

As a **user**,
I want **to see a call-to-action to the related formation at the end of an article**,
So that **I can explore deeper learning opportunities** (FR16, FR17).

**Acceptance Criteria:**

**Given** I'm reading an article that has a related formation
**When** I scroll to the end of the article
**Then** I see a CTA section "Aller plus loin"
**And** I see the related formation card
**And** tapping the CTA navigates to the formation detail
**And** if no related formation, the CTA section is hidden

---

## Epic 5: Contact Contextuel

L'utilisateur peut contacter Madinia avec le contexte de navigation pré-rempli.

### Story 5.1: Navigation Context Service

As a **developer**,
I want **a service that tracks user navigation context**,
So that **contact forms can be pre-filled with relevant info** (FR19).

**Acceptance Criteria:**

**Given** a NavigationContext service exists
**When** user navigates to a formation or article
**Then** the context stores the last viewed item (type + id + title)
**And** context is accessible from any view via Environment
**And** context resets after successful contact submission
**And** context persists during the session only

### Story 5.2: Contact Form View

As a **user**,
I want **to send a message to Madinia through a contact form**,
So that **I can ask questions or request information** (FR18).

**Acceptance Criteria:**

**Given** I'm on the Contact tab
**When** the view loads
**Then** I see a contact form with fields: Name, Email, Message
**And** all fields have proper labels and placeholders
**And** the form has a "Envoyer" button
**And** keyboard handling is smooth (scroll to active field)

### Story 5.3: Context Pre-fill Implementation

As a **user**,
I want **the contact form to show context from my navigation**,
So that **Madinia understands what I'm asking about** (FR19).

**Acceptance Criteria:**

**Given** I viewed a formation before going to Contact
**When** the contact form loads
**Then** I see a context banner "À propos de: [Formation Name]"
**And** I can dismiss the context if not relevant
**And** the message field is pre-filled with "Question concernant [Formation Name]"
**And** if no context, form shows without pre-fill

### Story 5.4: Contact API Submission

As a **system**,
I want **to send contact messages to the Laravel API**,
So that **Madinia receives inquiries** (FR21, FR39).

**Acceptance Criteria:**

**Given** a valid form is filled
**When** user taps "Envoyer"
**Then** the system sends POST to `/api/v1/contacts`
**And** payload includes: name, email, message, context (formation/article if any)
**And** loading state is shown during submission
**And** errors are handled with retry option

### Story 5.5: Contact Confirmation

As a **user**,
I want **to see a confirmation after sending my message**,
So that **I know Madinia received my inquiry** (FR20).

**Acceptance Criteria:**

**Given** contact message is submitted successfully
**When** API returns success
**Then** I see a success message "Message envoyé !"
**And** I see "Nous vous répondrons sous 24-48h"
**And** haptic feedback (success) is triggered
**And** form is reset for potential new message
**And** navigation context is cleared

---

## Epic 6: Madi Coach IA

L'utilisateur peut obtenir des recommandations personnalisées via le coach IA optionnel.

### Story 6.1: Madi FAB Button

As a **user**,
I want **to see a floating action button to access Madi**,
So that **I can get help whenever I need it** (FR22).

**Acceptance Criteria:**

**Given** I'm on any main screen
**When** the view is displayed
**Then** I see the Madi FAB in the bottom-right corner
**And** the FAB has the Madi icon/avatar
**And** the FAB is visible but not intrusive
**And** the FAB hides when keyboard is active
**And** tapping the FAB opens the Madi chat sheet

### Story 6.2: Madi Chat View

As a **user**,
I want **a chat interface to interact with Madi**,
So that **I can ask questions naturally** (FR23).

**Acceptance Criteria:**

**Given** I tap the Madi FAB
**When** the chat sheet opens
**Then** I see a chat interface with Madi's welcome message
**And** I see a text input field at the bottom
**And** I can type and send messages
**And** my messages appear on the right (user bubble)
**And** Madi's responses appear on the left (Madi bubble)
**And** I can dismiss the sheet by swiping down

### Story 6.3: Madi Service (AI Integration)

As a **developer**,
I want **a service that handles Madi AI conversations**,
So that **users get intelligent responses**.

**Acceptance Criteria:**

**Given** the MadiService is implemented
**When** a message is sent to Madi
**Then** the service calls the AI backend (OpenAI/Supabase Edge Function)
**And** the prompt includes context about Madinia formations
**And** responses are relevant to formation guidance
**And** typing indicator shows while waiting for response
**And** fallback message is shown if AI service fails (FR: NFR17)

### Story 6.4: Formation Recommendations

As a **user**,
I want **Madi to recommend formations based on my goals**,
So that **I find the right learning path** (FR24, FR25).

**Acceptance Criteria:**

**Given** I ask Madi about my learning goals
**When** Madi processes my question
**Then** Madi recommends relevant formations (Starter/Performer/Master)
**And** Madi explains the differences between packs when asked
**And** recommendations include formation names as tappable links
**And** Madi's tone is friendly and encouraging (coach persona)

### Story 6.5: Navigate to Recommended Formation

As a **user**,
I want **to tap a formation mentioned by Madi to see its details**,
So that **I can learn more and potentially register** (FR26).

**Acceptance Criteria:**

**Given** Madi recommends a formation in chat
**When** I tap the formation name/link
**Then** the chat sheet dismisses
**And** I navigate to that formation's detail view
**And** the transition is smooth and intuitive

### Story 6.6: Non-intrusive Madi Behavior

As a **user**,
I want **Madi to never interrupt my navigation**,
So that **I feel in control of my experience** (FR27).

**Acceptance Criteria:**

**Given** I'm using the app
**When** I navigate freely
**Then** Madi never shows pop-ups or unsolicited messages
**And** Madi FAB remains subtle (no animations to attract attention)
**And** Madi only speaks when I initiate conversation
**And** I can completely ignore Madi and still use the full app

---

## Epic 7: Push Notifications

L'utilisateur peut recevoir et gérer les notifications push.

### Story 7.1: Push Permission Request

As a **user**,
I want **to be asked for notification permission at the right moment**,
So that **I can choose to receive updates** (FR28).

**Acceptance Criteria:**

**Given** I'm using the app for the first time
**When** I complete a meaningful action (e.g., view a formation)
**Then** the app requests notification permission
**And** the request explains the value ("Recevez les nouvelles formations")
**And** I can accept or decline
**And** my choice is respected (no repeated asks if declined)
**And** permission status is stored locally

### Story 7.2: Device Token Registration

As a **system**,
I want **to register the device token with the backend**,
So that **push notifications can be sent** (FR40).

**Acceptance Criteria:**

**Given** user grants notification permission
**When** APNs returns a device token
**Then** the app sends POST to `/api/v1/devices`
**And** payload includes: device_token, platform (ios), app_version
**And** token is stored in Keychain
**And** token is re-registered if it changes
**And** errors are handled silently (non-blocking)

### Story 7.3: Receive & Display Notifications

As a **user**,
I want **to receive notifications about new formations and articles**,
So that **I stay informed about Madinia news** (FR29, FR30).

**Acceptance Criteria:**

**Given** I have notifications enabled
**When** Madinia sends a push notification
**Then** I see the notification on my device
**And** notification shows title and brief message
**And** notification appears in Notification Center
**And** notification badge updates on app icon

### Story 7.4: Notification Deep Link Handling

As a **user**,
I want **to tap a notification and go directly to the relevant content**,
So that **I can quickly see what's new** (FR31).

**Acceptance Criteria:**

**Given** I receive a notification about a new formation
**When** I tap the notification
**Then** the app opens (or comes to foreground)
**And** I'm navigated directly to that formation's detail
**And** the correct tab is selected
**And** deep link works from cold start and background

### Story 7.5: Notification Preferences

As a **user**,
I want **to manage my notification preferences**,
So that **I only receive relevant updates** (FR32).

**Acceptance Criteria:**

**Given** I navigate to app settings (via profile or settings)
**When** I view notification preferences
**Then** I can toggle: Nouvelles formations, Nouveaux articles, Rappels
**And** preferences are saved locally and synced to backend
**And** changes take effect immediately
**And** I can disable all notifications from here

---

## Epic 8: Deep Links & Partage

L'utilisateur peut ouvrir l'app depuis un lien web Madinia et partager des formations.

### Story 8.1: Universal Links Configuration

As a **developer**,
I want **Universal Links configured for the app**,
So that **web links open in the app** (FR33).

**Acceptance Criteria:**

**Given** Universal Links are configured
**When** the app is installed
**Then** links from madinia.fr domain are associated with the app
**And** apple-app-site-association file is configured on server
**And** Associated Domains entitlement is added to the app
**And** links work on iOS 17+

### Story 8.2: Deep Link Routing

As a **user**,
I want **web links to open the correct page in the app**,
So that **I have a seamless experience between web and app** (FR34).

**Acceptance Criteria:**

**Given** I tap a Madinia link (e.g., madinia.fr/formations/starter)
**When** the app is installed
**Then** the app opens instead of Safari
**And** I'm navigated to the correct formation detail
**And** supported routes: /formations/{id}, /blog/{id}
**And** unknown routes open the home tab
**And** works from Messages, Mail, Safari, and other apps

### Story 8.3: Share Formation

As a **user**,
I want **to share a formation link with others**,
So that **I can recommend Madinia to friends** (FR35).

**Acceptance Criteria:**

**Given** I'm on a formation detail view
**When** I tap the share button
**Then** the iOS share sheet appears
**And** the shared content includes: formation title + web URL
**And** I can share via Messages, Mail, AirDrop, etc.
**And** the URL is the web version (madinia.fr/formations/{id})
**And** recipients with the app installed will open it in-app

