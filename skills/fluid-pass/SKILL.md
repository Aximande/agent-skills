---
name: fluid-pass
description: >
  Repasse « feel » d'une interface web, à la Apple : réponse instantanée,
  gestes 1:1, springs interruptibles, momentum, matériaux, typographie
  optique, reduced-motion. Compile les principes des WWDC en checks
  vérifiables (grep + pilotage de la vraie app) et prouve l'interruptibilité
  en attrapant une animation en vol. Use when: « passe fluid-pass », « rends
  cette UI plus fluide / plus Apple », « audite le feel de ce drag / sheet /
  carousel », ou /fluid-pass sur un repo web. Uniquement sur demande
  explicite.
license: MIT
---

# Fluid Pass

Repasse sur la **mécanique du ressenti** d'une UI web — ce qui se passe
entre le doigt et le pixel. Pas le polish visuel statique
(interfaces/better-*), pas la perf d'animation (fixing-motion-performance),
pas l'a11y générale (fixing-accessibility), pas l'identité anti-template
(baseline-ui) : renvoyer vers eux, ne pas dupliquer. Trois principes :

- **Le déterministe d'abord** : une règle greppable se pose en check,
  jamais en prose.
- **Un finding de feel est prouvé** — un grep, un repro piloté ou une
  mesure — jamais « ça manque de fluidité ».
- **Validité constante** : gate différentiel (lint/tests/build) ; sans
  filet → mode rapport (safety-net d'abord).

## 0. Préflight

- Stack : React/Next/vanilla ? Lib d'animation présente (Motion,
  react-spring, GSAP, CSS pur) ? **Context7 sur la lib qui est là** —
  aucune API affirmée de mémoire.
- **Inventaire des surfaces gestuelles**, chacune avec fichier:ligne :
  drags, swipes, sheets/drawers, carousels, scroll custom, contrôles
  pressables. C'est la carte de l'audit ; une surface non listée n'est pas
  auditée.
- Baseline par **liste nommée** des violations aux checks du §1.
- Filet tests/build relevé ; branche `fluid/<YYYY-MM-DD>` ; WIP utilisateur
  non commité sur un fichier cible → les fixes de ce fichier partent au
  rapport, jamais en commit.

## 1. Checks déterministes (le grep est la preuve)

Fixes mécaniques, commits gatés :

- **reduced-motion** : toute animation/transition sans équivalent sous
  `@media (prefers-reduced-motion: reduce)` (cross-fade, pas de slide ni
  d'overshoot). `backdrop-filter` sans repli
  `prefers-reduced-transparency`. L'absence du bloc *est* le finding.
- **Feedback à l'appui** : contrôle pressable sans état `:active` (ou
  équivalent pointer-down) — le feedback qui attend le `click` est mort.
  Élément interactif custom sans `touch-action: manipulation`.
- **Durée fixe sur surface manipulable** : `transition`/`@keyframes` sur un
  élément aussi piloté au pointeur (sheet, drag) — non interruptible par
  construction, à remplacer par une animation repartant de la valeur
  courante.
- **Typo optique** : un seul `letter-spacing` global toutes tailles ;
  display sans tracking négatif ; corps loin de 0 ; spacing/typo en `px`
  fixes qui ignorent le réglage de taille de texte utilisateur
  (`rem`/`em`).
- **Compositeur** : animation de `top/left/width/height` là où
  `transform`/`opacity` suffisent.
- **Matériaux** : deux surfaces translucides empilées ; texte gris plat
  posé sur une surface translucide.

## 2. Audit — ce que le grep ne voit pas

Chaque finding cite fichier:ligne + la réécriture proposée ou le repro :

- **Drag** : snap au centre au lieu du grab offset ; pas de
  `setPointerCapture` ; pas d'historique de vélocité (impossible de rendre
  la vélocité au release) ; pas d'hystérésis (~10 px) avant d'engager une
  direction.
- **Release** : seam visible entre le doigt et l'animation (vélocité non
  transmise) ; snap au point le plus proche de la *position* au lieu de la
  **projection du momentum**. Références :
  `projeté = position + (v/1000)·d/(1−d)` avec `d ≈ 0.998` ;
  vélocité relative = `v / (cible − courant)` ;
  rubberband = `(x·dim·c)/(dim + c·|x|)` avec `c ≈ 0.55` — jamais de hard
  stop aux bords.
- **Interruptibilité** : input verrouillé pendant une transition ;
  animation démarrée depuis la valeur *cible* au lieu de la valeur de
  présentation (saut visible) ; inversion en hard-cut de vélocité.
- **Espace** : entrée et sortie par des chemins différents ;
  menu/popover/sheet sans `transform-origin` ancré au déclencheur.
- **Springs** : défaut = amorti critique (damping 1.0) ; du bounce
  (~0.8) *uniquement* après un geste à momentum. Valeurs de référence
  Apple : déplacement 1.0/0.4, rotation 0.8/0.4, sheet 0.8/0.3
  (damping/response).

## 3. Preuve dynamique — le feel piloté

Uniquement si l'app tourne localement (réutiliser la découverte de stack de
proof-run) ; sinon les findings partent au rapport, non prouvés et dits
tels.

- Piloter via agent-browser : presser (le feedback part-il à l'appui ?),
  dragger la surface clé, relâcher avec vitesse (l'élément continue-t-il
  sur sa lancée ?), et **attraper l'animation en vol** pour l'inverser —
  suit-elle le pointeur ou finit-elle sa course d'abord ?
- Enregistrer l'interaction et la relire image par image : les défauts de
  seam et de saut sont invisibles à pleine vitesse.
- Un fix de feel n'entre en commit que si le repro avant/après montre la
  différence ; sinon rapport.

## Livraison

1. Commits par nature : checks §1 / fixes §2-§3 gatés — le structurel
   (refonte gestuelle, architecture d'animation) reste au rapport.
2. **Lib de springs jamais imposée** — elle change les deps du repo.
   Proposer au rapport, avec ce qu'elle remplacerait (les transitions CSS
   bricolées du repo).
3. Rapport `.fluid-pass/rapport-<date>.md` (non commité, non tracké) :
   inventaire des surfaces, findings fichier:ligne, repros avant/après,
   propositions, stats.
4. Commits sans Co-Authored-By ni mention d'IA.

Place au pipeline : transverse — après frontend-dev/ui-skills, avant
cleanup-pass sur un produit UI. Perf d'animation →
fixing-motion-performance ; a11y → fixing-accessibility ; identité visuelle
→ baseline-ui.
