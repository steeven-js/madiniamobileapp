---
stepsCompleted: [1, 2, 3, 4, 5, 6]
workflow_completed: true
inputDocuments:
  - "_bmad-output/analysis/brainstorming-session-2026-01-23.md"
date: 2026-01-23
author: Steeven
project_name: "Madinia Mobile"
---

# Product Brief: Madinia Mobile

<!-- Content will be appended sequentially through collaborative workflow steps -->

## Input Documents Loaded

### Brainstorming Session (2026-01-23)
- **23 idées validées** via méthode SCAMPER
- **4 thèmes stratégiques** identifiés
- **Scope V1** : Catalogue, Blog, Contact, Madi (Coach IA optionnel)
- **Scope V2+** : Espace apprenant, Gamification

### Contexte Existant (Exploré)
- **Site Vitrine** : Laravel 12 + React (formations, services, packs, blog)
- **Dashboard CRM** : Laravel 12 + Filament (clients, devis, factures)
- **Supabase** : Storage PDFs/médias, Edge Functions
- **Projet Swift** : SwiftUI + SwiftData (scaffold initialisé)

## Executive Summary

**Madinia Mobile** est une application iOS native qui permet aux utilisateurs de découvrir et s'inscrire aux formations en IA générative de Madinia. L'app adopte une approche "vitrine intelligente" avec une UX inspirée de Duolingo : simple, claire, grand public.

**Différenciateur clé :** "Madi", un coach IA optionnel qui guide les utilisateurs vers les formations adaptées sans jamais s'imposer.

## Vision & Problem Statement

### Problème

Les prospects Madinia n'ont pas d'accès mobile simple au catalogue de formations. Le site web existe mais l'expérience mobile n'est pas optimale. Les utilisateurs veulent :
- Découvrir les formations rapidement
- Comprendre le parcours Starter → Performer → Master
- S'inscrire sans friction

### Solution

Une app iOS native avec :
- **4 onglets simples** : Accueil | Formations | Blog | Contact
- **Zéro compte obligatoire** pour explorer
- **Infos clés en 5 secondes** : Durée | Niveau | Prix | Session
- **Pré-inscription en 2 taps**
- **"Madi" Coach IA** (optionnel) pour guider les indécis

### Principes Fondateurs

1. **Règle des 5 secondes** — Tout doit être compréhensible instantanément
2. **Navigation libre prioritaire** — L'IA aide mais n'impose jamais
3. **Écosystème unifié** — Web et mobile partagent le même contenu
4. **Centré utilisateur** — Objectifs avant produits

## Target Users

### Primary Users

#### 🎓 Persona 1 : Lucas, 22 ans — L'Étudiant Curieux

**Contexte :**
- Étudiant en marketing/communication
- Utilise ChatGPT "à l'aveugle", veut structurer ses connaissances
- Découvre Madinia via réseaux sociaux (Instagram, TikTok)

**Problème actuel :**
- Ne sait pas par où commencer avec l'IA générative
- Se forme seul sur YouTube, manque de structure
- Veut se démarquer sur le marché du travail

**Solution Madinia :** Pack Starter — bases solides, prix accessible

**Moment "Aha!" :** "Enfin quelqu'un qui m'explique comment structurer un prompt !"

---

#### 💼 Persona 2 : Sophie, 38 ans — La Freelance Débordée

**Contexte :**
- Freelance créative (graphiste, rédactrice, etc.)
- Clients exigeants, besoin de productivité
- Découvre Madinia via conférences ou recommandations

**Problème actuel :**
- Tâches répétitives chronophages
- Concurrents qui utilisent l'IA, peur de décrocher
- Besoin de cas concrets appliqués à son métier

**Solution Madinia :** Pack Performer — automatisation workflow créatif

**Moment "Aha!" :** "J'ai créé 10 variations en 20 minutes au lieu de 3 heures"

---

#### 🏢 Persona 3 : Marc, 52 ans — Le Dirigeant Pragmatique

**Contexte :**
- Chef d'entreprise PME (10-50 salariés)
- Entend parler d'IA partout, veut comprendre l'impact concret
- Découvre Madinia via journées découverte, meetings réseau

**Problème actuel :**
- Équipes qui demandent des outils IA sans vision claire
- Besoin de comprendre avant d'investir
- Veut former ses équipes efficacement

**Solution Madinia :** Pack Master — vision complète + formation équipe

**Moment "Aha!" :** "Je comprends enfin ce que mes équipes peuvent automatiser"

---

### Secondary Users

N/A pour V1 — Focus sur les 3 personas primaires uniquement.

---

### User Journey

#### Parcours type dans Madinia Mobile V1

| Étape | Lucas (Étudiant) | Sophie (Freelance) | Marc (Dirigeant) |
|-------|------------------|-------------------|------------------|
| **Découverte** | Pub Instagram → télécharge app | Deep Link client → app | QR journée découverte → app |
| **Premier contact** | Explore catalogue librement | Va direct sur formation recommandée | Utilise Madi pour orientation |
| **Exploration** | Parcours Starter→Master visuel | Blog "IA créatifs" + CTA | Blog cas d'usage concrets |
| **Décision** | Infos clés en 5 sec (prix/durée) | Preview PDF contenus | Vision parcours complet |
| **Action** | Pré-inscription 2 taps | Pré-inscription + contact | Contact contextuel équipe |

#### Moments clés de l'app

1. **Zéro friction** — Exploration complète sans compte
2. **5 secondes** — Infos essentielles visibles immédiatement
3. **2 taps** — Pré-inscription ultra-rapide
4. **Contexte** — Chaque contact enrichi du parcours utilisateur

## Success Metrics

### Vision du Succès V1

L'app Madinia Mobile V1 réussit si elle devient un **canal d'acquisition complémentaire** au site web, générant :
- Des pré-inscriptions aux formations
- Des demandes de contact qualifiées
- Une notoriété renforcée via l'engagement régulier

### Métriques Utilisateur

| Persona | Succès | Indicateur |
|---------|--------|------------|
| Lucas (Étudiant) | Comprend le parcours, s'inscrit | Pré-inscription Starter |
| Sophie (Freelance) | Trouve sa formation, s'inscrit | Pré-inscription Performer |
| Marc (Dirigeant) | Contacte pour son équipe | Formulaire contact envoyé |

### Business Objectives

**Approche V1 : Qualitative**

Objectif principal : Valider que l'app mobile est un canal viable avant d'optimiser les conversions.

**Court terme (3 mois) :**
- ✅ Premiers utilisateurs actifs
- ✅ Premières pré-inscriptions via l'app
- ✅ Feedback utilisateur positif

**Moyen terme (6-12 mois) :**
- ✅ Canal d'acquisition complémentaire établi
- ✅ Engagement régulier via blog et notifications
- ✅ Notoriété Madinia renforcée sur mobile

### Key Performance Indicators

**KPIs Qualitatifs V1 :**

| Catégorie | Indicateur | Observation |
|-----------|------------|-------------|
| Acquisition | Téléchargements | L'app attire des utilisateurs |
| Engagement | Sessions répétées | Les utilisateurs reviennent |
| Conversion | Pré-inscriptions | L'app génère des leads |
| Contact | Demandes reçues | Leads qualifiés via app |
| Rétention | Ouvertures notifications | Push notifications efficaces |
| Contenu | Articles consultés | Blog mobile engageant |

**Signaux de succès :**
- Pré-inscriptions mentionnant l'app comme source
- Retours utilisateurs après notifications push
- Demandes de contact contextualisées

**Signaux d'alerte :**
- Téléchargements sans exploration
- Notifications systématiquement ignorées
- Zéro conversion après 3 mois

## MVP Scope

### Core Features V1.0

| Onglet | Fonctionnalités | Priorité |
|--------|-----------------|----------|
| **Accueil** | Parcours visuel Starter→Performer→Master, Highlights, Accès rapide | Must |
| **Formations** | Liste formations, Fiches détaillées (Durée/Niveau/Prix/Session), Pré-inscription 2 taps | Must |
| **Blog** | Feed articles, Lecture article, CTA vers formations liées | Must |
| **Contact** | Formulaire contextuel, Pré-remplissage selon navigation | Must |
| **Madi (IA)** | Chat optionnel, Guide vers formations, Accessible mais non-intrusif | Must |
| **Notifications** | Push nouveautés, Rappels engagement | Must |
| **Deep Links** | Universal Links iOS (web → app) | Should |

### Out of Scope for MVP

| Fonctionnalité | Raison | Version cible |
|----------------|--------|---------------|
| Espace apprenant | Auth + contenus + suivi = complexité | V2 |
| Gamification | Badges, points, streaks après validation | V2 |
| Paiement in-app | App Store fees + complexité | V2+ |
| Multi-langue | Français uniquement au lancement | V2 |
| Mode offline | Pas de cache complexe | V2 |
| Apple Watch | Focus iPhone | V3+ |

### MVP Success Criteria

**Critères de validation V1 :**

| Critère | Indicateur de succès |
|---------|---------------------|
| Fonctionnel | 4 onglets OK, Madi répond, notifs fonctionnelles |
| Utilisateur | Exploration + pré-inscriptions |
| Business | Leads générés via l'app |
| Technique | Stabilité + App Store validé |

**Décision Go/No-Go V2 :**
- ✅ Go : Pré-inscriptions + feedback positif + stabilité
- ⚠️ Pivot : Téléchargements sans conversion
- ❌ Stop : Aucune traction après 3 mois

### Future Vision

| Version | Évolutions |
|---------|-----------|
| V1.5 | Madi amélioré, Preview PDF formations |
| V2 | Espace apprenant (login, progression, contenus) |
| V2.5 | Gamification (badges, streaks, défis) |
| V3 | Multi-langue, Mode offline, iPad |
| V3+ | Apple Watch, Widgets iOS, Siri |

