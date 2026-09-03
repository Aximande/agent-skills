# Rodage de /proof-run — protocole de mesure

### 1. Fiabilité du verdict — sabotage du vérificateur

La mesure signature : saboter volontairement la feature (casser l'état de
succès) et relancer un vérificateur frais — il doit dire `broken`. Un
vérificateur qui dit `works` sur une feature sabotée est disqualifié :
reformuler le prompt de vérification avant tout autre run. Score X/N sur
≥ 3 sabotages, comme le filet de safety-net.

### 2. Indépendance

Relire le prompt envoyé au vérificateur : contient-il l'implémentation, le
diff, ou une formulation qui souffle la réponse ? L'intent seul.

### 3. Coût

Rounds nécessaires (cible : 1–2), temps total, poids des preuves.

## Compliance (vérifiable)

- [ ] verdict final rendu par un vérificateur frais, jamais par l'orchestrateur
- [ ] code produit jamais modifié par le vérificateur
- [ ] cap 3 rounds respecté (escalade ensuite, pas de round 4)
- [ ] `evidence/` et `.proof-run/` gitignorés, zéro preuve commitée
- [ ] `--checks` : stack locale/staging de l'utilisateur uniquement, volumes modérés
- [ ] PR ouverte seulement après `works`

Case décochée = défaut de rédaction du SKILL.md, à reformuler.
