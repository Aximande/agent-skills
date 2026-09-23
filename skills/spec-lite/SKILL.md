---
name: spec-lite
description: >
  Une page de critères d'acceptation avant de vibecoder — spec-kit
  compressé à la seule étape « specify », moteur grilling. Chaque critère
  est observable et formulé pour que proof-run l'exécute tel quel ; la
  spec est vérifiée par un agent frais qui ne voit qu'elle, puis vit dans
  le repo (table d'état remplie au proof-run, relue par ship-check).
  Use when: « fais une spec », « qu'est-ce qu'on construit exactement ? »,
  avant de démarrer un projet ou une feature vibecodée, ou /spec-lite.
  Uniquement sur demande explicite.
license: MIT
---

# Spec Lite

Dire **quoi et pourquoi** avant de laisser l'agent décider **comment** —
sans réveiller la bureaucratie qui tue le spec-driven development.
Trois principes :

- **Une page, c'est dur.** Une spec qu'on ne relit pas est pire que pas
  de spec. Budget : 1 page, ≤ 10 critères (≤ 5 pour une exploration).
  Refuser de gonfler, même si on sait remplir.
- **Un critère est observable ou il n'est pas.** Chaque critère est écrit
  pour qu'un vérificateur qui ne voit que la spec puisse le *jouer* dans
  l'app — c'est le format d'entrée de proof-run.
- **Une ambiguïté se résout par grilling, jamais par du remplissage.**
  Pas de « [à clarifier] » laissé en trou, pas de prose qui meuble.

## 0. Cadrage

- Projet neuf ou feature sur un existant ? Échelle : produit, outil
  interne, exploration — l'exploration a droit à 5 critères et zéro
  cérémonie.
- Ce que l'utilisateur a déjà dit est acquis. Ne demander que ce qui
  change les critères.

## 1. Grilling — verrouiller les décisions

- Rounds de questions serrées, uniquement sur ce qui change le
  livrable : l'utilisateur cible, le job en une phrase, le **hors
  périmètre**, les arbitrages (plateformes, données, qualité vs
  vitesse).
- « on continue » = trancher soi-même, et consigner chaque choix en
  **Assomptions** — jamais en silence.
- C'est l'équivalent des marqueurs `[NEEDS CLARIFICATION]` de
  spec-kit — résolus séance tenante au lieu d'être laissés dans le
  document.

## 2. La page — `SPEC.md`

Committée à la racine du repo cible (c'est un artefact du projet,
contrairement aux rapports des autres skills) :

```markdown
# SPEC — <nom> (<date>)

**Job** : <une phrase — pour qui, quoi, pourquoi maintenant>
**Hors périmètre** : <la liste qui protège le focus>

## Critères d'acceptation (P1 = MVP viable à lui seul)
- **C1 (P1)** — Étant donné <état>, quand <action>, alors <résultat observable>.
- **C2 (P1)** — …
- **C5 (P2)** — …

## Cas limites
- <ce qui casse : entrée vide, gros fichier, offline, double-clic…>

## Assomptions (tranchées au grilling, ou par l'agent sur « on continue »)
- <choix> — <pourquoi>

## État (rempli par proof-run, relu par ship-check)
| Critère | État | Preuve / raison |
|---|---|---|
| C1 | — | |
```

- Priorisation héritée de spec-kit : **les critères P1 forment seuls un
  produit viable** ; chaque priorité est démontrable indépendamment.
- Critères tech-agnostiques — le « comment » appartient au vibecode.
  Chiffrés quand c'est du perf/volume (« en moins de 2 s », « 500
  lignes »), jamais d'adjectif (« rapide », « agréable » = à reformuler).

## 3. Vérification — la spec passe l'agent frais

Un agent qui ne voit **que** `SPEC.md` répond : (a) trois cas piège
« est-ce dans le périmètre ? » ; (b) pour chaque critère, « peux-tu le
jouer dans l'app sans autre contexte ? ». Un périmètre raté ou un
critère injouable = reformuler avant livraison. Cap 2 rounds.

## 4. La spec vit — la dérive tracée, pas subie

- Au **proof-run**, chaque critère passe ✅ prouvé / ⚠️ modifié (avec le
  pourquoi) / ❌ abandonné — c'est le « converge » de spec-kit, ramené à
  une table. Un critère de la spec est un check de proof-run tel quel.
- **ship-check** relit la table : un ❌ ou un « — » sans raison au moment
  de publier est un flag.
- Commit de `SPEC.md` seul, sans Co-Authored-By ni mention d'IA.

Place au pipeline : tête de pipeline, avant vibecode. Aval : proof-run
exécute les critères, ship-check audite la table d'état.
