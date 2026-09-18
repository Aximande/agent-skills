---
name: react-doctor
description: >
  Diagnostic React/Next post-vibecoding : pose l'outillage déterministe
  (lint hooks) au lieu de le paraphraser, audite les pathologies que le
  lint ne voit pas (useEffect pour état dérivé, frontière server/client,
  secrets dans le bundle client, instanciation module-level), et prouve
  les findings perf par mesure de re-renders dans la vraie app. Use when:
  « diagnostique ce repo React », « pourquoi ça re-render », « passe
  react-doctor », ou /react-doctor sur un repo React/Next. Uniquement sur
  demande explicite.
license: MIT
---

# React Doctor

Diagnostic de la **mécanique React** d'un repo vibecodé — pas des pixels
(interfaces/better-* et frontend-dev s'en chargent). Trois principes :

- **Le déterministe d'abord** : si une règle lint attrape un pattern, la
  réponse est *poser la règle*, jamais la paraphraser en prose. Le skill
  installe l'outillage, il ne le concurrence pas.
- **Un finding est prouvé** — une mesure, un repro ou une preuve
  greppable — jamais une opinion.
- **Validité constante** : gate différentiel comme cleanup-pass — aucune
  nouvelle failure lint/tests/tsc/build. Sans filet → mode rapport
  (safety-net d'abord).

## 0. Préflight

- Détection : React seul ou Next (App Router / Pages) ? TS ? bundler ?
- **Context7 obligatoire** : recharger la doc React/Next courante avant
  tout diagnostic — interdiction d'affirmer une API de mémoire, React 19
  et Next 15-16 ont bougé.
- État de l'outillage : le linter du repo peut être **ESLint, oxlint ou
  Biome** — vérifier la couverture hooks de *celui qui est là* avant d'en
  poser un autre (un scan qui ne cherche qu'eslint conclut à tort
  « aucun lint »). Présent ? **exécuté** ? vert ? Un lint installé qui ne
  tourne pas est un finding en soi.
- Baseline par **liste nommée** des violations existantes, jamais par
  comptage.
- Filet tests/typecheck relevé ; branche `react/<YYYY-MM-DD>`.
- **WIP utilisateur non commité sur un fichier cible → les fixes de ce
  fichier partent au rapport**, jamais en commit (on n'embarque pas le
  travail en cours de quelqu'un dans ses propres commits).

## 1. Poser l'outillage (commit séparé, réversible)

- Lint hooks absent → l'installer et le brancher (flat config ESLint 9),
  baseline nommée des violations qu'il révèle.
- **React Compiler : jamais imposé** — il change le build. Évaluer
  l'éligibilité (healthcheck) et le proposer au rapport, avec ce qu'il
  remplacerait (les useMemo/useCallback manuels du repo).
- Une pathologie couvrable par une règle custom → la règle avec message
  remédiateur part au rapport (pattern cleanup-pass couche 3).

## 2. Audit — ce que le lint ne voit pas

Chaque finding cite fichier:ligne + la réécriture proposée ou le repro :

- `useEffect` pour de l'**état dérivé** → calcul au rendu (ou useMemo).
- Fetch/poll-in-effect sans gestion de course — fix canonique : flag
  `ignore` (ou token de génération) posé en cleanup ; AbortController
  seul ne suffit pas (doc React). Chercher aussi les **gardes mortes** :
  un `cancelled` déclaré et testé partout mais jamais mis à `true`.
- **Instanciation au niveau module** de clients SDK (OpenAI, Supabase…) :
  build otage des env vars → instanciation paresseuse (piège déjà payé
  sur un vrai projet).
- `key={index}` sur listes réordonnables ou filtrables.
- État dupliqué, prop drilling pathologique, context fourre-tout →
  structurel, au **rapport** seulement.
- Sur un composant > 1 000 lignes : **second passage par un agent
  frais** — deux audits indépendants trouvent des ensembles de findings
  partiellement disjoints (mesuré au rodage) ; le rapport est l'union.

Si Next détecté :

- **Frontière server/client** : `"use client"` au plus bas niveau utile ;
  composant serveur qui importe du code client par accident.
- **Secrets dans le bundle client** : builder puis grepper
  `.next/static` — toute valeur d'env non `NEXT_PUBLIC_` qui y apparaît
  est un finding critique (preuve greppable). Le verdict sécurité global
  reste à ship-check : signaler et renvoyer, ne pas dupliquer l'audit.
- Caching/revalidate/server actions : chaque affirmation vérifiée contre
  la doc Context7 du jour, pas de mémoire.

## 3. Preuve dynamique — re-renders mesurés

Uniquement si l'app tourne localement (réutiliser la découverte de stack
de proof-run) ; sinon les findings perf partent au rapport, non prouvés
et dits tels.

- Instrumenter l'interaction clé (React Profiler `onRender` ou compteur
  de renders), piloter via agent-browser.
- Mesurer **avant** → fixer → mesurer **après**. Un fix perf n'entre en
  commit que si la mesure bouge ; sinon rapport.
- Services externes/LLM : stack locale uniquement, jamais de clé live.

## Livraison

1. Commits par nature : outillage / fixes gated (chacun vert au gate
   différentiel) — le structurel reste au rapport.
2. Rapport `.react-doctor/rapport-<date>.md` (non commité, non tracké) :
   findings fichier:ligne, baseline lint nommée, mesures avant→après,
   propositions (React Compiler, règles custom, restructurations), et un
   bloc **Stats** : violations lint avant→après, renders avant→après par
   interaction, lignes de code retirées.
3. Remote présent → push + PR draft, rapport en description.
4. Commits sans Co-Authored-By ni mention d'IA.

Place au pipeline : **avant cleanup-pass** — le lint posé ici devient une
source de vérité que cleanup-pass exploite ensuite. graphify opportuniste
(composants god par degré entrant) ; fallback manuel sinon.
