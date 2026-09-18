---
name: excalidraw-slides
description: >
  Créer ou remanier une présentation Excalidraw à partir d'un brief, de
  documents ou d'une scène existante : récit adapté au public et au temps
  de parole, éléments éditables, notes orales, sources et vérification
  visuelle. Use when: « fais des slides sur Excalidraw », « transforme ce
  rapport en présentation Excalidraw », « adapte ce deck », ou
  /excalidraw-slides. Ne s'applique pas à la simple vérification d'accès
  à un lien ni aux diagrammes isolés.
license: MIT
---

# Excalidraw Slides

Faire un support que l'on peut **présenter, vérifier et modifier**.
Le contenu projeté porte l'idée ; les notes portent l'explication.
Un deck n'est pas un rapport découpé en rectangles.

## 1. Cadrer sans ralentir

Déduire du brief le public, le message à retenir, la durée, la langue,
les sources et la destination (nouvelle scène ou scène existante).
Annoncer les hypothèses utiles ; ne demander que ce qui change réellement
le livrable et n'est pas inférable. Une demande de création autorise la
création : pas d'approbation systématique du plan avant d'avancer.

- Une introduction suivie d'un bilan appelle une transition et le bon
  partage du temps, pas la réécriture automatique du bilan.
- Une ressource peut être une source de contenu ou une référence visuelle :
  distinguer les deux. Inspecter le template demandé et en reprendre
  les choix pertinents ; ne pas imposer les couleurs d'une mission passée.
- Un brief de 10 minutes n'impose pas 10 slides. Adapter le nombre à la
  densité, au public et aux moments de démonstration ou d'échange.

## 2. Construire un récit factuel

Lire les sources avant d'écrire. Pour les PDF/Office, utiliser le lecteur
ou convertisseur disponible ; utiliser doc-ingest s'il est disponible et
utile. Vérifier ailleurs les faits récents, incertains ou déterminants.

Séparer dans le contenu **observé / mesuré / estimé / prévu / fictif**.
Une estimation citée dans un rapport reste une estimation, même sous un
titre « mesuré ». Ne pas transformer des volumes d'usage en heures
économisées sans méthode. Une capacité possible n'est pas une fonctionnalité
déployée. Signaler les contradictions déterminantes, sans réécrire les
sources. La date de transcription d'une conférence n'est pas sa date.

Préparer un conducteur compact avant les écritures :
**slide → idée unique → preuve ou exemple → structure visuelle → durée**.

- Partir des situations du public ; définir le jargon à sa première
  apparition. Une analogie aide, mais ne doit pas devenir une fausse
  explication du mécanisme.
- Distinguer ce qui est affiché, ce qui est dit et ce qui reste en annexe.
- Totaliser les durées et garder la place des transitions. Nommer ce total
  « minutage prévu » tant qu'il n'a pas été répété à voix haute.
- Associer les affirmations aux sources : lien ou référence précise de
  page dans les notes, repère lisible sur la slide si pertinent. Les
  annexes de sources sont hors temps, sauf demande contraire.

## 3. Résoudre la destination Excalidraw

Découvrir les outils réellement disponibles ; lire leurs signatures
ciblées plutôt que charger tout le catalogue. Avant la première écriture
de contenu, lire intégralement le guide vivant
`read_presentation_format`. Il fait référence pour le format des éléments,
les polices, les bindings et les règles du serveur. Ne pas maintenir une
copie de ce schéma dans le skill.

Pièges d'accès :
- Dans `/s/<workspace>/<scene>`, le premier segment est l'espace,
  le second la scène. Ne pas essayer le workspace comme sceneId.
- Un identifiant de partage readonly/slides n'est pas nécessairement
  l'identifiant de scène. Chercher la correspondance dans les métadonnées
  accessibles (`readOnlyLinks`, `sharedSlidesLinks`) si nécessaire.
- Un partage readonly n'autorise pas l'édition par ce lien ; la scène
  d'origine peut néanmoins être éditable via une connexion authentifiée.
  Vérifier cette connexion avant de conclure à une impossibilité.
- Un lien local `x-coredata://` ne fournit pas à lui seul le contenu.
  Une capture confirme l'apparence, pas les droits d'édition.

Pour une nouvelle présentation, utiliser une collection accessible
identifiée par les outils. Pour un remaniement, inspecter les slides et
l'ordre existants. Ne pas écraser le deck de référence ni changer son
partage, sa collection ou ses permissions sans demande correspondante.

Sans accès en écriture : préparer le conducteur et les notes, expliquer
le prérequis exact ; ne jamais annoncer une scène créée. Un export local
n'est proposé que si son format peut réellement être produit et vérifié.

## 4. Réaliser des slides éditables

Utiliser `create_scene` pour une nouvelle scène et `create_slide` pour
chaque slide : **une frame = une slide**, créée et ordonnée par l'outil.
En modification, préserver l'ordre et les notes via les outils de slides.

Boucle de production : créer la frame → remplir → capture → inspecter →
corriger si nécessaire. Une écriture cohérente par slide suffit
généralement. Garder les mutations d'une même scène séquentielles.

Invariants à respecter selon le guide et le contrat courants :
- Chaque enfant référence le vrai `frameId` ; ses coordonnées sont
  absolues, à l'intérieur de la `safeArea` retournée.
- `add` reçoit des éléments neufs sans `id` ; `tempId` sert aux
  références du même appel. `update` et `delete` utilisent les IDs
  persistés. Après un timeout d'écriture, inspecter avant de réessayer
  pour éviter les doublons.
- Texte appartenant à une forme : `label`. Flèches attachées aux formes :
  bindings explicites. Titres et annotations peuvent être autonomes.
- Après relecture, utiliser les dimensions persistées : le serveur peut
  recalculer celles du texte, et les dimensions demandées ne prouvent
  pas l'absence de débordement.

Choisir une composition qui exprime la relation : séquence, comparaison,
avant/après, hiérarchie, tableau ou image. Varier selon le contenu ;
éviter que chaque slide devienne la même grille de cartes. Schémas,
titres et textes restent natifs ; réserver les images aux photos,
captures et illustrations. Ne pas aplatir une slide pour masquer une
mise en page difficile.

Adapter la lisibilité à la projection : peu de texte, contraste net,
marges généreuses, jargon limité, taille lisible au fond de la salle.
Le 16:9 est un défaut raisonnable, pas une contrainte contre un template
existant. Une identité visuelle sobre et cohérente prime sur les effets.

Ajouter à chaque slide des notes orales courtes : durée prévue,
explication, exemple ou nuance utile, transition, source. Elles doivent
aider à parler, pas répéter exactement l'écran.

## 5. Prouver la qualité, puis livrer

Avant de conclure :
- Inspecter la capture de **chaque slide créée ou modifiée**, à une
  taille permettant de lire le texte. Vérifier focalisation, hiérarchie,
  contraste, chevauchements et coupures. Une capture n'est pas un test
  réel dans la salle : ne pas le prétendre.
- Relire l'ordre via `list_slides`, la présence des notes et le minutage.
  À l'export, contrôler aussi frames, appartenance, références et
  débordements avec les données persistées ; ce contrôle ne remplace
  pas la lecture visuelle.
- Vérifier que les sources étayent les affirmations, que les exemples
  fictifs sont identifiés et que le degré de certitude est conservé.
- Revoir uniquement les slides touchées après une correction.
  Si une limite technique persiste après deux corrections ciblées,
  simplifier la composition ou livrer avec la limite explicite.

Livrer le lien exact de la scène, le nombre de slides présentées et
d'annexes, le minutage prévu, les vérifications et les limites restantes.
Quand possible, fournir un export `.excalidraw` issu de l'état persisté
et les notes dans un fichier lisible, au bon emplacement du projet.
Vérifier que l'export contient les fichiers images référencés ; signaler
les images non embarquées plutôt que promettre une copie autonome.

Ne pas publier un lien public pour simplement faciliter la livraison.
Ne pas annoncer un export PDF/PPTX, une répétition chronométrée ou une
validation indépendante qui n'a pas eu lieu.
