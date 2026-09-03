---
name: proof-run
description: >
  Preuve d'usage : un sous-agent vérificateur indépendant pilote la vraie
  app (agent-browser / curl / binaire CLI), compare observé vs attendu et
  capture les preuves — la PR embarque la preuve. Use when: « prouve que ça
  marche », « vérifie cette feature dans l'app », avant la PR d'une feature
  vibecodée, ou `--checks` pour exécuter les tests dynamiques de
  VIBECODE-CHECKS (ship-check). Uniquement sur demande explicite.
license: MIT
---

# Proof Run

Nos autres gates prouvent des invariants statiques : safety-net fige le
comportement, cleanup-pass garantit « aucune nouvelle failure », ship-check
audite le code. Aucun ne répond à la question de l'utilisateur final :
**la tâche marche-t-elle vraiment ?** proof-run y répond en pilotant l'app
qui tourne — preuve, pas promesse.

Deux rôles, jamais confondus :

- **L'orchestrateur (toi)** : monte la stack, corrige, relance, livre.
- **Le vérificateur (sous-agent frais, lecture seule)** : n'a pas écrit le
  code, pilote l'app, juge observé vs attendu. Le verdict « ça marche »
  appartient au vérificateur seul — jamais à celui qui a écrit le code.

## 0. Préflight

- Branche de travail (jamais la branche par défaut), changements commités.
- **Stack** : découvrir la commande de démarrage et l'URL/port dans le repo
  (scripts package.json, Makefile, Procfile, docker-compose). Les noter
  dans `.proof-run/stack.md` — cache re-vérifié à chaque run (la commande
  démarre, le port répond), jamais cru sur parole.
- `evidence/` et `.proof-run/` dans `.gitignore`.
- **Critères d'acceptation** : depuis la spec ou le plan s'il en existe un,
  sinon formuler l'intent en « un utilisateur peut désormais <action> et
  observe <état de succès> ». Sans état observable formulable → stop,
  demander à l'utilisateur.

## 1. Driver

- **Web** → `agent-browser` (open / screenshot / snapshot) sur l'URL locale.
- **API** → curl ; corps de réponse + status en preuve.
- **CLI** → le binaire construit ; stdout en preuve.

## 2. Verdict — boucle vérifier → corriger → re-vérifier

Dispatcher un sous-agent vérificateur avec un prompt autoporteur : les
critères d'acceptation, les étapes d'exercice, le driver, l'URL — l'intent,
**jamais l'implémentation ni le diff** (l'indépendance est ce qui donne sa
valeur au verdict). Le vérificateur déroule les étapes exactes, capture
l'état de succès dans `evidence/`, et retourne uniquement :

```
TASK: works | broken
  expected: <critères>
  observed: <ce qui s'est réellement passé>
  evidence: <chemins sous evidence/>
```

`broken` → corriger l'implémentation, relancer un vérificateur **frais**
(jamais le même contexte). Cap : 3 rounds, puis escalade à l'utilisateur
avec le dernier verdict.

## 3. Balayage régression

Après `works` : les checks codifiés du repo (tests, typecheck, build) avec
notre gate différentiel — aucune failure absente de la **baseline nommée**
(`fichier :: test`), mesurée sur arbre purgé des artefacts générés. Une
assertion ne s'affaiblit jamais pour passer au vert. Si la correction d'un
round a changé le comportement visible → re-vérifier (retour au 2).

## 4. Livraison — la PR porte la preuve

PR draft dont le corps **montre** la preuve : screenshot embarqué inline
(uploadé sur une prerelease `pr-evidence` via `gh release upload`, ou en
pièce jointe), verdict expected/observed, commande de reproduction (stack
up + étapes). `evidence/` reste hors git — seul l'artefact uploadé est
référencé. Commits sans Co-Authored-By ni mention d'IA.

## Mode `--checks` — le bras dynamique de ship-check

Dérouler les « **Test :** » de `VIBECODE-CHECKS.md` (skill ship-check)
contre la stack : changer l'ID dans l'URL (IDOR), rejouer un payload
modifié (enforcement serveur), poster un corps surdimensionné (limites
d'entrée), un fichier au mimetype menti (uploads)… Chaque test : ✅ / 🕳️
avec sa preuve dans `evidence/`. Bornes strictes :

- **Uniquement sur une stack locale ou un staging qui appartient à
  l'utilisateur** — la prod d'autrui est hors limites, toujours.
- Rate limiting : lecture du code + un envoi modéré (dizaines, pas
  milliers) ; jamais de volume réel sur une API payante.

## Règles

- Le vérificateur lit et pilote ; le code produit lui reste interdit.
- Le vérificateur reçoit l'intent, jamais l'implémentation.
- PR ouverte seulement après un verdict `works` frais.
- Secrets absents du prompt du vérificateur et d'`evidence/`.

**Fini quand** : verdict `works` d'un vérificateur frais + balayage
régression vert (différentiel) + PR draft avec preuve embarquée.
