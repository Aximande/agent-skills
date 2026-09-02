# Rodage de /cleanup-pass — protocole de mesure

Grille de débrief après un run de test. But : calibrer le skill sur du réel
(agressivité, jugement, compliance) et éditer SKILL.md avec les constats.

## Données produites par construction (rien à préparer)

- **Un commit par lot** sur `cleanup/<date>` → chaque décision du skill est une
  unité de review isolée : `git log --oneline main..cleanup/<date>`.
- **Diff global** : `git diff main...cleanup/<date> --shortstat` (lignes
  avant/après).
- **Rapport** : `.cleanup/rapport-<date>.md` — lots + hashes, baseline rouge,
  items couche 3.

## Les 4 mesures du débrief

### 1. Validité (dur, non négociable)
Gate vert ET smoke test manuel : lancer l'app/le script, vérifier les parcours
principaux. Cible : **zéro régression**. Une seule régression = bug critique du
skill, on remonte à la cause (lot fautif via son commit) avant tout autre
ajustement.

### 2. Taux d'acceptation (le KPI qualité)
Pour chaque commit de couche 2, l'utilisateur note :
- ✅ je mergerais tel quel
- ⚠️ bonne idée, exécution à retoucher
- ❌ je reverte

Cibles : **≥ 80 % de ✅** = calibrage bon. 50-80 % = ajuster (lire les ⚠️/❌
pour savoir quoi). **< 50 % = agressivité ou jugement à revoir** dans SKILL.md.

### 3. Pertinence du rapport (couche 3 + signalements)
Par item : « oui il faudrait vraiment le faire » vs bruit. Un rapport à
majorité bruit = le skill remonte tout au lieu de juger.

### 4. Faux négatifs (le plus dur, connaissance du repo requise)
L'utilisateur, qui connaît le repo : qu'est-ce que le skill aurait dû voir ?
(dead code évident laissé, duplication ratée, docstring absente sur l'API qui
compte). Liste courte, c'est le signal « trop timide ».

## Compliance (le document a-t-il piloté l'agent ?)

Checklist binaire, vérifiable dans git + rapport :
- [ ] working tree vérifié propre avant de commencer
- [ ] branche `cleanup/<date>` créée, main intact
- [ ] baseline enregistrée et citée dans le rapport
- [ ] commits séparés couche 1 / couche 2, un par lot
- [ ] gate lancé après chaque lot (visible dans le déroulé de session)
- [ ] packages sans filet → zéro commit, rapport seulement
- [ ] aucun Co-Authored-By / mention IA dans les commits
- [ ] `.cleanup/rapport-<date>.md` présent

Chaque case décochée = défaut de rédaction du SKILL.md (variance), pas une
excuse : reformuler la règle concernée.

## Après le débrief

Éditer SKILL.md avec les constats (une cause → une édition), noter le taux
d'acceptation du run dans la mémoire projet, et refaire un run sur un second
repo différent (autre langage si possible) avant de considérer le skill
calibré.
