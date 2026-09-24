---
name: fluid-pass
description: >
  Repasse « feel » d'une interface web, à la Apple : réponse instantanée,
  gestes 1:1, springs interruptibles, momentum, matériaux, typographie
  optique, reduced-motion. Compile les principes des WWDC en checks
  vérifiables (grep + pilotage de la vraie app) et prouve l'interruptibilité
  en attrapant une animation en vol. Mode amélioration (radar
  anti-template, auto-critique du plan) sur demande. Use when: « passe
  fluid-pass », « rends cette UI plus fluide / plus Apple », « rends ce
  design moins générique », « audite le feel de ce drag / sheet /
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
- Le savoir complet (formules, valeurs, principes, processus de review)
  vit dans `REFERENCE.md`, même dossier — charger la **section utile** au
  moment du besoin, pas tout d'un coup. Le SKILL reste le protocole.
- **Inventaire des surfaces gestuelles**, chacune avec fichier:ligne :
  drags, swipes, sheets/drawers, carousels, scroll custom, contrôles
  pressables. C'est la carte de l'audit ; une surface non listée n'est pas
  auditée.
- Baseline par **liste nommée** des violations aux checks du §1.
- Filet tests/build relevé ; branche `fluid/<YYYY-MM-DD>` ; WIP utilisateur
  non commité sur un fichier cible → les fixes de ce fichier partent au
  rapport, jamais en commit.

## 1. Checks déterministes (le grep est la preuve)

Fixes mécaniques, commits gatés. Chaque propriété se greppe sous ses
**trois graphies** — kebab (`touch-action`), camelCase (`touchAction`,
styles inline/CSS-in-JS) et utilitaires Tailwind (`touch-*`,
`motion-reduce:`, `tracking-*`, `backdrop-blur-*`, `transition-*`,
`active:`) : un grep mono-graphie rend des verdicts faux (payé au
rodage). Les noms de libs se greppent avec frontières de mots (`grep -w` :
`embla` matche « vrais**embla**ble » — payé aussi). Et ne citer une
feuille CSS qu'après avoir vérifié qu'elle est **réellement importée**
(une feuille morte → cleanup-pass, pas un finding feel).

- **reduced-motion** : toute animation/transition sans équivalent sous
  `@media (prefers-reduced-motion: reduce)` (cross-fade, pas de slide ni
  d'overshoot). `backdrop-filter` sans repli
  `prefers-reduced-transparency`. L'absence du bloc *est* le finding.
- **Feedback à l'appui** : contrôle pressable sans état `:active` (ou
  équivalent pointer-down) — le feedback qui attend le `click` est mort.
  Élément interactif custom sans `touch-action: manipulation`. Vérifier
  aussi qu'une `transition: all` ne lisse pas le `transform` du
  `:active` : un press adouci sur 150 ms est un press mou.
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

- **Drag** : snap au centre au lieu du grab offset ; pas d'historique de
  vélocité (impossible de rendre la vélocité au release) ; pas
  d'hystérésis (~10 px) avant d'engager une direction. L'absence de
  `setPointerCapture` seule n'est pas un bug : à la souris, la capture
  implicite + listeners `window` font le travail — le trou réel est le
  `pointercancel` tactile, à juger avec `touch-action` (proposition de
  robustesse, pas finding).
- **Release** : seam visible entre le doigt et l'animation (vélocité non
  transmise) ; reverse/commit décidé sur la *position* au lieu du
  **signe de la vélocité** ; snap au point le plus proche de la position
  au lieu de la **projection du momentum**. Références :
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
  (~0.8) *uniquement* après un geste à momentum. Un mouvement 2D se
  décompose en springs X/Y indépendants (une seule spring sur la distance
  désynchronise). Valeurs de référence Apple : déplacement 1.0/0.4,
  rotation 0.8/0.4, sheet 0.8/0.3 (damping/response).
- **Lib d'animation présente** (framer-motion/Motion…) :
  `AnimatePresence mode="wait"` sur une navigation = non-interruptible
  par design — l'entrant attend la fin du sortant, mesurer la latence
  appui→contenu ; absence de `MotionConfig reducedMotion="user"` =
  reduced-motion non couvert côté JS (un bloc CSS ne neutralise pas les
  animations inline) ; `reducedMotion="always"` dans une branche
  print/export est un usage légitime, pas un finding.
- **Matériaux & retours** : un modal se scrime (dim), un panneau
  parallèle non-bloquant ne se scrime pas ; une surface de verre se
  *matérialise* (blur + scale ensemble), elle ne fade pas ; texte sur
  matériau = contraste + graisse, la couleur vit sur une couche pleine ;
  bord de scroll en fondu plutôt que bordure 1 px. Son/haptique/visuel
  sur la **même frame**, cause évidente, réservés aux moments qui
  comptent.

Sur une surface auditée dépassant ~1 500 lignes : **second passage par un
agent frais** — deux audits indépendants trouvent des ensembles
partiellement disjoints (mesuré au rodage) ; le rapport est l'union
arbitrée, chaque finding du second passage revérifié au vrai code.

## 3. Preuve dynamique — le feel piloté

Uniquement si l'app tourne localement (réutiliser la découverte de stack de
proof-run) ; sinon les findings partent au rapport, non prouvés et dits
tels.

- Piloter via agent-browser : presser (le feedback part-il à l'appui ?),
  dragger la surface clé, relâcher avec vitesse (l'élément continue-t-il
  sur sa lancée ?), et **attraper l'animation en vol** pour l'inverser —
  suit-elle le pointeur ou finit-elle sa course d'abord ?
- **Instrumenter par `eval`** : listener d'input horodaté +
  échantillonnage du DOM toutes les 100-150 ms. La latence input→contenu,
  les inputs perdus et un lockout se mesurent ainsi, en chiffres, sans
  profiler ni vidéo (technique validée au rodage).
- Enregistrer l'interaction et la relire image par image : les défauts de
  seam et de saut sont invisibles à pleine vitesse.
- Un fix de feel n'entre en commit que si le repro avant/après montre la
  différence ; sinon rapport.

## 4. Mode amélioration — sur demande seulement

Quand la demande est « améliore ce design / rends-le moins générique »
(pas un simple audit) : d'abord §0-§3, puis travailler comme un studio.

- **Ancrer dans le produit** : nommer le public, le job unique de
  l'écran, et l'élément signature — celui dont on se souviendra. La
  hardiesse se dépense à un seul endroit, tout le reste se tait.
- **Radar anti-template** — les looks qui dominent l'UI générée sont des
  défauts, pas des choix : crème chaud + serif contrastée + accent
  terracotta ; near-black + un accent acide (vert/vermillon) ; broadsheet
  de filets hairline, radius zéro, colonnes denses. Idem le héros « gros
  chiffre sur petit label + gradient » et la numérotation 01/02/03 sur du
  contenu non séquentiel. Une palette ou un layout sans raison enracinée
  dans le produit se révise.
- **Auto-critique du plan avant de le proposer** : « ce plan
  sortirait-il identique pour un autre produit ? » Si oui, le réviser et
  dire ce qui a changé ; s'il est déjà spécifique, le dire aussi.
- Séquencer : accessibilité → conventions → craft → polish. Ne pas
  sur-critiquer un design fort ; ne pas aplatir la personnalité — si les
  fixes rendent le design indiscernable d'un template, c'est trop loin.
- Chevauchement assumé avec baseline-ui : baseline-ui pose le plancher
  anti-slop à la génération ; ce mode juge et redresse un design
  existant.

## Références à la demande (HIG)

Les Human Interface Guidelines ne se vendorent pas (droits Apple,
péremption) et ne se citent pas de mémoire : **fetcher la page au moment
du besoin** sur `developer.apple.com/design/human-interface-guidelines/<page>`
selon la surface auditée — `gestures`, `motion`, `materials`,
`typography`, `feedback`, `drag-and-drop`, `sheets`, `menus` — et citer
la page fetchée dans le finding.

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
