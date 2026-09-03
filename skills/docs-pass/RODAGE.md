# Rodage de /docs-pass — protocole de mesure

### 1. Épreuve du nouvel arrivant

Un agent frais (ou l'utilisateur) suit le README réparé de bout en bout
sur un checkout propre : arrive-t-il au run sans aide extérieure ? C'est
le verdict qui compte — une doc réparée qui ne porte pas un nouvel
arrivant a raté sa cible.

### 2. Précision des findings

Chaque « périmé » / « conflit » / « à supprimer » vérifié par
l'utilisateur : % de vrais problèmes, cible ≥ 90 % (même barre que
ship-check). Supprimer une vraie contrainte compte double en faux positif.

### 3. Le quiz pose-t-il les bonnes questions ?

L'utilisateur connaît ses pièges : lesquels le quiz a-t-il manqués ?
Chaque piège manqué devient une question type à encoder dans le SKILL.md.

## Compliance (vérifiable)

- [ ] zéro modification de code (code cassé → rapport)
- [ ] chaque commande gardée dans la doc a été réellement exécutée
- [ ] commandes destructives/payantes non exécutées, marquées avec raison
- [ ] chaque conflit cite les deux emplacements
- [ ] chaque fait signalé périmé vérifié contre le repo
- [ ] bloc Stats présent (commandes, quiz, lignes toujours-chargées)

Case décochée = défaut de rédaction du SKILL.md, à reformuler.
