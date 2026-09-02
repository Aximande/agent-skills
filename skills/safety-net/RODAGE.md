# Rodage de /safety-net — protocole de mesure

Après un run de test, quatre mesures :

### 1. Honnêteté du score de sabotage
Refaire soi-même 2-3 mutations *différentes* de celles de l'agent et vérifier
que la suite passe au rouge. Un filet qui n'attrape que les sabotages de son
auteur est un filet de théâtre.

### 2. Stabilité
Lancer la suite 3 fois sur la machine de l'utilisateur (pas celle du run).
Cible : 3/3 verts. Un seul flake = chercher le champ volatil mal scrubbé.

### 3. Lisibilité
L'utilisateur ouvre 2 tests au hasard : comprend-il en < 1 minute ce que
chacun capture ? Des tests de caractérisation illisibles seront supprimés au
premier agacement — et le filet avec.

### 4. Déblocage effectif (le but final)
Lancer `/cleanup-pass` après merge : le préflight doit détecter le filet et
sortir du mode rapport. C'est le critère de succès du pipeline entier.

## Compliance (vérifiable dans git + rapport)

- [ ] working tree vérifié propre ; branche `safety-net/<date>`
- [ ] cibles exclues motivées une par une (LLM, intestable, UI)
- [ ] code produit intact (diff ne touche que tests/ et deps de test)
- [ ] score sabotage X/N présent, sabotages non commitées
- [ ] tests existants non modifiés
- [ ] rapport `.safety-net/rapport-<date>.md` présent

Chaque case décochée = défaut de rédaction du SKILL.md, à reformuler.
