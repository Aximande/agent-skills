---
name: cleanup-pass
description: >
  Repasse de nettoyage sur un repo fonctionnel issu de vibecoding : maximise la
  qualité (code plus court, dead code retiré, docstrings publiques) à validité
  constante (aucune nouvelle failure tests/typecheck/build). Python, TS/JS,
  notebooks. Use when: l'utilisateur demande explicitement « nettoie / épure /
  cleane ce repo » ou tape /cleanup-pass. Uniquement sur demande explicite —
  c'est une repasse sanctionnée, pas un réflexe de codage.
license: MIT
---

# Cleanup Pass

Contexte : une repasse sanctionnée sur du code qui marche déjà — pas du codage
vers l'avant. Deux axes :

- **VALIDITÉ** (invariant dur) : le comportement observable ne change jamais.
  Prouvé par le gate (§Gate), sinon mode rapport.
- **QUALITÉ** (mandat à maximiser) : code minimum — plus court, plus clair,
  maintenable par un vrai dev qui ne vibecode pas derrière.

Le skill vit à leur intersection : **maximiser la qualité à validité constante.**

Arguments : `/cleanup-pass [--paths <globs>] [--yolo]`

## Socle Karpathy

| Principe | Rôle ici |
|---|---|
| #2 Simplicity First | La boussole qualité : « si 200 lignes peuvent en faire 50, réécris ». |
| #4 Goal-Driven Execution | Le gate : critère vérifiable avant ET après chaque lot. |
| #1 Think Before Coding | Préflight des faits, rapport avant application, doutes remontés. |
| #3 Surgical Changes | Lettre inversée, esprit gardé (encadré). |

> **Le #3 reformulé.** En cleanup on refactore et on supprime — c'est le mandat,
> l'inverse de « ne touche pas ce qui n'est pas cassé ». Mais le cœur du #3
> tient : on ne change que ce qu'on comprend assez pour prouver l'équivalence,
> et chaque changement trace à la demande, qui devient ici :
> **« plus simple/clair à comportement constant »**. Un changement de
> comportement, même « plus propre », est hors mandat → rapport.

## Déroulé

### 0. Préflight — établir les faits

0. **Working tree propre** : `git status` sans modification non commitée.
   Sinon, stop — demander à l'utilisateur de committer ou stasher son travail
   en cours avant la repasse (la branche cleanup ne doit contenir que du
   nettoyage, jamais du WIP mélangé).
1. Détecter les packages par manifests (`pyproject.toml`, `requirements.txt`,
   `package.json` + `tsconfig.json`, `.ipynb`). En monorepo, chaque package est
   un sous-repo autonome : sa chaîne d'outils, son gate. Un package rouge ne
   bloque pas les autres.
2. Détecter le filet par package : tests > typecheck/build > rien.
3. Enregistrer la **baseline** : lancer le filet, noter la liste exacte des
   failures existantes.
4. Lire la config repo (ruff/black/eslint/prettier/mypy/tsconfig) : **la config
   du repo gagne toujours** sur les défauts du §Outils — le style maison est un
   comportement à préserver comme un autre.
5. Créer la branche `cleanup/<YYYY-MM-DD>`. Tout le travail vit dessus.
6. Périmètre : tout le repo par lots (module ou dossier cohérent), ou
   restreint aux globs de `--paths`.

Fini quand : packages, filet, baseline et config sont notés par package, la
branche existe.

### 1. Couche 1 — outillage déterministe

Formatters + linters `--fix` par package (§Outils). Gate, puis un commit par
package : `chore: format + lint (<package>)`.

### 2. Couche 2 — simplification à comportement constant

Par lot, dans l'ordre :

- **Dead code prouvé** : supprimer seulement sur preuve d'inatteignabilité —
  vérifier entrypoints, exports, imports dynamiques, réflexion/DI, routes,
  templates, tests. Un simple « grep ne trouve rien » part au rapport, pas
  au diff.
- **Duplication flagrante** → factoriser.
- **Abstraction single-use** (wrapper, classe, indirection à un seul appelant)
  → inliner.
- **Docstrings sur l'API publique** (détectées en préflight via ruff `D`) :
  Google en Python, TSDoc sur les `export` en TS. Une docstring dit le contrat
  et le pourquoi ; une signature reformulée en prose est du bruit à ne pas
  écrire.
- **Noms trompeurs** → renommer, portée locale au module.
- **Commentaires** : retirer ceux qui répètent le code ; garder ceux qui
  encodent une intention, un pourquoi, un ticket, un warning.

Gate après chaque lot ; un lot qui introduit une failure est **reverté**, pas
corrigé à la volée. Un commit par lot :
`refactor: <sujet du lot> (comportement constant)`.

Un bloc dont l'effet reste incertain après lecture part au rapport, intact.

Fini quand : tous les lots du périmètre traités ou consignés, gate vert
(différentiel) sur chaque package touché.

### 3. Couche 3 — structurel (rapport seulement)

Redécoupage de modules, changement d'API interne, gros renommages,
introduction du typage, tests manquants : consignés au rapport comme checklist
de décisions, jamais appliqués dans cette passe.

### 4. Livraison

1. **Rapport court** par catégorie : un item par lot avec son hash de commit,
   baseline rouge pré-existante, items couche 3 en attente de décision, et un
   bloc **Stats** (par package + total) :
   - lignes nettes de couche 2 **hors docstrings** — le vrai « code en
     moins » ; le brut de couche 1 est du churn de formatage, affiché à part
     et étiqueté comme tel ;
   - dead code supprimé (lignes, fichiers) ;
   - duplications factorisées, au format « N occurrences → 1 » ;
   - docstrings ajoutées (nombre) ;
   - plus gros fichier du repo avant/après.
   Toujours écrit dans `.cleanup/rapport-<date>.md` (non commité, non tracké)
   en plus de l'affichage.
2. Validation utilisateur — sautée pour les couches 1-2 si `--yolo`.
3. Remote présent → push + **PR draft**, rapport en description. Sinon branche
   locale. Le merge appartient à l'utilisateur.
4. Commits propres : pas de Co-Authored-By ni de mention d'IA.

## Gate

Filet par package, ordre de préférence :

1. **Tests** ;
2. sinon **typecheck/build** ;
3. sinon aucun filet → **mode rapport** : zéro commit sur ce package, toutes
   les trouvailles partent au rapport, l'utilisateur est prévenu explicitement.

Le gate est **différentiel** : vert = aucune failure absente de la baseline.
Les tests déjà rouges au préflight sont listés au rapport et laissés rouges —
les réparer changerait le comportement.

## Outils par défaut (quand le repo n'a pas de config)

| Langage | Couche 1 | Détection pour couche 2 |
|---|---|---|
| Python | `ruff format` puis `ruff check --fix --select E,F,W,I,UP,B,SIM` | `ruff check --select D` (convention Google), filtré sur l'API publique (pas de `_prefix`) |
| TS/JS | `prettier --write` ; `eslint --fix` seulement si configuré dans le repo | `tsc --noEmit` si tsconfig présent |
| Notebooks | `nbqa ruff` — couche 1 seulement, outputs intacts | simplifications → rapport (état caché des cellules = pas de gate fiable) |

Le typecheck sert de filet seulement s'il est déjà configuré ; introduire le
typage sur un repo qui n'en a pas est un item de couche 3.
