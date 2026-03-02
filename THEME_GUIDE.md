# Madin.IA — Guide du Thème (Design System)

> Référence complète pour la maquette Figma

---

## 1. Couleurs de marque

| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| **Gold** | `#EED076` | `238, 208, 118` | Couleur principale, accent en dark mode |
| **Violet** | `#582586` | `88, 37, 134` | Couleur secondaire, accent en light mode |
| **Dark Gray** | `#0A121B` | `10, 18, 27` | Fond sombre, texte sur fond gold |

### Couleurs adaptatives (Light / Dark)

| Token | Light Mode | Dark Mode |
|-------|-----------|-----------|
| **Accent** | `#582586` (violet) | `#EED076` (gold) |
| **Violet** | `#582586` | `#B48CDC` (180, 140, 220) |
| **Dark Gray** | `#0A121B` | `#FFFFFF` (blanc) |

### Couleurs sémantiques

| Token | Couleur | Usage |
|-------|---------|-------|
| Niveau Débutant | `green` (system) | Badge niveau starter |
| Niveau Intermédiaire | `orange` (system) | Badge niveau performer |
| Niveau Avancé | `red` (system) | Badge niveau master |
| Tier Bronze | `rgba(204, 128, 51)` | Récompenses |
| Tier Argent | `gray` (system) | Récompenses |
| Tier Or | `#EED076` | Récompenses |

### Surfaces (iOS system) — Valeurs hex pour Figma

| Token | Light Mode | Dark Mode |
|-------|-----------|-----------|
| **Surface Background** | `#FFFFFF` | `#000000` |
| **Card Background** | `#F2F2F7` | `#1C1C1E` |
| **Elevated Background** | `#F2F2F7` | `#1C1C1E` |
| **Grouped Background** | `#F2F2F7` | `#000000` |
| **Primary Text** | `#000000` | `#FFFFFF` |
| **Secondary Text** | `#3C3C43` (60%) | `#EBEBF5` (60%) |

> Note : Le thème par défaut est **Dark Mode**, donc les fonds principaux sont `#000000` (fond de page) et `#1C1C1E` (cartes/élevé).

---

## 2. Dégradés (Gradients)

| Nom | Type | Couleurs | Direction |
|-----|------|----------|-----------|
| **Brand Gradient** | Linear | Violet → Gold | ↘ (topLeading → bottomTrailing) |
| **Image Overlay** | Linear | Transparent → DarkGray 80% | ↓ (top → bottom) |
| **Placeholder** | Linear | Violet 60% → Gold 40% | ↘ (topLeading → bottomTrailing) |

---

## 3. Typographie

**Police : SF Pro (police système iOS)** — Aucune police custom n'est utilisée.

**Téléchargement :** https://developer.apple.com/fonts/

| Token | Taille | Poids | Usage |
|-------|--------|-------|-------|
| `largeTitle` | 28 pt | **Bold** | Titres principaux de page |
| `title` | 22 pt | **Bold** | Titres de section |
| `title2` | 20 pt | **Semibold** | Sous-titres |
| `headline` | 17 pt | **Semibold** | En-têtes de carte |
| `body` | 17 pt | Regular | Texte courant |
| `callout` | 16 pt | Regular | Labels, descriptions |
| `subheadline` | 15 pt | Regular | Texte secondaire |
| `caption` | 12 pt | Regular | Badges, métadonnées |
| `caption2` | 11 pt | Regular | Petit texte, timestamps |
| Splash title | 36 pt | **Bold** | Logo texte sur splash screen |

---

## 4. Espacement (grille de 4pt)

| Token | Valeur |
|-------|--------|
| `xxs` | 4 pt |
| `xs` | 8 pt |
| `sm` | 12 pt |
| `md` | 16 pt |
| `lg` | 24 pt |
| `xl` | 32 pt |
| `xxl` | 48 pt |

---

## 5. Rayons de coins (Border Radius)

| Token | Valeur |
|-------|--------|
| `sm` | 8 pt |
| `md` | 12 pt |
| `lg` | 16 pt |
| `xl` | 20 pt |

---

## 6. Ombres (Shadows)

| Style | Opacité | Rayon de flou | Offset X | Offset Y |
|-------|---------|---------------|----------|----------|
| **Card** | 10% noir | 4 pt | 0 | 2 |
| **Elevated** | 15% noir | 8 pt | 0 | 4 |
| **FAB** (bouton flottant) | 30% violet | 8 pt | 0 | 4 |

---

## 7. Tailles de composants

| Composant | Dimensions |
|-----------|-----------|
| Carte formation | 170 × 240 pt |
| Carte highlight | 320 × 200 pt |
| Carte article (hauteur) | 320 pt |
| Image hero | 120 pt (hauteur) |
| Image hero highlight | 200 pt (hauteur) |
| Logo splash screen | 140 × 140 pt (coin arrondi `xl` = 20pt) |
| Safe area tab bar | 100 pt (iPhone) / 24 pt (iPad) |

---

## 8. Composants UI (Chips & Pills)

### Gold Pill
- Texte : `caption` semibold
- Couleur texte : `#0A121B` (darkGrayFixed)
- Fond : couleur accent
- Padding : `xs` horizontal (8pt), `xxs` vertical (4pt)
- Forme : Capsule

### Violet Chip
- Texte : `caption`
- Couleur texte : violet
- Fond : violet à 15% opacité
- Padding : `sm` horizontal (12pt), `xs` vertical (8pt)
- Forme : Capsule

---

## 9. Animations

| Token | Type | Durée | Paramètres |
|-------|------|-------|------------|
| `quick` | easeOut | 0.15s | — |
| `standard` | easeInOut | 0.25s | — |
| `gentle` | easeOut | 0.35s | — |
| `spring` | spring | — | response: 0.35, damping: 0.7 |
| `springLight` | spring | — | response: 0.3, damping: 0.8 |
| `springBouncy` | spring | — | response: 0.4, damping: 0.6 |
| `list` | easeOut | 0.3s | — |
| `fade` | easeInOut | 0.2s | — |

### Interactions
- **Press Scale** : réduction à 95% au toucher
- **Staggered Appearance** : fade + glissement, décalé par index
- **Shimmer** : dégradé blanc animé (loading)

---

## 10. Thème par défaut

Le thème par défaut de l'app est le **Dark Mode**.

---

## 11. Assets & Logo

### Localisation des fichiers

```
MadiniaApp/Assets.xcassets/
├── AccentColor.colorset/        → #EED076 (gold)
├── AppIcon.appiconset/          → Icône de l'app (toutes tailles)
├── madinia-logo.imageset/       → Logo principal
│   └── madinia-logo.png
├── splash-logo.imageset/        → Logo du splash screen
│   └── splash-logo.png
└── madinia-tab-icon.imageset/   → Icône pour la tab bar (template)
    └── madinia-tab-icon.png
```

### Utilisation des logos

| Asset | Emplacement | Taille | Style |
|-------|-------------|--------|-------|
| `splash-logo` | Splash screen | 140 × 140 pt | Coins arrondis 20pt |
| `madinia-logo` | Général | Variable | — |
| `madinia-tab-icon` | Tab bar | Standard iOS | Rendu en template (teinté) |
| `AppIcon` | Icône système | Toutes tailles Apple | — |

**AppIcon haute résolution (1024px) :**
`MadiniaApp/Assets.xcassets/AppIcon.appiconset/1024.png`

---

## Résumé rapide pour Figma

```
Couleurs principales :
  Gold       #EED076
  Violet     #582586
  Dark Gray  #0A121B
  Violet clair (dark mode) #B48CDC

Police : SF Pro (système)

Grille d'espacement : multiples de 4pt (4, 8, 12, 16, 24, 32, 48)

Coins : 8, 12, 16, 20

Thème par défaut : Dark
```
