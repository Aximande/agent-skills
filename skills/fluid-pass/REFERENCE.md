# Fluid Pass — Référence

La mine complète des deux sources du skill, distillée et traduite pour le
web. Le `SKILL.md` est le protocole (quoi vérifier, dans quel ordre, avec
quelle preuve) ; ce fichier est le savoir (pourquoi, comment, avec quelles
valeurs). Charger la section utile au moment du besoin — pas tout d'un coup.

Sources : les conférences design d'Apple distillées par le skill
`apple-design` (*Designing Fluid Interfaces* WWDC 2018, *The Details of UI
Typography* WWDC 2020, *Designing Audio-Haptic Experiences*, *Principles
of Great Design* WWDC 2026), et le processus de review de
[dickwu/apple-design-skill](https://github.com/dickwu/apple-design-skill)
(HIG). Le texte des HIG appartient à Apple : rien n'est vendoré ici, voir
§V pour le routage à la demande.

---

## I. La mécanique du mouvement

Le fil rouge : une interface est vivante quand le mouvement **part de la
valeur affichée à l'écran, hérite de la vélocité du geste, projette le
momentum, et peut être attrapée et inversée à tout instant**. Les springs
sont l'outil naturel de tout ça — interruptibles et sensibles à la
vélocité par construction.

### 1. Réponse — tuer la latence

Dès que le lag apparaît, la sensation de manipulation directe « tombe de
la falaise ». Tout le reste se construit là-dessus.

- Réagir au **pointer-down**, pas au release. Un bouton s'allume à
  l'appui ; un feedback qui attend le `click` est mort.
- Auditer chaque latence du chemin d'entrée : debounces, timers
  artificiels, attentes de transition, délai de tap ~300 ms
  (`touch-action: manipulation`). Tout ce qui n'est pas essentiel est une
  régression.
- Le feedback est **continu pendant le geste**, pas seulement à la fin :
  un drag, un slider, un drawer suivent le pointeur 1:1 du début à la fin.

```css
/* Le feedback vit sur l'appui, et il est instantané */
.button:active { transform: scale(0.97); transition: transform 100ms ease-out; }
```

Piège croisé (payé au rodage) : un `transition: all 150ms` sur le même
élément lisse le `transform` du `:active` — le press devient mou. Lister
les propriétés transitionnées et en exclure `transform` (ou ≤ 50 ms).

### 2. Manipulation directe — 1:1

« Le doigt et le contenu bougent ensemble. »

- L'élément reste collé au pointeur **en respectant l'endroit où il a été
  saisi** (grab offset). Recentrer sous le pointeur casse l'illusion.
- Pointer Events + `setPointerCapture` pour suivre hors des bounds — à la
  souris, la capture implicite pendant un drag bouton-enfoncé + listeners
  `window` font aussi le travail ; le trou réel est le `pointercancel`
  tactile (d'où `touch-action: none` sur les surfaces draggées).
- Tenir un **historique position/temps** des derniers `pointermove` : la
  vélocité au release en dépend (§5).

```js
el.addEventListener("pointerdown", (e) => {
  el.setPointerCapture(e.pointerId);
  const grabOffset = e.clientY - el.getBoundingClientRect().top; // où on a saisi
  // … historique {y, t} pour la vélocité
});
```

### 3. Interruptibilité — le principe le plus important

« La pensée et le geste sont parallèles. » Toute animation doit pouvoir
être attrapée et redirigée à tout instant : un modal qui se ferme et
qu'on rattrape suit le doigt — il ne finit pas de se fermer d'abord.

- **Jamais de lockout d'input** pendant une transition.
- Toujours animer **depuis la valeur de présentation** (l'état affiché à
  l'écran), jamais depuis la valeur cible — sinon saut visible à
  l'interruption.
- Pas de `transition`/`@keyframes` CSS sur ce qui est piloté au geste :
  une durée fixe ne s'attrape pas en vol. Les springs repartent de la
  valeur courante par défaut.
- À l'inversion, **fondre la vélocité**, pas la couper net (le « mur de
  briques ») : choisir une lib de springs qui re-cible en conservant la
  vélocité (l'équivalent web des *additive animations* d'iOS).
- Décomposer un mouvement 2D en **springs X et Y indépendantes** : une
  seule spring sur la distance désynchronise quand X et Y ont des
  vélocités différentes.

### 4. Springs — le comportement plutôt que l'animation

« L'animation est une conversation avec l'objet, pas un script. » Apple a
remplacé le triplet physique (masse/raideur/amortissement) par deux
paramètres de designer :

- **Damping ratio** — contrôle le rebond. `1.0` = amorti critique, aucun
  overshoot. `< 1.0` = rebond, d'autant plus bas que c'est rebondissant.
- **Response** — vitesse d'atteinte de la cible, en secondes. Ce n'est
  **pas une durée** : le temps de pose émerge des paramètres.

Défauts : partir à damping `1.0` partout ; du bounce (~`0.8`)
**uniquement quand le geste portait du momentum** (flick, throw,
release de drag). Un overshoot sur un menu qui vient de fondre à l'écran
est faux ; sur une carte qu'on a lancée, il est juste.

Valeurs qu'Apple ship réellement :

| Interaction | Damping | Response |
| --- | --- | --- |
| Déplacement / reposition (PiP) | 1.0 | 0.4 |
| Rotation | 0.8 | 0.4 |
| Drawer / sheet | 0.8 | 0.3 |

Correspondance web (Motion / Framer Motion) : l'API `bounce` + `duration`
mappe damping + response. Style maison sûr : `bounce: 0` partout par
défaut, du bounce seulement après momentum.

```js
import { animate } from "motion";
animate(el, { y: 0 },      { type: "spring", bounce: 0,   duration: 0.4 }); // défaut
animate(el, { y: target }, { type: "spring", bounce: 0.2, duration: 0.4 }); // après un flick
```

### 5. Handoff de vélocité — la couture drag→animation

À la fin du geste, l'animation **continue à la vélocité exacte du
doigt** : aucune couture visible. C'est le détail qui sépare « fluide »
de « correct ».

```
vélocitéRelative = vélocitéGeste / (cible − valeurCourante)
```

Exemple : élément à y=50, cible y=150 (100 px restants), doigt à 50 px/s
→ vélocité de spring = 0.5. Motion/Framer prennent la vélocité absolue en
px/s directement (option `velocity`).

Au release, **le signe de la vélocité décide** reverse vs commit — pas la
position. Un sheet à 80 % ouvert qu'on pousse vers le bas se ferme.

### 6. Projection du momentum — animer vers où va le geste

« Un petit input, un grand output. » Ne pas snapper au point le plus
proche de la *position* de release : **projeter la position de repos**
depuis la vélocité (comme la décélération de scroll), puis snapper à la
cible la plus proche du point projeté.

```js
// La fonction exacte d'Apple (decay exponentiel — PAS v²/(2·décél))
// decelerationRate ≈ 0.998 (scroll normal) ; 0.99 (plus sec)
function project(vInitiale /* px/s */, decelerationRate = 0.998) {
  return (vInitiale / 1000) * decelerationRate / (1 - decelerationRate);
}
const pointProjeté = position + project(vélocitéRelease);
const cible = snapLePlusProche(pointProjeté);
animateSpringVers(cible, { velocity: vélocitéRelease }); // puis handoff (§5)
```

C'est le comportement standard des bons bottom-sheets et carousels
(Vaul, Embla).

### 7. Cohérence spatiale

« Ce qui disparaît d'un côté revient par où c'est parti. »

- **Entrée et sortie par le même chemin.** Entre par la droite → sort par
  la droite. Entre-droite/sort-bas déconnecte.
- **Ancrer au déclencheur** : menu, popover, sheet naissent de l'élément
  qui les a ouverts — `transform-origin` sur le déclencheur, pas le
  centre.
- **Miroiter l'easing** des transitions réversibles (points de contrôle
  cubic-bézier inverses aller/retour).

### 8. Hint — les frames intermédiaires pointent vers l'issue

L'humain prédit l'état final depuis la trajectoire. Le mouvement
intermédiaire télégraphie la destination (les modules de Control Center
« grandissent vers le doigt ») — pas une interpolation aveugle.

### 9. Rubber-banding — des bords souples

Au bord, résister progressivement au lieu de bloquer net. Un arrêt dur
lit « gelé » ; une résistance continue lit « vivant, mais il n'y a rien
de plus ici ».

```js
// Plus on dépasse, moins l'élément suit — les choses réelles ralentissent avant de s'arrêter
function rubberband(dépassement, dimension, c = 0.55) {
  return (dépassement * dimension * c) / (dimension + c * Math.abs(dépassement));
}
```

### 10. Le détail des gestes — la checklist du « feel »

- **Tap** : allumer au touch-*down* (instantané), committer au
  touch-*up* ; ~10 px de tolérance autour de la cible ; annulable en
  glissant hors puis re-annulable en revenant.
- **Drag/swipe** : seuil d'hystérésis (~10 px) avant d'engager une
  direction, puis 1:1.
- **Détecter tous les gestes plausibles en parallèle** dès le premier
  move, puis annuler franchement les perdants. Éviter les recognizers qui
  ne rapportent qu'un état final (`swipeleft`-style) — ils jettent le
  tracking continu (l'HTML5 drag&drop est dans ce cas).
- **Minimiser les délais de désambiguïsation** : le double-tap retarde
  mécaniquement le simple tap — ne payer ce coût que là où le double-tap
  existe.

### 11. Lissage au niveau frame

La fluidité, c'est le contenu des frames, pas seulement leur cadence.

- Garder le déplacement par frame sous le seuil de perception (éviter le
  strobing).
- Mouvement très rapide : un léger **motion blur / étirement** encode la
  vitesse mieux qu'une traînée nette.
- `requestAnimationFrame` est l'horloge synchronisée à l'écran (le
  `CADisplayLink` du web). N'animer que `transform` et `opacity` ;
  `will-change` quand le mouvement est imminent.

---

## II. Matière, typographie, retours

### 12. Matériaux & profondeur

La translucidité est une couche fonctionnelle flottante qui structure
sans voler le focus. Web : `backdrop-filter`.

- Nav/toolbars/sheets en couches translucides (`backdrop-filter: blur()`
  + fond semi-transparent), le contenu défile dessous — pas des barres
  opaques.
- **Le poids du matériau encode la hiérarchie** : sombre/lourd = régions
  structurelles (sidebars) ; clair = éléments interactifs. **Jamais deux
  surfaces claires translucides empilées** — la lisibilité s'effondre.
- Une grande surface lit « plus épaisse » : blur plus fort + ombre plus
  profonde qu'un petit chip. Ombre contextuelle : plus lourde sur du
  contenu chargé, plus légère sur du calme.
- **Scrimer pour focaliser, séparer pour garder le flux** : une tâche
  modale = scrim + fond repoussé ; un panneau parallèle non-bloquant =
  translucidité + décalage **sans scrim**. Sheets empilés : chaque parent
  s'assombrit et recule d'un cran.
- **Vibrancy** : sur matériau flou, pas de gris plat — contraste plus
  haut, graisse un peu plus forte, léger bump de letter-spacing. La
  couleur vit sur une couche pleine, pas sur le premier plan translucide.
- **Bord de scroll en fondu**, pas une bordure 1 px : un petit
  masque blur/gradient là où le contenu rencontre le chrome flottant,
  seulement où l'UI flottante recouvre réellement du contenu.
- **Matérialiser, pas fondre** : une surface de verre anime blur et
  scale ensemble à l'entrée/sortie — un matériau qui arrive, pas une
  opacité qui monte.

```css
.toolbar {
  background: rgba(255, 255, 255, 0.6);
  backdrop-filter: blur(20px) saturate(180%);
  border-top: 1px solid rgba(255, 255, 255, 0.4); /* la lumière accroche le bord */
}
```

### 13. Multimodal — mouvement + son + haptique

1. **Causalité** — la cause du feedback est évidente : déclencher sur
   l'événement causal réel (le toggle qui bascule, l'item qui snappe), au
   caractère assorti à la physicalité de l'action.
2. **Harmonie** — visuel, son et haptique (Vibration API) partent sur
   **la même frame**. La latence entre eux détruit l'illusion.
3. **Utilité** — n'ajouter du feedback que là où il gagne sa place
   (succès, erreur, commit, snap). Le sur-feedback apprend à tout ignorer.

### 14. Reduced-motion & réglages — trois signaux indépendants

Motion réduit ≠ zéro feedback : un équivalent doux, non vestibulaire.

- **`prefers-reduced-motion: reduce`** — cross-fades courts à la place
  des slides/springs/parallax ; supprimer l'élastique et l'overshoot ;
  garder les changements d'opacité/couleur qui aident à comprendre.
- **`prefers-reduced-transparency: reduce`** — surfaces givrées/solides :
  monter l'opacité de fond, couper le blur.
- **`prefers-contrast: more`** — fonds quasi pleins + bordure définie
  contrastée.

En plus : pas de fonds animés plein écran ; pas d'oscillations lentes en
boucle (~0,2 Hz, un cycle / 5 s) ; pas de sauts de luminosité brutaux
(adoucir les bascules dark↔light) ; les grands objets en déplacement
deviennent semi-transparents pendant le trajet, et une grande surface qui
se repositionne loin fond en sortie puis revient posée.

Côté JS : un bloc CSS ne neutralise pas les animations inline d'une lib —
framer-motion se couvre par `MotionConfig reducedMotion="user"`
(`"always"` dans une branche print/export est un usage légitime).

```css
@media (prefers-reduced-motion: reduce) {
  .sheet { transition: opacity 200ms ease; transform: none !important; }
}
@media (prefers-reduced-transparency: reduce) {
  .toolbar { background: white; backdrop-filter: none; }
}
```

### 15. Typographie — optique, pas uniforme

- **Le tracking dépend de la taille — jamais une valeur unique.** Le
  display veut du tracking *négatif* (les lettres s'écartent trop en
  grandissant) ; le petit corps veut un léger *positif* ; le corps reste
  proche de 0. Un `letter-spacing` global est faux quelque part.
- **Le leading suit inversement la taille** : serré sur les grands
  titres, aéré sur le corps ; resserré pour l'UI dense.
- **La hiérarchie = poids + taille + leading ensemble** — l'emphase par
  la graisse ajoute de la présence sans prendre de place.
- **Respecter le réglage de taille de texte** (le Dynamic Type du web) :
  espacements en `rem`/`em`, pas en px figés — le layout grandit avec le
  texte.
- **La police système d'abord** : elle embarque déjà optical sizing,
  tables de tracking et réglages de lisibilité. Ne la remplacer qu'avec
  une raison.

```css
:root { font: 100%/1.5 system-ui, sans-serif; }
.display {
  font-size: clamp(2rem, 5vw, 4rem);
  line-height: 1.05;        /* leading serré en grand */
  letter-spacing: -0.02em;  /* tracking négatif en grandissant */
  font-optical-sizing: auto;
}
```

---

## III. Les fondations — huit principes et leurs règles tactiques

Le filtre premier : un écran qui casse un principe a un problème plus
grave que n'importe quelle guideline isolée.

| Principe | La ligne d'Apple | La question à poser |
| --- | --- | --- |
| Purpose | Faire quelque chose qui compte | À quoi sert cet écran, et le design le sert-il ? Décider quoi *ne pas* construire — chaque feature dépense du temps, de l'attention et de la confiance. |
| Agency | Laisser les gens faire à leur façon | Peut-on explorer, sauter, se rattraper ? Undo facile pour les glissades ; confirmation seulement pour le destructif irréversible (en abuser apprend à cliquer au travers). |
| Responsibility | Agir dans l'intérêt des gens | Permissions au bon moment, pour le strict besoin, transparentes. Anticiper le mésusage (une app recettes consciente des allergies ne suggère pas l'ingrédient dangereux) ; couper la feature dont le risque dépasse la valeur. |
| Familiarity | Construire sur le connu | Les patterns collent-ils à la plateforme et restent-ils cohérents ? Métaphores ni trop littérales ni trop abstraites ; même apparence = même comportement, même place. Ne casser un pattern connu que preuve à l'appui. |
| Flexibility | S'adapter aux contextes et capacités | Ça marche sur toutes les tailles, entrées, tailles de texte, aptitudes ? Adapter à la plateforme et à la situation ; quand aucun layout unique ne va, laisser personnaliser. |
| Simplicity | Être clair et direct — pas minimal | Chaque élément a-t-il gagné sa place ? Tout enterrer au même endroit *paraît* minimal sans être simple. Parfois *ajouter* du contexte simplifie (le scrubber qui montre le temps restant). Chemin courant d'abord, avancé un niveau plus bas. |
| Craft | Soigner chaque détail | Espacement, alignement, wording, animation : est-ce fini ? Rien n'est aléatoire — chaque valeur se défend. Un scroll qui saccade, une icône désalignée lisent « négligence ». |
| Delight | Le rendre humain | Quelle émotion, et est-ce la bonne ? Le délice est le résultat des sept autres, pas du confetti par-dessus. |

Règles tactiques au service des principes :

- **Le feedback a quatre genres** : statut, complétion, avertissement,
  erreur. Confirmer les actions qui comptent, exposer le statut en cours,
  prévenir avant le problème, valider inline (pas au submit).
- **Wayfinding** — chaque écran répond : où suis-je ? où puis-je aller ?
  qu'y a-t-il là-bas ? comment je sors ? Ne jamais piéger.
- **Groupement & mapping** : la proximité implique la relation ; un
  contrôle vit près de ce qu'il affecte et les contrôles reflètent ce
  qu'ils changent. S'il faut un label pour expliquer un contrôle, le
  mapping est faible.
- **Des labels directs et spécifiques** : « Progress », « Library » —
  pas « Home ». La spécificité crée la prédictibilité.

### Le processus (WWDC)

- **Prototyper interactivement** — une démo jouable vaut « un million de
  maquettes statiques » ; elle fixe aussi la barre qui empêche une
  implémentation finale médiocre.
- **Designer interaction et visuel ensemble** : « on ne doit pas pouvoir
  dire où l'un finit et où l'autre commence. »
- **Tester avec de vraies personnes en vrai contexte**, et revoir le
  mouvement au ralenti / image par image — l'invisible à pleine vitesse.

---

## IV. Le processus de review (dickwu, adapté maison)

### 16. Le contexte avant le jugement

Avant de juger quoi que ce soit :

- **Plateforme et stack** ; catégorie d'app et public.
- **L'artefact** : code, screenshots, maquette ? Dire ce qu'on peut et ne
  peut pas vérifier avec. Le contraste se calcule depuis les hex, pas à
  l'œil sur un JPEG. **Une limite n'est pas un finding.**
- **La thèse du design, en une phrase** : quel est le job unique de cet
  écran, et sa chose la plus caractéristique ? Pas de réponse = note de
  craft.
- **Le but de l'utilisateur** : audit complet, inquiétude précise, ou
  direction d'amélioration. Inférer ce qu'on peut ; ne demander que si la
  réponse change la review.

### 17. Les cinq lentilles, dans l'ordre, avec sévérités

1. **Accessibilité (échecs = Critical)** — le texte suit le réglage
   système et le layout survit aux plus grandes tailles ; corps par
   défaut ~17 pt mobile (min 11), ~13 pt desktop (min 10), pas de graisses
   fines en petit ; contraste **4.5:1** jusqu'à 17 pt, **3:1** à partir de
   18 pt ou en gras — calculé et montré en chiffres.
2. **Conventions de plateforme (High)** — mobile : tab bars, sheets,
   search, safe areas, cibles 44 pt, clavier évité ; desktop : barre de
   menus complète, raccourcis standards, fenêtres redimensionnables,
   menus contextuels, hover. Light et dark partout, depuis des tokens
   sémantiques.
3. **Visuel & craft (High/Medium)** — une couleur = un sens, rien de
   codé en dur ; peu de typefaces, une échelle claire ; alignement,
   groupement, air ; divulgation progressive plutôt que densité ; icônes
   d'un seul langage, au poids du texte voisin ; le mouvement est
   intentionnel, bref, annulable, rare sur les interactions fréquentes.
4. **Interaction (Medium)** — chargements, feedback, alertes, modalité,
   actions destructives, undo, saisie.
5. **Contenu & écriture (Medium)** — des labels qui disent ce qui va se
   passer, capitalisation de plateforme, erreurs et états vides qui
   orientent.

### 18. La lentille craft — le regard studio

- **Y a-t-il un point de vue ?** Nommer la chose dont ce design sera
  retenu. Rien ne ressort → le dire. Un utilitaire volontairement
  discret peut être la bonne réponse — le dire aussi.
- **Radar anti-template** — les looks qui dominent l'UI générée : crème
  chaud + serif contrastée + accent terracotta ; near-black + un accent
  acide (vert/vermillon) ; broadsheet de filets hairline, radius zéro,
  colonnes denses. Même famille : le héros « gros chiffre sur petit
  label + gradient », la numérotation 01/02/03 sur du contenu non
  séquentiel. Une palette, un pairing ou un layout sans raison enracinée
  dans le produit est un défaut, pas un choix.
- **La typo porte-t-elle une personnalité**, ou n'est-elle qu'un
  véhicule ? Système pour la nav et les contrôles ; la marque vit dans le
  display, le contenu, quelques moments.
- **La structure encode-t-elle de l'information ?** Numéros, eyebrows,
  filets, labels disent quelque chose de *vrai* sur le contenu.
- **La hardiesse se dépense à un seul endroit** — un élément signature,
  tout le reste se tait (version Apple : le branding s'efface devant le
  contenu, le logo ne se répète pas).
- **Retirer un accessoire** : qu'est-ce qui part sans perte ? Si rien, le
  design est déjà maigre — le dire.

La tension « à sa place sur la plateforme » vs « impossible à confondre »
se résout comme Apple : composants système pour la nav et les contrôles ;
l'identité dans la couleur, la typo, l'imagerie, le ton, quelques moments.

### 19. Mode amélioration — travailler comme un studio

Review d'abord, puis :

1. **Ancrer dans le sujet** : produit, public, job unique de l'écran ;
   puiser le monde visuel dans les matériaux et le vernaculaire du sujet.
2. **Planifier un système de tokens compact** avant de toucher au
   layout : 4-6 couleurs nommées avec rôles (surface, contenu, accent,
   signal), variantes light/dark et **chiffre de contraste** ; un display
   sobre + un corps + une utilitaire data si besoin, l'échelle montrée ;
   une phrase + un wireframe ASCII de l'écran clé en compact et régulier ;
   **la signature** — l'élément dont on se souviendra, et pourquoi il
   appartient à *ce* produit ; un seul moment de motion orchestré s'il
   sert le sujet, sinon aucun.
3. **Critiquer le plan avant de le proposer** : « aurais-je produit ce
   même plan pour un autre produit ? » Oui → c'est un défaut, réviser et
   dire ce qui a changé. Déjà spécifique → le dire et garder.
4. **Des fixes concrets, chiffrés, dans le framework de l'utilisateur** :
   pas « corriger le contraste » mais « corps de #999999 → #595959 sur
   blanc, 7.0:1 ».
5. **Séquencer** : accessibilité → conventions → craft → polish.
6. **Critiquer encore** : chercher une chose à retirer (dire s'il n'y en
   a pas) ; confirmer le plancher : responsive jusqu'à la plus petite
   largeur, focus clavier visible, reduced-motion et reduced-transparency
   respectés, la plus grande taille de texte survivable.

### 20. Règles de travail

- **Des chiffres, pas des adjectifs.** « 12 px #AAAAAA sur blanc, 2.3:1,
  sous 4.5:1 » bat « difficile à lire ». Impossible à mesurer → dire ce
  qu'il faudrait pour mesurer.
- **Citer, ou étiqueter comme jugement.** Ne jamais inventer une
  guideline.
- **Parler le framework de l'utilisateur.**
- **Nommer le trade-off** quand une guideline heurte un besoin métier,
  puis recommander.
- **Reviewer le flux, pas seulement l'écran** — un bel écran peut casser
  la navigation autour.
- **Ne pas sur-critiquer.** Un design fort reçoit une review courte et la
  raison claire de sa force.
- **Ne pas aplatir la personnalité.** Si les fixes rendent le design
  indiscernable d'un template, on est allé trop loin.

### 21. Format de rapport (adapté au nôtre)

Chez dickwu : Summary / Critical / Improvements / Craft notes / What
works / Platform notes — chaque finding = un Quoi, un Pourquoi qui cite
la source, un Fix dans le framework. Chez nous, ça se mappe sur
`.fluid-pass/rapport-<date>.md` : préflight + inventaire / findings
(fichier:ligne + preuve + réécriture) / **écartés avec raison** (notre
ajout : le « What works » prouvé) / §3 mesures / propositions / stats.

---

## V. Routage HIG — fetch à la demande

L'idée du `hig-lookup` de dickwu, sans vendorer (droits Apple,
péremption) : fetcher `developer.apple.com/design/human-interface-guidelines/<page>`
au moment du besoin, citer la page dans le finding.

| Surface auditée | Page(s) |
| --- | --- |
| Drag, swipe, gestes custom | `gestures`, `drag-and-drop` |
| Animations, transitions | `motion` |
| Translucidité, profondeur | `materials` |
| Typo, échelle, Dynamic Type | `typography` |
| Feedback, chargements, erreurs | `feedback`, `loading` |
| Sheets, drawers, modales | `sheets`, `modality` |
| Menus, popovers | `menus`, `popovers` |
| Boutons, contrôles | `buttons`, `toggles`, `sliders` |
| Undo, destructif | `undo-and-redo` |
| Charts | `charting-data` |
| A11y, couleurs | `accessibility`, `color`, `dark-mode` |

---

## VI. Quick reference

| Besoin | Technique | Valeur concrète |
| --- | --- | --- |
| Spring UI par défaut | Amorti critique, sans overshoot | damping 1.0, response 0.3-0.4 |
| Spring momentum/flick | Sous-amorti, léger rebond | damping ~0.8, response 0.3-0.4 |
| Geste → vélocité de spring | Handoff au release | `vGeste / (cible − courant)` si normalisé |
| Point d'arrivée d'un flick | Projeter le momentum | `pos + (v/1000)·d/(1−d)`, d ≈ 0.998 |
| Interrompre proprement | Partir de la valeur de présentation | lire le transform affiché |
| Éviter le « mur » à l'inversion | Porter la vélocité au re-ciblage | spring qui fond la vélocité |
| Transition réversible | Miroiter l'easing | cubic-bézier inverse |
| Reverse vs commit | Le **signe** de la vélocité | au release, pas la position |
| Drag 1:1 | Pointer Events + capture | respecter le grab offset |
| Feedback | Au pointer-down, continu | jamais seulement à la fin |
| Bord | Rubber-band, pas d'arrêt dur | `(x·dim·0.55)/(dim+0.55·|x|)` |
| Chrome translucide | Couche `backdrop-filter` | le contenu défile dessous |
| Tracking | Par taille, jamais fixe | display −0.02em, corps ~0 |
| Reduced motion | Cross-fade, pas slide/spring | `@media (prefers-reduced-motion)` |
| Hystérésis de geste | Seuil avant engagement | ~10 px |
| Cible tactile | Taille minimale | 44 pt |
| Contraste | Calculé, montré | 4.5:1 (≤17 pt) ; 3:1 (≥18 pt ou gras) |

---

## Généalogie et écarts assumés

Rejeté de la source 1 : l'« Initial Response » scriptée (un skill qui
récite une phrase d'accueil n'audite rien). Rejeté de la source 2 : le
vendoring des 122 pages HIG (droits + péremption — remplacé par §V) ; le
vocabulaire multi-framework Flutter/RN/Tauri (notre territoire est le
web) ; les modes spécialisés app-icons/Liquid Glass/onboarding (couverts
au besoin par §V). Ajouté par la maison, absent des deux : la preuve
dynamique pilotée (sampler `eval`, sabotage d'écran), le gate de
non-régression, les modes rapport/commit, la règle WIP, les trois
graphies de grep, le protocole de rodage.
