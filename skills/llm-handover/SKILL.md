---
name: llm-handover
description: >
  Handover prêt à copier-coller pour passer la main d'une conversation LLM
  à un autre LLM ou agent (Codex, Cursor, ChatGPT, Gemini, session Claude
  fraîche) : état + intention + décisions + prochaine action, vérifié par
  un agent frais qui ne voit que le handover. Deux modes : repo (le
  destinataire a le clone) et standalone (chat sans accès fichiers).
  Use when: « prépare un handover / handoff », « je passe sur X », fin de
  session à continuer ailleurs, ou /llm-handover. Uniquement sur demande
  explicite.
license: MIT
---

# LLM Handover

Passer la main d'une conversation à un autre LLM en **un document unique,
collé tel quel**. On transmet l'**état et l'intention** — où on en est,
pourquoi, quoi faire — jamais le transcript : un handover n'est pas une
archive. Deux règles au-dessus de tout :

- **N'affirme que ce qui est vérifié à l'instant T** (règle docs-pass) :
  un handover écrit à 18h ne décrit pas l'état de 14h.
- **Le contexte du destinataire est la ressource rare** : chaque ligne
  doit changer ce que le destinataire *fera*. Ce qui ne change rien sort.

## 0. Invocation & mode

Argument attendu : le **destinataire** et, si utile, le focus de la
prochaine session (`/llm-handover codex — finir la PR sécu`).

- **Mode repo** (défaut) : le destinataire a accès au même clone (Codex
  CLI, Cursor, session Claude fraîche, autre CLI). Tout ce qui vit dans un
  artefact — spec, PR, commit, doc — se **référence par chemin ou URL,
  jamais ne se recopie**.
- **Mode standalone** (`--standalone`, ou destinataire = chat web :
  ChatGPT, Gemini, claude.ai, Le Chat…) : le destinataire ne verra aucun
  fichier. Le handover embarque une **capsule** : les extraits strictement
  nécessaires à la prochaine action (signatures, config, le bloc de code
  concerné) — jamais de fichiers entiers.

Destinataire ambigu → demander, c'est une bifurcation de contenu.

## 1. Collecte vérifiée — l'état à l'instant T

Avant d'écrire, re-vérifier le terrain, pas la mémoire de la
conversation — surtout si elle a été compactée :

- `git status` / branche / `git log` récent, PRs ouvertes (`gh pr list`),
  état des fichiers modifiés non commités.
- Les commandes d'état peu coûteuses citées dans le handover se
  re-exécutent (tests ciblés, build check, curl de santé).
- Un fait invérifiable dans le temps imparti → marqué **« à vérifier »**
  dans le handover, jamais affirmé.

## 2. Quiz avant rédaction — le corrigé d'abord

Écrire, **avant** le document, 5 questions critiques avec leurs réponses
attendues — ce qu'un repreneur doit savoir pour agir sans danger :

1. Quelle est la prochaine action exacte ? (toujours la question n°1)
2. Quelle décision est verrouillée, et pourquoi ne pas la rouvrir ?
3. Quel piège a déjà été rencontré, et quel est son fix ?
4. Où se trouve X (fichier, PR, source de vérité) ?
5. Qu'est-il interdit de faire (sécurité, prod, irréversible) ?

Le corrigé reste hors du handover : il servira de juge en §4.

## 3. Rédaction — le squelette

```markdown
# Handover — <projet> → <destinataire> (<date>)

## Mission & état
D'où on vient, où on va, où on en est exactement — 5 à 10 lignes.

## Décisions verrouillées (et pourquoi)
Une par ligne, avec la raison — pour que le repreneur ne les rouvre pas.

## Fichiers touchés & commandes
Chemins complets, commandes lancées avec leur résultat (vert/rouge).

## Pièges rencontrés → fixes
La section la plus rentable : chaque erreur déjà payée et sa solution.

## Prochaine action
LA première chose à faire, précise et exécutable. Puis les suivantes,
par priorité. Les « à vérifier » explicitement marqués.

## Outillage attendu
Ce dont le repreneur a besoin, traduit pour lui : pas de « lance
/graphify » vers un chat web — l'équivalent réalisable chez lui, ou rien.

## Capsule (mode standalone uniquement)
Extraits nécessaires à la prochaine action, chacun titré de son chemin.
```

**Budget adaptatif** : la taille suit le **travail restant + décisions +
pièges**, pas la longueur de la conversation — une session à 80 % de
contexte dont le chantier est presque clos tient en 120 lignes, un
chantier multi-fronts en cours peut en demander 600. Le juge de
complétude est l'agent frais (§4) ; le juge de sobriété est la règle
« chaque ligne change ce que le destinataire fera ».

## 4. Vérification — un agent frais qui ne voit que le handover

Le handover n'est pas livré sur la foi de son auteur :

- Lancer un **sous-agent frais** dont le prompt contient le handover et
  le quiz (sans le corrigé). Il répond au quiz et énonce la prochaine
  action.
- **Isolation selon le mode** : standalone → interdiction totale d'outils
  et de lecture de fichiers, le document seul fait foi ; repo → accès au
  clone autorisé (les mêmes conditions que le destinataire réel).
- L'orchestrateur compare au corrigé. Réponse manquante ou fausse = trou
  du handover, pas faute de l'agent : combler le trou cité, relancer un
  vérificateur frais.
- **Cap 3 rounds**. Au cap, livrer quand même avec le score réel affiché
  et le dire à l'utilisateur.
- Le score s'embarque en pied de document :
  `Vérifié : agent frais X/5 · prochaine action correcte · N round(s)`.

## 5. Secrets — le handover traverse une frontière

Le document part chez un autre provider : c'est un vecteur
d'exfiltration. Avant livraison, scan du texte final :

- Clés, tokens, mots de passe, PII → **jamais en clair**, empreinte
  4 caractères maximum si l'identification est nécessaire.
- Si le repreneur aura besoin d'un secret : dire **où** le trouver
  (gestionnaire de secrets, variable d'env, dashboard), jamais le
  recopier.

## 6. Livraison

1. Fichier `.handoff/<YYYY-MM-DD>-<destinataire>.md` à la racine du
   repo — **non commité, non tracké** (comme `.proof-run/`).
2. Copie dans le presse-papier (`pbcopy` sur macOS) : l'utilisateur
   invoque, puis ⌘V dans l'autre LLM.
3. Annonce finale : chemin, taille (lignes, ~tokens), score de
   vérification, et ce qui reste marqué « à vérifier ».
