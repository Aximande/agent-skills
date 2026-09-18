---
name: safety-net
description: >
  Pose un filet de tests de caractérisation sur un repo fonctionnel non testé :
  capture le comportement ACTUEL (bugs compris) en golden masters, prouve que
  le filet tient par sabotage, et débloque le gate de cleanup-pass. Python,
  TS/JS. Use when: l'utilisateur demande explicitement « pose un filet /
  des tests de caractérisation / sécurise ce repo avant refacto », ou quand
  cleanup-pass a basculé en mode rapport faute de filet. Uniquement sur
  demande explicite.
license: MIT
---

# Safety Net

Contexte : un repo qui marche mais que rien ne protège. Le filet de
**caractérisation** (Feathers) capture ce que le code **fait**, pas ce qu'il
devrait faire :

- Le comportement actuel EST la spec, bugs compris. Le filet protège contre
  les *changements*, pas contre les bugs existants — une sortie suspecte
  repérée en passant est listée au rapport, jamais « corrigée ».
- Le livrable n'est pas « des tests » : c'est un **gate prouvé** (par
  sabotage, §2) que `/cleanup-pass` et tout refacto futur pourront utiliser.

Arguments : `/safety-net [--paths <globs>]`

## Déroulé

### 0. Préflight — inventaire des cibles

1. **Working tree propre** ; sinon stop, demander commit/stash.
2. Packages par manifests ; en monorepo, chaque package est autonome.
3. **Tests existants conservés tels quels** — seule la surface non couverte
   est visée. Exception, le **harnais mort** : si les suites échouent au
   *chargement* (config runner cassée, alias non résolu — 0 test exécuté),
   réparer l'infra de test EST le travail du filet : c'est restaurer la
   couverture sans toucher ni au code produit ni aux tests. Les tests
   restaurés qui sortent rouges rejoignent la baseline (liste nommée
   `fichier :: test`), jamais réparés.
4. Runner : celui du repo s'il existe, sinon stdlib (`unittest` Python,
   `node:test` TS/JS) — zéro dépendance ajoutée, à une exception près :
   l'enregistrement HTTP (§1), signalé au rapport.
5. Inventaire des cibles **par ROI décroissant** :
   1. endpoints API (un appel = un comportement observable complet) ;
   2. fonctions pures publiques ;
   3. sorties CLI.
   Composants UI : exclus (snapshots fragiles = filet qui crie faux).
   Si un graphe graphify existe (`graphify-out/graph.json`), ordonner à
   l'intérieur de chaque catégorie par degré du nœud (god nodes d'abord) —
   la centralité mesure ce qui casse tout si ça change. Les « fonctions
   pures » s'y repèrent mécaniquement : modules sans arête `imports_from`
   vers le framework (react/vue/express…) ; parmi eux, ceux sans I/O
   (fetch, DB, fs) se caractérisent trivialement — et c'est là que les
   tests existants d'un repo gravitent déjà naturellement.
6. Branche `safety-net/<YYYY-MM-DD>`.

Fini quand : la liste des cibles retenues ET exclues (chacune avec sa raison)
est écrite dans le rapport en cours.

### 1. Capture — écrire le filet

Par cible :

- **API** : client de test in-process (TestClient FastAPI, `test_client`
  Flask, app Express montée sous `node:test` + fetch). Par endpoint : happy
  path + 1 cas limite (entrée invalide).
- **Fonctions pures** : 3 à 5 entrées représentatives (vide, borne, typique).
- **CLI** : invocations principales — stdout, stderr, exit code.

Mécanique :

- **Golden masters** : fichiers JSON dans `tests/golden/`, tests dans
  `tests/characterization/`. Champs volatils (timestamps, uuid, ports,
  chemins absolus) normalisés par des scrubbers visibles dans le test.
- **Non-déterminisme** : seed du random et freeze du temps quand c'est
  trivial ; HTTP externe → cassettes enregistrées puis rejouées (vcrpy /
  nock, seule dépendance autorisée) ; appels LLM live → cible **exclue**,
  motivée au rapport.
- **Le code produit n'est jamais modifié.** Une cible intestable sans
  refacto part au rapport — le refacto, c'est le travail de cleanup-pass
  (couche 3).

Un commit par package : `test: filet de caractérisation (<package>)`.

Fini quand : chaque cible retenue a ses tests et la suite passe
**3 fois d'affilée** — un test instable est stabilisé ou retiré, jamais
livré (un filet flaky est pire que pas de filet : il crie faux).

### 2. Sabotage — prouver que le filet tient

Au moins **5 mutations volontaires**, réparties sur les packages et types de
cibles : condition inversée, constante changée, appel supprimé. Une à la
fois, dans le working tree, jamais commitées :

1. muter → la suite doit passer au rouge ;
2. `git checkout` immédiat de la mutation ;
3. noter attrapé/raté.

Score **X/N au rapport**. Un sabotage non attrapé = un test ajouté pour le
couvrir, ou un trou documenté explicitement — jamais passé sous silence.

### 3. Livraison

1. **CI minimal commité avec le filet** (`.github/workflows/tests.yml`) : le
   filet s'exécute sur chaque push/PR — un filet sans CI meurt en silence.
   S'il existe des tests rouges en baseline, committer leur liste nommée
   (`.github/jest-baseline.txt` ou équivalent) et comparer en CI : échec
   seulement sur failure **nouvelle**.
2. Rapport `.safety-net/rapport-<date>.md` (non commité) : cibles couvertes,
   exclusions motivées, sorties suspectes repérées, **score sabotage X/N**,
   la commande exacte pour lancer la suite.
3. Validation utilisateur.
4. Remote présent → push + PR draft, rapport en description. Le merge
   appartient à l'utilisateur. Commits sans Co-Authored-By ni mention d'IA.

## Après merge

Lancer `/cleanup-pass` : son préflight trouve le filet comme n'importe quels
tests, et le repo passe de « mode rapport » à nettoyage complet gaté.
