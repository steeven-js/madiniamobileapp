---
stepsCompleted: ['step-01-init', 'step-02-discovery', 'step-03-success', 'step-04-journeys', 'step-05-domain', 'step-06-innovation', 'step-07-project-type', 'step-08-scoping', 'step-09-functional', 'step-10-nonfunctional', 'step-11-polish', 'step-12-complete']
workflow_completed: true
completed_date: '2026-01-23'
inputDocuments:
  - "_bmad-output/planning-artifacts/product-brief-madiniamobileapp-2026-01-23.md"
  - "_bmad-output/analysis/brainstorming-session-2026-01-23.md"
workflowType: 'prd'
documentCounts:
  briefs: 1
  research: 0
  brainstorming: 1
  projectDocs: 0
classification:
  projectType: mobile_app
  domain: edtech
  complexity: medium
  projectContext: greenfield
date: 2026-01-23
author: Steeven
project_name: "Madinia Mobile"
---

# Product Requirements Document - Madinia Mobile

**Author:** Steeven
**Date:** 2026-01-23

## Executive Summary

**Madinia Mobile** est une application iOS native permettant aux utilisateurs de découvrir et s'inscrire aux formations en IA générative de Madinia.

| Aspect | Description |
|--------|-------------|
| **Vision** | App vitrine intelligente avec UX inspirée Duolingo |
| **Différenciateur** | "Madi", coach IA optionnel qui guide sans imposer |
| **Cible** | iPhone iOS 17+, français, portrait |
| **Tech Stack** | Swift 5.9 / SwiftUI / SwiftData + API Laravel |
| **MVP Scope** | 4 onglets, catalogue, blog, contact, Madi, push, deep links |

**Principes fondateurs :**
1. **Règle des 5 secondes** — Tout compréhensible instantanément
2. **Navigation libre prioritaire** — L'IA aide mais n'impose jamais
3. **Écosystème unifié** — Web et mobile partagent le même contenu
4. **Zéro friction** — Exploration sans compte, pré-inscription 2 taps

---

## Success Criteria

### User Success

| Persona | Moment de succès | Indicateur mesurable |
|---------|------------------|---------------------|
| Lucas (Étudiant) | Comprend le parcours Starter→Master, s'inscrit | Pré-inscription Starter complétée |
| Sophie (Freelance) | Trouve LA formation pour son métier | Pré-inscription Performer + consultation fiche > 30s |
| Marc (Dirigeant) | Contacte Madinia pour former son équipe | Formulaire contact envoyé avec contexte "équipe" |

**Moments "Aha!" :**
- Première découverte du parcours visuel Starter→Performer→Master
- Interaction réussie avec Madi (réponse pertinente)
- Réception d'une notification push pertinente

### Business Success

**Court terme (3 mois) :**
- ✅ Premiers utilisateurs actifs sur l'app
- ✅ Premières pré-inscriptions générées via mobile
- ✅ Feedback utilisateur positif (App Store reviews)

**Moyen terme (6-12 mois) :**
- ✅ Canal d'acquisition complémentaire établi
- ✅ Engagement régulier via blog et notifications
- ✅ Notoriété Madinia renforcée sur mobile

**Signaux de succès :**
- Pré-inscriptions mentionnant l'app comme source
- Retours utilisateurs après notifications push
- Demandes de contact contextualisées

**Signaux d'alerte :**
- Téléchargements sans exploration
- Notifications systématiquement ignorées
- Zéro conversion après 3 mois

### Technical Success

| Critère | Cible V1 | Mesure |
|---------|----------|--------|
| Stabilité | Crash rate < 1% | Firebase Crashlytics |
| Performance | Lancement < 3s | Instruments iOS |
| API | Réponse < 500ms | Monitoring Laravel |
| App Store | Publication validée | Apple Review |
| Push | Delivery rate > 95% | APNs metrics |

### Measurable Outcomes

| KPI | Description | Fréquence |
|-----|-------------|-----------|
| Téléchargements | Nouveaux utilisateurs | Hebdomadaire |
| Sessions | Utilisateurs actifs | Quotidien |
| Pré-inscriptions | Leads générés | Hebdomadaire |
| Contacts | Demandes reçues | Hebdomadaire |
| Rétention | Retour J7 / J30 | Mensuel |
| Notifications | Taux d'ouverture | Hebdomadaire |

## Product Scope

### MVP - Minimum Viable Product (V1.0)

| Fonctionnalité | Priorité | Description |
|----------------|----------|-------------|
| Navigation 4 onglets | Must | Accueil, Formations, Blog, Contact |
| Catalogue formations | Must | Liste + fiches détaillées |
| Parcours visuel | Must | Starter→Performer→Master |
| Pré-inscription | Must | 2 taps, email uniquement |
| Blog | Must | Feed articles + CTA formations |
| Contact contextuel | Must | Formulaire pré-rempli |
| Madi Coach IA | Must | Chat optionnel, guide formations |
| Push notifications | Must | Nouveautés, rappels |
| Deep Links | Should | Universal Links iOS |

### Growth Features (Post-MVP)

| Feature | Version | Description |
|---------|---------|-------------|
| Madi amélioré | V1.5 | Réponses plus intelligentes |
| Preview PDF | V1.5 | Extraits formations gratuits |
| Espace apprenant | V2 | Login, progression, contenus |
| Gamification | V2.5 | Badges, streaks, défis |

### Vision (Future)

| Feature | Version | Description |
|---------|---------|-------------|
| Multi-langue | V3 | EN, ES, autres |
| Mode offline | V3 | Cache contenus |
| iPad | V3 | Interface optimisée |
| Apple Watch | V3+ | Notifications |
| Widgets iOS | V3+ | Accès rapide |
| Siri | V3+ | Raccourcis vocaux |

## User Journeys

### Journey 1 : Lucas — L'Étudiant Curieux découvre Madinia

**Persona :** Lucas, 22 ans, étudiant marketing/communication à Lyon. Utilise ChatGPT "à l'aveugle", veut structurer ses connaissances pour se démarquer sur le marché du travail.

**Opening Scene :**
Lucas scroll Instagram pendant une pause cours. Il voit une pub Madinia "Maîtrise l'IA en 2 semaines". Intrigué — il utilise ChatGPT mais se sent amateur comparé à ceux qui obtiennent des résultats impressionnants.

**Rising Action :**
1. Clique la pub → App Store → Télécharge l'app (gratuit, pas de compte requis)
2. Ouvre l'app → Écran d'accueil avec parcours visuel Starter→Performer→Master
3. Pense : "Ah, je comprends la progression ! Je suis clairement niveau Starter"
4. Consulte la fiche Starter : voit immédiatement 490€ | 2 jours | Débutant | Prochaine session
5. Hésite sur la différence avec Performer... active Madi
6. Madi explique : "Starter = les fondamentaux. Performer = automatisation avancée. Commence par Starter !"

**Climax :**
Lucas convaincu → tape son email → 2 taps → Pré-inscription envoyée → Message "On te recontacte sous 24h"

**Resolution :**
Lucas reçoit un email personnalisé de Madinia. Il montre l'app à ses amis. "Regarde, c'est super clean !" Bouche-à-oreille activé.

**Capabilities Revealed :**
- Acquisition via réseaux sociaux (deep link App Store)
- Exploration sans compte obligatoire
- Parcours visuel clair et immédiat
- Infos clés visibles en 5 secondes
- Coach IA Madi pour lever les hésitations
- Pré-inscription friction minimale (2 taps)

---

### Journey 2 : Sophie — La Freelance trouve SA formation

**Persona :** Sophie, 38 ans, graphiste freelance. Clients exigeants, besoin de productivité. Concurrents qui utilisent l'IA, peur de décrocher si elle n'évolue pas.

**Opening Scene :**
Sophie reçoit un lien WhatsApp d'une cliente satisfaite : "Tu connais Madinia ? Ils forment sur l'IA pour créatifs, ça pourrait t'intéresser."

**Rising Action :**
1. Clique le lien web → Deep Link ouvre l'app directement sur la fiche "Performer"
2. Voit immédiatement les infos clés : 2 jours | Intermédiaire | 790€ | Prochaine session 15 février
3. Pense : "C'est exactement mon niveau et mon budget"
4. Lit les détails : "Automatiser la création visuelle avec l'IA générative"
5. Va sur l'onglet Blog → Article "5 prompts Midjourney pour designers"
6. À la fin de l'article : CTA "Tu veux aller plus loin ? Formation Performer"

**Climax :**
Sophie pré-inscrit en 2 taps + envoie un message via Contact contextuel (pré-rempli "Formation Performer") : "Je veux savoir si c'est adapté aux graphistes print, pas que digital"

**Resolution :**
Madinia répond avec un témoignage d'un graphiste print formé. Sophie s'inscrit définitivement et recommande Madinia à 3 collègues freelances.

**Capabilities Revealed :**
- Deep Links fonctionnels (web → app sur bonne page)
- Contexte préservé dans la navigation
- Blog avec CTA vers formations liées
- Contact contextuel (pré-remplissage intelligent)
- Conversion par la preuve (témoignages)

---

### Journey 3 : Marc — Le Dirigeant évalue pour son équipe

**Persona :** Marc, 52 ans, chef d'entreprise PME (15 salariés). Entend parler d'IA partout, veut comprendre l'impact concret avant d'investir dans la formation de ses équipes.

**Opening Scene :**
Marc revient d'une journée découverte Madinia. Convaincu par la présentation, il scanne le QR code sur le flyer et installe l'app dans le train du retour.

**Rising Action :**
1. Ouvre l'app → Active Madi dès le premier écran
2. Marc : "Je suis chef d'entreprise, je veux former mon équipe de 5 personnes"
3. Madi : "Super ! Quel est leur niveau actuel avec l'IA ?"
4. Marc : "Débutants complets, ils n'utilisent même pas ChatGPT"
5. Madi suggère : "Je recommande de commencer par Starter pour toute l'équipe, puis Performer pour les plus motivés"
6. Marc explore le parcours visuel complet, comprend la logique de progression
7. Lit un article blog "Le ROI de la formation IA en PME" avec chiffres concrets

**Climax :**
Marc envoie un Contact contextuel enrichi : "Demande de devis formation équipe 5 personnes - Parcours Starter→Performer - Contact suite journée découverte Madinia du 20 janvier"

**Resolution :**
Madinia rappelle Marc le lendemain, propose un devis personnalisé avec planning adapté à sa PME. Contrat signé pour Q2, formation planifiée.

**Capabilities Revealed :**
- QR Code → App Store (acquisition événementiel)
- Madi comme conseiller stratégique (pas juste FAQ)
- Conversation contextuelle pour besoins complexes
- Blog avec contenu décisionnel (ROI, business case)
- Contact ultra-contextuel avec historique de navigation

---

### Journey 4 : Lucas revient via notification

**Persona :** Lucas (même persona), 2 semaines après sa pré-inscription initiale.

**Opening Scene :**
Lucas a pré-inscrit mais n'a pas finalisé. Il a oublié Madinia dans son quotidien étudiant chargé.

**Rising Action :**
1. Reçoit une notification push : "🎯 Lucas, la prochaine session Starter commence dans 5 jours !"
2. Clique → L'app s'ouvre sur la fiche Starter avec compte à rebours
3. Voit "Plus que 3 places" (urgence)
4. Relit les bénéfices, se souvient pourquoi il voulait se former
5. Hésite encore... notification J-2 : "💡 Nouveau : paiement en 3x sans frais"

**Climax :**
Lucas finalise son inscription via le lien dans la notification → Redirigé vers paiement web

**Resolution :**
Lucas participe à la formation Starter, poste sur LinkedIn "Meilleure décision de mon année", tag Madinia.

**Capabilities Revealed :**
- Push notifications de rappel personnalisées
- Deep links depuis notifications
- Urgence et rareté (places limitées)
- Relance intelligente multi-touch
- Handoff app → web pour paiement

---

### Journey Requirements Summary

| Journey | Capabilities clés révélées |
|---------|---------------------------|
| **Lucas découvre** | Acquisition sociale, exploration libre, parcours visuel, Madi, pré-inscription 2 taps |
| **Sophie trouve** | Deep Links, blog CTA, contact contextuel, conversion par preuve |
| **Marc évalue** | Madi conseiller, contenu décisionnel, contact enrichi, B2B flow |
| **Lucas revient** | Push notifications, rappels personnalisés, urgence, relance multi-touch |

**Fonctionnalités révélées par les journeys :**
- Navigation sans compte
- Parcours visuel Starter→Performer→Master
- Fiches formations avec infos clés immédiates
- Coach IA Madi (guide + conseiller)
- Blog avec CTA formations
- Contact contextuel pré-rempli
- Push notifications personnalisées
- Deep Links (web↔app)
- Pré-inscription 2 taps

## Mobile App Specific Requirements

### Project-Type Overview

**Type :** Application mobile iOS native
**Technologie :** Swift 5.9+ / SwiftUI / SwiftData
**Cible :** iPhone (iOS 17+)
**Distribution :** App Store

### Platform Requirements

| Critère | Spécification |
|---------|---------------|
| **Plateforme** | iOS uniquement (V1) |
| **Version minimum** | iOS 17.0 |
| **Devices** | iPhone (pas iPad V1) |
| **Orientation** | Portrait uniquement |
| **Langue** | Français uniquement (V1) |
| **Taille app** | < 50 MB cible |

### Device Permissions

| Permission | Usage | Obligatoire |
|------------|-------|-------------|
| **Push Notifications** | Nouveautés, rappels engagement | Optionnel (demandé au 1er lancement) |
| **Network** | API Laravel, contenu dynamique | Oui |
| **Stockage local** | Cache images, données offline | Automatique |

**Permissions NON requises :**
- Caméra / Microphone
- Localisation GPS
- Contacts / Calendrier
- HealthKit / Motion

### Offline Mode

**Stratégie V1 : Online-first**

| Comportement | Description |
|--------------|-------------|
| **Sans connexion** | Message "Connexion requise" |
| **Cache basique** | Images et données récentes en mémoire |
| **Pas de mode offline complet** | Prévu pour V2+ |

### Push Notification Strategy

#### Types de notifications

| Type | Contenu | Fréquence |
|------|---------|-----------|
| **Nouveautés** | Nouvelle formation, nouvel article blog | Max 1/semaine |
| **Rappel pré-inscription** | Relance pour finaliser inscription | J+3, J+7 après pré-inscription |
| **Session imminente** | "La session Starter commence dans 5 jours" | J-5, J-2 avant session |
| **Engagement** | "Tu n'as pas ouvert l'app depuis 2 semaines" | Max 1/mois |

#### Personnalisation

- Notifications avec prénom : "Lucas, la prochaine session..."
- Deep link vers écran pertinent
- Catégories désactivables dans les Settings iOS

#### Infrastructure

- **Provider :** APNs (Apple Push Notification service)
- **Backend :** Laravel + service push (Firebase Cloud Messaging ou direct APNs)
- **Tokens :** Stockés côté serveur, associés à l'email pré-inscription

### Store Compliance

#### App Store Guidelines

| Requirement | Status |
|-------------|--------|
| **Apple Review Guidelines** | À respecter |
| **Privacy Policy** | Requis (lien dans app + App Store) |
| **Privacy Labels** | À déclarer (email collecté, analytics) |
| **Age Rating** | 4+ (pas de contenu mature) |
| **In-App Purchase** | Non utilisé V1 (pas de 30% Apple) |

#### Privacy Labels (App Store Connect)

| Donnée collectée | Usage | Lié à l'identité |
|------------------|-------|------------------|
| Email | Pré-inscription, contact | Oui |
| Analytics (anonymes) | Amélioration app | Non |
| Device ID (push token) | Notifications | Oui |

#### Soumission App Store

- **Bundle ID :** com.madinia.mobile (à confirmer)
- **Team :** Compte Apple Developer Madinia
- **Review time :** 24-48h typique
- **Rejections communes à éviter :**
  - Liens vers paiement externe sans mention
  - Placeholder content
  - Bugs/crashes évidents

### Technical Architecture Considerations

> ⚠️ **Note importante :** L'API Laravel existante devra être revue et adaptée pour la communication avec l'app mobile. Cette adaptation sera détaillée dans la phase Architecture.

#### API Communication

| Aspect | Choix |
|--------|-------|
| **Protocol** | REST JSON over HTTPS |
| **Base URL** | api.madinia.fr (à créer) |
| **Auth** | API Key simple (V1), JWT (V2+) |
| **Format** | JSON UTF-8 |
| **Versioning** | /api/v1/ prefix |

#### Deep Links (Universal Links)

| Pattern | Destination |
|---------|-------------|
| `madinia.fr/formations/{slug}` | Fiche formation |
| `madinia.fr/blog/{slug}` | Article blog |
| `madinia.fr/contact` | Formulaire contact |

#### Networking Layer

- URLSession natif (pas de dépendance externe)
- Async/await Swift
- Error handling robuste
- Retry automatique (3 tentatives)
- Timeout : 30s

### Implementation Considerations

#### Dépendances externes

| Dépendance | Usage | Obligatoire |
|------------|-------|-------------|
| **Aucune** (V1) | Architecture native pure | — |
| **Firebase** (optionnel) | Crashlytics, Analytics, Push | Recommandé |

#### Architecture Swift

- **Pattern :** MVVM + SwiftUI
- **Data :** SwiftData pour cache local
- **Navigation :** NavigationStack iOS 16+
- **State :** @Observable (iOS 17+)

#### Testing

- Unit tests : XCTest
- UI tests : XCUITest
- Minimum coverage : 60% (V1)

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach :** Experience MVP
- Livrer une expérience utilisateur complète mais focalisée
- Priorité : qualité de l'UX sur quantité de features
- Philosophie "Duolingo" : simple, clair, engageant

**Objectif MVP :**
- Valider que l'app mobile est un canal d'acquisition viable
- Générer premières pré-inscriptions et contacts
- Collecter feedback utilisateur pour itérer

**Resources Requirements :**
- 1 développeur iOS (Swift/SwiftUI)
- Backend : adaptation API Laravel existante
- IA : Supabase Edge Functions ou OpenAI API
- Design : Apple HIG natif (pas de designer dédié)

### MVP Feature Set (Phase 1)

**Core User Journeys Supported :**
- ✅ Lucas découvre Madinia (acquisition sociale)
- ✅ Sophie trouve sa formation (deep link + blog)
- ✅ Marc évalue pour son équipe (Madi + contact)
- ✅ Lucas revient via notification (rétention)

**Must-Have Capabilities :**

| Capability | Justification |
|------------|---------------|
| Navigation 4 onglets | Structure de base, UX claire |
| Catalogue formations | Core value proposition |
| Parcours visuel Starter→Master | Différenciateur UX |
| Fiches avec infos clés | Règle des 5 secondes |
| Pré-inscription 2 taps | Conversion friction minimale |
| Blog + CTA | Tunnel de conversion naturel |
| Contact contextuel | Leads qualifiés |
| Madi Coach IA | Différenciateur produit |
| Push notifications | Rétention et engagement |
| Deep Links | Écosystème unifié web↔mobile |

### Post-MVP Features

**Phase 2 — Growth (V1.5 - V2) :**

| Feature | Version | Valeur ajoutée |
|---------|---------|----------------|
| Madi amélioré | V1.5 | Réponses plus intelligentes, contexte |
| Preview PDF | V1.5 | Transparence, confiance |
| Espace apprenant | V2 | Rétention, valeur long-terme |
| Gamification | V2.5 | Engagement, habit formation |

**Phase 3 — Expansion (V3+) :**

| Feature | Version | Marché/Usage |
|---------|---------|--------------|
| Multi-langue | V3 | Expansion internationale |
| Mode offline | V3 | Usage transport, zones blanches |
| iPad | V3 | Utilisateurs tablette |
| Apple Watch | V3+ | Notifications au poignet |
| Widgets iOS | V3+ | Engagement écran d'accueil |
| Siri | V3+ | Commandes vocales |

### Risk Mitigation Strategy

**Technical Risks :**

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| API Laravel pas prête | Medium | High | Développer endpoints en parallèle, mock data pour dev iOS |
| Madi IA trop complexe | Medium | Medium | V1 basée sur règles/prompts simples, ML en V1.5 |
| Performance API | Low | Medium | Cache côté app, pagination, lazy loading |
| Push notifications | Low | Low | Tester sur TestFlight avant production |

**Market Risks :**

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| Faible adoption | Medium | High | Beta test avec clients existants, feedback loop |
| Pas de conversion | Medium | High | A/B test messages, optimiser parcours |
| Concurrence apps formation | Low | Medium | Différenciateur Madi + UX Duolingo |

**Process Risks :**

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| Rejet App Store | Low | High | Suivre guidelines strictement, pas de payment links |
| Délais développement | Medium | Medium | Scope MVP serré, pas de scope creep |

### Scoping Decisions Summary

**In Scope MVP :**
- Tout ce qui permet découverte + pré-inscription + contact
- Madi comme guide (pas comme LMS)
- Push notifications basiques

**Out of Scope MVP :**
- Espace apprenant (auth, contenus, progression)
- Paiement in-app
- Gamification
- Multi-langue
- Mode offline avancé

**Success Gate pour Phase 2 :**
- Pré-inscriptions générées via app
- Feedback utilisateur positif
- Stabilité technique validée

## Functional Requirements

### Navigation & Découverte

- FR1: L'utilisateur peut naviguer entre 4 onglets principaux (Accueil, Formations, Blog, Contact)
- FR2: L'utilisateur peut explorer l'app sans créer de compte
- FR3: L'utilisateur peut voir un écran d'accueil avec highlights et accès rapides
- FR4: L'utilisateur peut voir le parcours visuel Starter→Performer→Master

### Catalogue Formations

- FR5: L'utilisateur peut voir la liste des formations disponibles
- FR6: L'utilisateur peut voir les infos clés d'une formation (Durée, Niveau, Prix, Prochaine session) en moins de 5 secondes
- FR7: L'utilisateur peut consulter le détail complet d'une formation
- FR8: L'utilisateur peut comprendre la progression entre les packs (Starter→Performer→Master)
- FR9: L'utilisateur peut voir les formations par catégorie/objectif

### Pré-inscription

- FR10: L'utilisateur peut se pré-inscrire à une formation en 2 taps maximum
- FR11: L'utilisateur peut fournir son email pour la pré-inscription
- FR12: L'utilisateur reçoit une confirmation après pré-inscription
- FR13: Le système envoie la pré-inscription à Madinia (API/email)

### Blog & Contenu

- FR14: L'utilisateur peut voir le feed des articles de blog
- FR15: L'utilisateur peut lire un article complet
- FR16: L'utilisateur peut voir le CTA vers la formation liée à la fin d'un article
- FR17: L'utilisateur peut naviguer du blog vers une fiche formation

### Contact

- FR18: L'utilisateur peut envoyer un message de contact à Madinia
- FR19: Le formulaire de contact se pré-remplit avec le contexte de navigation (formation consultée)
- FR20: L'utilisateur reçoit une confirmation d'envoi du message
- FR21: Le système transmet le message avec contexte à Madinia

### Madi Coach IA

- FR22: L'utilisateur peut activer/désactiver Madi (coach IA)
- FR23: L'utilisateur peut poser des questions à Madi sur les formations
- FR24: Madi peut recommander une formation basée sur les objectifs de l'utilisateur
- FR25: Madi peut expliquer les différences entre les packs
- FR26: L'utilisateur peut naviguer vers une formation recommandée par Madi
- FR27: Madi reste non-intrusif (jamais de pop-up imposé)

### Push Notifications

- FR28: L'utilisateur peut autoriser/refuser les notifications push
- FR29: L'utilisateur reçoit des notifications pour les nouveautés (formations, articles)
- FR30: L'utilisateur reçoit des notifications de rappel pré-inscription
- FR31: L'utilisateur peut cliquer une notification pour ouvrir l'écran pertinent
- FR32: L'utilisateur peut gérer ses préférences de notifications

### Deep Links & Intégration

- FR33: L'utilisateur peut ouvrir l'app depuis un lien web Madinia
- FR34: Le deep link ouvre directement la page pertinente (formation, article)
- FR35: L'utilisateur peut partager un lien vers une formation depuis l'app

### Système & API

- FR36: Le système récupère les formations depuis l'API Laravel
- FR37: Le système récupère les articles de blog depuis l'API Laravel
- FR38: Le système envoie les pré-inscriptions à l'API Laravel
- FR39: Le système envoie les messages de contact à l'API Laravel
- FR40: Le système enregistre le device token pour les push notifications

## Non-Functional Requirements

### Performance

| ID | Exigence | Métrique |
|----|----------|----------|
| NFR1 | Démarrage app à froid | < 3 secondes |
| NFR2 | Chargement liste formations | < 2 secondes |
| NFR3 | Ouverture fiche formation | < 1 seconde |
| NFR4 | Réponse Madi (premier message) | < 3 secondes |
| NFR5 | Scroll et animations | 60 FPS constant |

### Security

| ID | Exigence | Critère |
|----|----------|---------|
| NFR6 | Communications réseau | HTTPS/TLS 1.3 obligatoire |
| NFR7 | Stockage données locales | Keychain pour tokens sensibles |
| NFR8 | Validation entrées | Sanitization email + messages |
| NFR9 | Protection API | Rate limiting + validation serveur |

### Accessibility

| ID | Exigence | Critère |
|----|----------|---------|
| NFR10 | VoiceOver support | 100% des éléments interactifs labellisés |
| NFR11 | Dynamic Type | Tailles de texte iOS respectées |
| NFR12 | Contrastes | Ratio minimum 4.5:1 (WCAG AA) |
| NFR13 | Zones tactiles | Minimum 44x44 points |

### Integration

| ID | Exigence | Critère |
|----|----------|---------|
| NFR14 | API Laravel | Timeout max 10s, retry automatique |
| NFR15 | Push APNs | Livraison en < 5 minutes |
| NFR16 | Deep Links | Universal Links iOS fonctionnels |
| NFR17 | Madi AI | Fallback gracieux si service indisponible |

### Reliability

| ID | Exigence | Critère |
|----|----------|---------|
| NFR18 | Crash-free rate | > 99.5% des sessions |
| NFR19 | Disponibilité API | 99% uptime (hors maintenance planifiée) |
| NFR20 | Gestion hors-ligne | États d'erreur clairs, retry manuel |

