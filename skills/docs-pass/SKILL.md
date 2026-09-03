---
name: docs-pass
description: >
  Passe documentation post-vibecoding : README/quickstart dont chaque
  commande est réellement exécutée, quiz de connaissance (les docs seuls
  doivent répondre), audit du contexte agent (CLAUDE.md, skills du repo)
  par les six bascules, doc de reprise si absente. Corrections prouvées en
  commits, le structurel en rapport. Use when: « passe les docs au propre »,
  « audite le README / CLAUDE.md », « rends ce repo lisible », avant de
  partager un repo. Uniquement sur demande explicite.
license: MIT
---

# Docs Pass

Rendre le repo **lisible** — pour l'humain qui débarque et pour l'agent qui
reprend. La règle unique : **une doc n'affirme que ce qui a été prouvé** —
une commande citée est une commande exécutée, un fait cité est un fait
vérifié contre le repo. Le skill édite la documentation, jamais le code :
du code cassé révélé par l'épreuve part au rapport.

## 0. Préflight — inventaire de la surface

- Docs humaines : README, quickstart, `docs/`, `.env.example`.
- Contexte agent : CLAUDE.md / AGENTS.md / .cursorrules /
  copilot-instructions, skills et commandes du repo. Noter la taille
  (lignes) de ce qui est **toujours chargé** — le poids total est un
  finding en soi.
- Fraîcheur : `git log -1 --format=%cs -- <doc>` vs le churn récent du
  code — une doc intacte depuis des mois dans un repo actif est présumée
  périmée ; une zone churny sans doc est un trou présumé. Présomption,
  pas verdict : chaque cas se vérifie avant d'être signalé.
- Branche `docs/<YYYY-MM-DD>`, working tree propre.

## 1. Épreuve d'exécution — chaque commande du README tourne

Dérouler le README/quickstart en copier-coller strict, dans l'ordre, comme
un nouvel arrivant :

- Commande qui échoue → finding avec la sortie exacte.
- Étape implicite manquante (« installer X d'abord ») → trou.
- Commandes destructives, payantes ou longues (deploy, migration prod,
  téléchargement massif) → non exécutées, marquées « non exécutable en
  audit » avec la raison.

La doc réparée ne garde que des commandes qui ont tourné.

## 2. Quiz de connaissance — les docs seuls répondent

Écrire 5–10 questions qu'un agent frais doit savoir pour travailler ici
sans danger : comment lancer UN test ? que ne faut-il jamais commiter ?
quelle est la source de vérité pour X ? quel est le piège du build ?
Répondre en n'utilisant **que** les docs auditées. Sans réponse = trou ;
réponse fausse = doc périmée. Chaque trou comblé cite sa question.

## 3. Audit du contexte agent — les six bascules

Sur CLAUDE.md & co, chaque finding cite fichier:ligne + la réécriture
proposée (ou « supprimer », avec une ligne de pourquoi c'est sûr) :

1. **Règles → jugement** : une règle dure qui encode une préférence devient
   un cadrage de jugement, ou disparaît si le modèle l'inférerait seul.
   Les règles dures restent où la violation coûte vraiment (sécurité,
   prod, irréversible, légal) — retirer les fausses contraintes, jamais
   les vraies.
2. **Toujours-chargé → divulgation progressive** : le long conditionnel
   (checklist, runbook, deep-dive) part dans un skill ou fichier lié,
   un pointeur reste.
3. **Répétition → une seule maison** par instruction — les copies
   divergent puis se contredisent.
4. **Conflits entre couches** — le finding le plus précieux : deux docs
   qui se contredisent forcent l'agent à trancher à chaque tâche. Citer
   les deux emplacements.
5. **Faits périmés** : tout fait signalé périmé a été vérifié contre le
   repo (le script existe-t-il ? la commande tourne-t-elle ?).
6. **Unknown knowns manquants** : le piège que l'équipe connaît et que
   rien n'écrit (l'étape de build non évidente, le dossier à ne pas
   toucher, le pourquoi d'un pattern bizarre) — c'est exactement ce pour
   quoi CLAUDE.md existe.

## 4. Doc de reprise (si absente)

Si rien ne permet à un agent de reprendre le projet à froid : générer une
page courte — état, décisions structurantes et leur pourquoi, prochaines
étapes — à l'emplacement conventionnel du repo (CONTEXT.md, `docs/`).

## Livraison

Même discipline que cleanup-pass :

1. **Commits** sur la branche, un par nature de changement, chemins du lot
   uniquement : commandes réparées **et re-exécutées**, faits corrigés,
   dégraissage du toujours-chargé, trous du quiz comblés.
2. **Rapport** `.docs-pass/rapport-<date>.md` (non commité, non tracké) :
   findings fichier:ligne + réécriture, code cassé révélé par l'épreuve,
   quiz complet (questions / réponses / verdicts), restructurations
   proposées, et un bloc **Stats** : commandes testées/réparées, questions
   du quiz répondues avant→après, lignes toujours-chargées avant→après.
3. Remote présent → push + PR draft, rapport en description.
4. Commits sans Co-Authored-By ni mention d'IA.

**Fini quand** : chaque commande restante de la doc a tourné, chaque
question du quiz a sa réponse dans les docs, zéro conflit entre couches
non signalé, rapport + PR draft livrés.
