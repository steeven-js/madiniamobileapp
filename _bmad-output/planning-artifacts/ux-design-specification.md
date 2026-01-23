---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
workflow_completed: true
inputDocuments:
  - "_bmad-output/planning-artifacts/prd.md"
  - "_bmad-output/planning-artifacts/product-brief-madiniamobileapp-2026-01-23.md"
date: 2026-01-23
author: Steeven
project_name: "Madinia Mobile"
---

# UX Design Specification — Madinia Mobile

**Author:** Steeven
**Date:** 2026-01-23

---

## Executive Summary

### Project Vision

**Madinia Mobile** est une application iOS vitrine intelligente permettant de découvrir et s'inscrire aux formations en IA générative de Madinia. L'UX s'inspire de Duolingo : simple, claire, engageante — pas un LMS corporate ennuyeux.

**Différenciateur clé :** "Madi", un coach IA optionnel qui guide les utilisateurs vers les formations adaptées sans jamais s'imposer.

### Target Users

| Persona | Profil | Objectif | Comportement |
|---------|--------|----------|--------------|
| **Lucas (22 ans)** | Étudiant marketing | Structurer ses connaissances IA pour se démarquer | Découvre via réseaux sociaux, explore librement, utilise Madi si indécis |
| **Sophie (38 ans)** | Freelance créative | Automatiser pour gagner en productivité | Arrive via recommandation, va droit au but, lit le blog |
| **Marc (52 ans)** | Dirigeant PME | Former son équipe efficacement | QR code événement, dialogue avec Madi, demande de devis |

### Key Design Challenges

| Défi | Description | Impact UX |
|------|-------------|-----------|
| **Clarté immédiate** | 3 formations (Starter/Performer/Master) avec progression à comprendre | Design de l'accueil critique |
| **Madi non-intrusif** | Coach IA présent mais jamais imposé | Équilibre visibilité/discrétion |
| **Conversion sans friction** | Pré-inscription sans compte, en 2 taps | Flow minimaliste à concevoir |
| **Multi-parcours** | 3 personas très différents | Navigation adaptée à chacun |

### Design Opportunities

| Opportunité | Valeur |
|-------------|--------|
| **Parcours visuel Starter→Master** | Différenciateur UX fort — progression claire en un coup d'œil |
| **Madi comme guide premium** | Expérience personnalisée pour les indécis, skip facile pour les pressés |
| **Infos clés en haut** | Prix/Durée/Niveau/Date visibles immédiatement = confiance instantanée |
| **Contact contextuel** | Pré-remplissage intelligent = leads ultra-qualifiés |

## Core User Experience

### Defining Experience

**Action centrale :** Découvrir le parcours de formation adapté et se pré-inscrire en 2 taps.

Tout le design doit faciliter cette action unique. Pas de distraction, pas de complexité.

### Platform Strategy

| Aspect | Décision |
|--------|----------|
| **Plateforme** | iOS native uniquement (V1) |
| **Device** | iPhone, portrait |
| **Interaction** | Touch-first, gestures iOS natifs |
| **Offline** | Non (online-first, cache basique) |
| **Capabilities** | Push notifications, Universal Links, Keychain |

### Effortless Interactions

| Interaction | Objectif | Comment |
|-------------|----------|---------|
| **Explorer sans compte** | Zéro friction à l'entrée | Pas de login, pas de mur |
| **Comprendre le parcours** | Clarté en 5 secondes | Visuel Starter→Performer→Master |
| **Voir les infos clés** | Décision rapide | Prix/Durée/Niveau/Date en haut |
| **Se pré-inscrire** | Conversion fluide | 2 taps + email = terminé |
| **Activer Madi** | Aide accessible | Bouton visible, jamais pop-up |

### Critical Success Moments

| Moment | Description | Indicateur |
|--------|-------------|------------|
| **Premier regard** | L'utilisateur comprend "c'est pour moi" | Temps sur accueil < 5s avant action |
| **Aha! parcours** | "Je vois où je dois commencer" | Clic sur Starter ou Madi |
| **Confiance prix** | "C'est clair, pas de surprise" | Consultation fiche > 30s |
| **Pré-inscription** | "C'était facile !" | Flow complété sans abandon |
| **Madi utile** | "Il m'a vraiment aidé" | Recommandation suivie |

### Experience Principles

| # | Principe | Application |
|---|----------|-------------|
| 1 | **5 secondes max** | Chaque écran doit être compris instantanément |
| 2 | **2 taps max** | Toute action importante en 2 taps ou moins |
| 3 | **Madi discret** | Présent mais jamais imposé — l'utilisateur choisit |
| 4 | **Contexte préservé** | Navigation enrichit le contact, pas de perte d'info |
| 5 | **Native first** | SwiftUI natif, pas de webview, gestures iOS |

## Desired Emotional Response

### Primary Emotional Goals

| Émotion Primaire | Description | Pourquoi |
|------------------|-------------|----------|
| **Clarté** | "Je comprends tout de suite" | Règle des 5 secondes, pas de confusion |
| **Confiance** | "C'est sérieux et transparent" | Prix/infos visibles, pas de piège |
| **Légèreté** | "C'est simple et agréable" | UX Duolingo, pas corporate |
| **Accompagnement** | "Je ne suis pas seul si j'ai besoin" | Madi présent mais discret |

### Emotional Journey Mapping

| Étape | Émotion Cible | Anti-pattern à éviter |
|-------|---------------|----------------------|
| **Découverte (Accueil)** | Curiosité + Clarté | ❌ Confusion, surcharge |
| **Exploration (Formations)** | Confiance + Intérêt | ❌ Doute sur les prix, complexité |
| **Hésitation** | Accompagnement (Madi) | ❌ Pression, pop-up intrusif |
| **Décision (Pré-inscription)** | Facilité + Accomplissement | ❌ Frustration, formulaire long |
| **Après action** | Satisfaction + Anticipation | ❌ Doute "ai-je bien fait?" |
| **Retour (Notification)** | Bienvenue + Pertinence | ❌ Spam, agacement |

### Micro-Emotions

| Micro-Émotion | État Souhaité | État à Éviter |
|---------------|---------------|---------------|
| **Compréhension** | ✅ "Je sais où aller" | ❌ "C'est quoi la différence?" |
| **Contrôle** | ✅ "Je décide mon rythme" | ❌ "On me force la main" |
| **Transparence** | ✅ "Tout est clair" | ❌ "Il y a un piège?" |
| **Progression** | ✅ "Je vois mon chemin" | ❌ "Par où commencer?" |
| **Soutien** | ✅ "Madi peut m'aider" | ❌ "Personne pour m'aider" |

### Design Implications

| Émotion | Implication UX |
|---------|----------------|
| **Clarté** | Hiérarchie visuelle forte, peu de texte, icônes explicites |
| **Confiance** | Prix visible sans scroll, témoignages, branding cohérent |
| **Légèreté** | Couleurs vives, illustrations, micro-animations subtiles |
| **Accompagnement** | Bouton Madi toujours visible mais jamais modal |
| **Accomplissement** | Feedback positif après pré-inscription, animation de succès |

### Emotional Design Principles

| # | Principe | Application |
|---|----------|-------------|
| 1 | **Rassurer avant de vendre** | Infos clés visibles, pas de dark patterns |
| 2 | **Célébrer les micro-succès** | Animation après pré-inscription |
| 3 | **Humaniser avec Madi** | Ton conversationnel, pas robot |
| 4 | **Respecter le rythme** | Jamais de pression, jamais d'urgence artificielle |
| 5 | **Gratifier la curiosité** | Blog riche, contenu de valeur gratuit |

## UX Pattern Analysis & Inspiration

### Inspiring Products Analysis

#### Duolingo — Référence Principale

| Aspect | Ce qu'ils font bien | Application Madinia |
|--------|---------------------|---------------------|
| **Onboarding** | Pas de compte requis pour commencer | ✅ Exploration sans login |
| **Progression** | Parcours visuel clair (arbre de compétences) | ✅ Visuel Starter→Performer→Master |
| **Clarté** | Une action par écran, pas de surcharge | ✅ Règle des 5 secondes |
| **Ton** | Friendly, encourageant, jamais corporate | ✅ Madi conversationnel |
| **Feedback** | Célébration des succès, animations joyeuses | ✅ Animation post pré-inscription |

#### Notion — Simplicité Puissante

| Aspect | Ce qu'ils font bien | Application Madinia |
|--------|---------------------|---------------------|
| **Navigation** | Hiérarchie claire, sidebar minimaliste | ✅ 4 onglets, pas plus |
| **Contenu** | Texte lisible, espacement généreux | ✅ Fiches formations aérées |
| **Empty states** | Guides l'utilisateur | ✅ Madi comme guide |

#### Calm / Headspace — Confiance & Sérénité

| Aspect | Ce qu'ils font bien | Application Madinia |
|--------|---------------------|---------------------|
| **Pricing** | Transparent dès le début | ✅ Prix visible immédiatement |
| **Onboarding** | Questions pour personnaliser | ✅ Madi pose des questions |
| **CTA** | Doux, pas agressifs | ✅ "Je suis intéressé" vs "Acheter" |

### Transferable UX Patterns

#### Navigation

| Pattern | Source | Application |
|---------|--------|-------------|
| **Tab bar 4-5 items** | iOS HIG + Duolingo | 4 onglets : Accueil, Formations, Blog, Contact |
| **Card-based content** | Notion, App Store | Fiches formations en cards |
| **Progressive disclosure** | Calm | Infos clés d'abord, détails ensuite |

#### Interactions

| Pattern | Source | Application |
|---------|--------|-------------|
| **Floating action button** | Material Design | Bouton Madi flottant |
| **Pull to refresh** | iOS standard | Actualiser formations/blog |
| **Swipe gestures** | iOS HIG | Navigation naturelle |

#### Visuels

| Pattern | Source | Application |
|---------|--------|-------------|
| **Illustrations friendly** | Duolingo | Mascotte Madi, illustrations formations |
| **Couleurs vives + blanc** | Duolingo, Notion | Palette énergique mais aérée |
| **Micro-animations** | Duolingo | Feedback visuel, transitions douces |

### Anti-Patterns to Avoid

| Anti-Pattern | Pourquoi l'éviter | Alternative |
|--------------|-------------------|-------------|
| **Login wall** | Tue la découverte | Exploration libre |
| **Carousel auto** | Perte de contrôle | Scroll manuel |
| **Pop-up intrusif** | Agacement | Madi accessible mais discret |
| **Prix caché** | Méfiance | Prix visible immédiatement |
| **Formulaire long** | Abandon | 2 taps + email uniquement |
| **Dark patterns** | Perte de confiance | Transparence totale |
| **Notifications spam** | Désinstallation | Max 1/semaine |

### Design Inspiration Strategy

#### À Adopter

| Pattern | Raison |
|---------|--------|
| Tab bar iOS standard | Familiarité, efficacité prouvée |
| Cards pour formations | Scannable, touch-friendly |
| Progression visuelle Duolingo | Différenciateur, clarté |

#### À Adapter

| Pattern | Adaptation |
|---------|------------|
| Onboarding Duolingo | Optionnel via Madi |
| Gamification Headspace | V2 seulement |
| Chat Intercom | Madi = coach, pas support |

#### À Éviter

| Pattern | Raison |
|---------|--------|
| Blocage exploration | Contraire à la vision |
| Urgence artificielle | Pas le ton Madinia |
| Upsell agressif | App vitrine, pas e-commerce |

## Design System Foundation

### Design System Choice

**Apple Human Interface Guidelines (HIG) + Personnalisation Madinia**

Pour une app iOS native SwiftUI, le choix optimal est d'utiliser les composants natifs Apple avec une couche de personnalisation Madinia ciblée.

### Rationale for Selection

| Facteur | Décision |
|---------|----------|
| **Plateforme** | iOS native → HIG = standard |
| **Principe "Native first"** | SwiftUI natif, pas de framework tiers |
| **Timeline MVP** | Composants prêts à l'emploi |
| **Équipe** | 1 dev → maintenance simplifiée |
| **UX** | Familiarité utilisateur iOS |

### Implementation Approach

| Élément | Approche |
|---------|----------|
| **Navigation** | TabView SwiftUI natif (4 onglets) |
| **Cards** | SwiftUI natif avec styling Madinia |
| **Boutons** | .buttonStyle() custom Madinia |
| **Couleurs** | Asset Catalog avec palette Madinia |
| **Typo** | SF Pro (système) |
| **Icônes** | SF Symbols + custom Madinia |
| **Animations** | SwiftUI .animation() natif |

### Customization Strategy

#### Design Tokens

| Token | Valeur |
|-------|--------|
| **Primary** | Couleur Madinia principale |
| **Secondary** | Couleur accent |
| **Background** | Blanc / Gris clair |
| **Text** | Noir / Gris foncé |
| **Success** | Vert |
| **Madi** | Couleur spécifique coach IA |
| **Spacing** | xs:4, sm:8, md:16, lg:24, xl:32 |
| **Radius** | sm:8, md:12, lg:16 |

#### Composants Custom

| Composant | Description |
|-----------|-------------|
| **FormationCard** | Card avec infos clés (prix/durée/niveau/date) |
| **ProgressPath** | Visuel Starter→Performer→Master |
| **MadiButton** | FAB flottant pour le coach IA |
| **PreRegistrationSheet** | Bottom sheet pré-inscription 2 taps |
| **BlogArticleCard** | Card article avec CTA formation |

## Defining Experience

### Core Interaction

> **"Découvrir son parcours de formation IA et se pré-inscrire en 2 taps"**

Comme Tinder = "Swipe pour matcher", Madinia Mobile = "Voir son chemin et s'engager instantanément".

### User Mental Model

| Approche actuelle | Frustration | Solution Madinia |
|-------------------|-------------|------------------|
| Site web formations | Trop d'info, pas mobile-friendly | App claire, 5 secondes |
| Google "formation IA" | Trop de choix, pas de confiance | Parcours guidé Madinia |
| Recommandation ami | "Par où commencer?" | Starter→Master visuel |

| Attente utilisateur | Réponse Madinia |
|---------------------|-----------------|
| "Je veux comprendre vite" | Infos clés visibles, pas de scroll |
| "Je veux savoir le prix" | Prix en haut de chaque fiche |
| "Je ne veux pas m'engager" | Exploration sans compte |
| "J'ai besoin d'aide" | Madi disponible mais optionnel |

### Success Criteria

| Critère | Indicateur | Cible |
|---------|------------|-------|
| **Compréhension** | Temps avant 1ère action | < 5 secondes |
| **Confiance** | Consultation fiche complète | > 30 secondes |
| **Conversion** | Pré-inscription complétée | 2 taps max |
| **Aide** | Utilisation Madi | Accessible en 1 tap |
| **Satisfaction** | Abandon pré-inscription | < 10% |

### Experience Mechanics

**Flow : Découverte → Pré-inscription**

1. **INITIATION** — Utilisateur ouvre l'app → Écran Accueil avec ProgressPath visible
2. **EXPLORATION** — Tap formation ou Madi → Fiche détaillée ou recommandation
3. **DÉCISION** — Infos clés visibles (Prix/Durée/Niveau/Date)
4. **ACTION** — Tap 1: "Je suis intéressé" → Tap 2: Email + Envoyer
5. **FEEDBACK** — Animation succès + "On te recontacte sous 24h"

### Screen Map

| Écran | Rôle | Éléments clés |
|-------|------|---------------|
| **Accueil** | Orienter | ProgressPath, Highlights, Accès rapide |
| **Formations** | Choisir | Liste cards, Filtres simples |
| **Fiche Formation** | Décider | Infos clés, Détails, CTA pré-inscription |
| **Blog** | Engager | Articles, CTA vers formations |
| **Contact** | Convertir | Formulaire contextuel |
| **Madi** | Guider | Chat overlay, Recommandations |

## Visual Design Foundation

### Color System

| Token | Usage | Valeur suggérée |
|-------|-------|-----------------|
| **Primary** | CTA, liens, accents | Bleu/Vert Madinia (à définir) |
| **Secondary** | Accents secondaires | Couleur complémentaire |
| **Background** | Fond principal | #FFFFFF |
| **Surface** | Cards, éléments | #F8F9FA |
| **Text Primary** | Texte principal | #1A1A1A |
| **Text Secondary** | Texte secondaire | #6B7280 |
| **Success** | Confirmations | #22C55E |
| **Warning** | Alertes | #F59E0B |
| **Error** | Erreurs | #EF4444 |
| **Madi** | Coach IA | Couleur distinctive |

### Typography System

**Police : SF Pro (Système iOS)**

| Style | Taille | Poids | Usage |
|-------|--------|-------|-------|
| **Large Title** | 34pt | Bold | Titres principaux |
| **Title 1** | 28pt | Bold | Titres sections |
| **Title 2** | 22pt | Bold | Sous-titres |
| **Title 3** | 20pt | Semibold | Noms formations |
| **Headline** | 17pt | Semibold | Labels importants |
| **Body** | 17pt | Regular | Texte courant |
| **Callout** | 16pt | Regular | Infos secondaires |
| **Caption** | 12pt | Regular | Métadonnées |

### Spacing & Layout Foundation

**Unité de base : 4pt**

| Token | Valeur | Usage |
|-------|--------|-------|
| **xs** | 4pt | Espacement minimal |
| **sm** | 8pt | Entre éléments liés |
| **md** | 16pt | Padding cards |
| **lg** | 24pt | Entre sections |
| **xl** | 32pt | Marges écran |

**Rayons de coins :**
- sm: 8pt (boutons)
- md: 12pt (cards)
- lg: 16pt (modals)

### Accessibility Considerations

| Aspect | Implémentation |
|--------|----------------|
| **VoiceOver** | Tous éléments labellisés |
| **Dynamic Type** | Tailles iOS respectées |
| **Contraste** | WCAG AA (≥4.5:1) |
| **Touch targets** | 44x44pt minimum |
| **Reduce Motion** | Animations désactivables |

## Design Direction Decision

### Chosen Direction

**"Duolingo Meets Premium Formation"** — Interface friendly mais professionnelle, aérée avec couleurs vives mais pas enfantines.

### Design Rationale

| Décision | Raison |
|----------|--------|
| **Tab bar iOS** | Familiarité utilisateur, pas de courbe d'apprentissage |
| **FAB Madi** | Toujours accessible sans bloquer l'écran |
| **Cards aérées** | Règle 5 secondes, lisibilité optimale |
| **Infos en badge** | Décision rapide sans scroll |
| **Overlay chat** | Contexte préservé, navigation fluide |

### Implementation Approach

| Élément | Implémentation |
|---------|----------------|
| **Layout** | Cards full-width, espacées (lg: 24pt) |
| **Navigation** | TabView SwiftUI standard |
| **CTA** | Boutons arrondis (sm: 8pt), couleur primary |
| **Cards** | Coins arrondis (md: 12pt), ombre légère |
| **Madi** | FAB flottant bas-droite + sheet overlay |
| **Infos clés** | HStack badge horizontal en haut des fiches |
| **Animations** | .animation(.easeInOut) SwiftUI natives |

### Key Screens Layout

| Écran | Structure |
|-------|-----------|
| **Accueil** | Header + ProgressPath + Highlights grid + TabBar |
| **Formations** | Liste ScrollView + FormationCard |
| **Fiche** | Image + InfoBadge + Description + CTA sticky |
| **Blog** | Liste articles + CTA formation lié |
| **Contact** | Formulaire contextuel pré-rempli |
| **Madi** | FAB → Sheet overlay avec chat |

## User Journey Flows

### Flow 1: Lucas Découvre (Acquisition)

**Entrée:** Deep link Instagram → App Store
**Succès:** Pré-inscription en 2 taps

```
Pub Instagram → App Store → Télécharge → Accueil → Comprend parcours?
  → Oui → Tap Starter → Fiche → Infos clés → Intéressé?
      → Oui → "Je suis intéressé" → Email → Envoyer → ✅ Confirmation
  → Non → Active Madi → Madi explique → Tap Starter...
```

### Flow 2: Sophie Trouve (Deep Link)

**Entrée:** Deep link web → Fiche formation directe
**Succès:** Pré-inscription avec contexte

```
Lien WhatsApp → App installée?
  → Oui → Universal Link → Fiche Performer direct
  → Non → App Store → Install → Fiche Performer
→ Infos clés → Besoin plus d'info?
  → Oui → Blog → Article → CTA → Pré-inscription
  → Non → Pré-inscription directe → ✅ Confirmation
```

### Flow 3: Marc Évalue (Madi B2B)

**Entrée:** QR code événement → Madi direct
**Succès:** Demande de devis contextualisée

```
QR Code → App Store → Accueil → Active Madi
→ "Quel objectif?" → "Former équipe"
→ "Combien?" → "5 personnes, débutants"
→ Recommande Starter → Explore parcours
→ Lit article ROI → Contact contextuel
→ Formulaire pré-rempli → ✅ Demande devis
```

### Flow 4: Lucas Revient (Rétention)

**Entrée:** Push notification
**Succès:** Conversion vers paiement web

```
Push J+3 → Ouvre?
  → Non → Push J+7 → Ouvre?
  → Oui → Fiche Starter → "Plus que 3 places"
→ Convaincu? → "Finaliser" → Redirect web paiement → ✅ Inscrit
```

### Journey Patterns

| Catégorie | Pattern | Usage |
|-----------|---------|-------|
| **Navigation** | Tab switching | Entre onglets principaux |
| **Navigation** | Push to detail | Liste → Fiche |
| **Navigation** | Sheet overlay | Madi, pré-inscription |
| **Decision** | Quick action button | CTA visible sans scroll |
| **Decision** | Madi assist | Aide optionnelle |
| **Feedback** | Success animation | Après pré-inscription |
| **Feedback** | Badge info | Prix/Durée/Niveau |

### Flow Optimization Principles

| Optimisation | Impact |
|--------------|--------|
| **Pas de login** | -3 étapes au flow |
| **Infos clés en haut** | Décision sans scroll |
| **2 taps pré-inscription** | Conversion max |
| **Contexte auto** | Contact enrichi |
| **Madi optionnel** | Pas de blocage |

## Component Strategy

### Design System Components (SwiftUI Natif)

| Composant | Usage Madinia |
|-----------|---------------|
| **TabView** | Navigation 4 onglets |
| **NavigationStack** | Push vers fiches détail |
| **ScrollView** | Listes formations, blog |
| **Button** | CTA avec .buttonStyle() custom |
| **TextField** | Email, messages contact |
| **Sheet** | Madi overlay, pré-inscription |

### Custom Components

| Composant | Purpose | Priority |
|-----------|---------|----------|
| **FormationCard** | Afficher formation en liste | P1 |
| **ProgressPath** | Visualiser Starter→Performer→Master | P1 |
| **InfoBadge** | Afficher prix/durée/niveau/date | P1 |
| **MadiButton** | FAB accès coach IA | P2 |
| **PreRegistrationSheet** | Pré-inscription 2 taps | P1 |
| **MadiChatView** | Interface chat IA | P2 |

### Component Specifications

**FormationCard**
- Content: Image, titre, InfoBadge, date
- States: Default, Pressed, Loading
- Variants: Compact (liste), Featured (accueil)

**ProgressPath**
- Content: 3 étapes connectées visuellement
- Actions: Tap étape → Navigation fiche
- Orientation: Horizontal (défaut)

**InfoBadge**
- Content: Prix | Durée | Niveau | Date
- Variants: Inline (fiche), Compact (card)

**MadiButton**
- Position: Flottant bas-droite, au-dessus TabBar
- States: Default, Pressed, With notification badge

**PreRegistrationSheet**
- Height: .medium detent (~40%)
- States: Input, Loading, Success, Error

### Implementation Roadmap

| Phase | Composants | Raison |
|-------|------------|--------|
| **P1 Core** | FormationCard, InfoBadge, ProgressPath, PreRegistrationSheet | MVP flows |
| **P2 Madi** | MadiButton, MadiChatView | Coach IA |
| **P3 Polish** | BlogArticleCard, ContextualContactForm | Optimisation |

## UX Consistency Patterns

### Button Hierarchy

| Type | Usage | Style SwiftUI |
|------|-------|---------------|
| **Primary** | CTA principaux (Pré-inscription, Contacter) | `.borderedProminent` + Madinia Purple |
| **Secondary** | Actions secondaires (Explorer, Voir plus) | `.bordered` |
| **Tertiary** | Liens textuels, navigation | `.plain` + couleur accent |

### Feedback Patterns

| Event | Feedback | Duration |
|-------|----------|----------|
| Tap button | Haptic light | Immédiat |
| Pré-inscription success | Haptic success + animation ✓ | 2s |
| Error | Haptic error + shake | 0.5s |
| Pull-to-refresh | Spinner natif | Variable |
| Madi typing | Animation dots | Variable |

### Form Patterns

| Pattern | Usage |
|---------|-------|
| **Floating label** | Email input (pré-inscription) |
| **Validation inline** | Format email en temps réel |
| **Error state** | Rouge + message sous le champ |
| **Success state** | Check vert inline |

### Navigation Patterns

| Pattern | Usage |
|---------|-------|
| **Tab switch** | Animation système SwiftUI |
| **Push detail** | Standard NavigationStack |
| **Sheet modal** | Pré-inscription, Madi chat |
| **Back** | Chevron gauche standard |

### Madi Patterns

| Pattern | Description |
|---------|-------------|
| **FAB visibility** | Visible sur tous les onglets sauf quand clavier actif |
| **Chat entry** | Sheet .large avec drag indicator |
| **Typing indicator** | 3 dots animés |
| **Message bubble** | User à droite (accent), Madi à gauche (gris) |

## Responsive Design & Accessibility

### Responsive Strategy

| Aspect | Stratégie |
|--------|-----------|
| Plateforme | iOS uniquement (iPhone) |
| Orientation | Portrait uniquement |
| Tailles écran | iPhone SE → iPhone 15 Pro Max |
| Approche | SwiftUI adaptatif natif |

### Device Adaptation

| Taille | Largeur | Adaptation |
|--------|---------|------------|
| iPhone SE/Mini | 375pt | Compacter InfoBadges |
| iPhone Standard | 390pt | Design principal |
| iPhone Pro Max | 430pt | Plus d'espace |

### Accessibility Strategy (WCAG 2.1 AA)

| Catégorie | Implémentation |
|-----------|----------------|
| VoiceOver | Labels accessibles sur tous les éléments |
| Dynamic Type | Support complet via `.font()` natif |
| Contraste | Ratio 4.5:1 minimum |
| Touch targets | Minimum 44×44pt |
| Reduce Motion | Respecter préférences système |

### Testing Strategy

| Type | Méthode |
|------|---------|
| VoiceOver | Test manuel device réel |
| Dynamic Type | Simulateur iOS toutes tailles |
| Contraste | Accessibility Inspector |
| Tailles écran | Simulateur SE → Pro Max |

