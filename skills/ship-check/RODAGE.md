# Rodage de /ship-check — protocole de mesure

### 1. Précision (faux positifs)
L'utilisateur vérifie chaque finding NO-GO/⚠️ : % de vrais problèmes. Un
rapport qui crie au loup sera ignoré dès le deuxième run — cible ≥ 90 %.

### 2. Rappel (faux négatifs)
L'utilisateur, qui connaît ses cadavres (audit d'août 2026 : secrets
historisés, RLS ouvertes) : qu'est-ce que le skill aurait dû voir ?

### 3. Actionnabilité
Chaque finding porte-t-il fichier:ligne + commande de correction ? Le
verdict GO/NO-GO est-il tranché ou mou ?

## Compliance (vérifiable)

- [ ] aucun secret réaffiché ni commité (empreintes tronquées seulement)
- [ ] Supabase : lecture seule, zéro modification
- [ ] auto-fix limité à .gitignore / licence / .env.example
- [ ] sections non applicables marquées N/A avec raison
- [ ] rapport « Au-delà du ship-check » présent si app à utilisateurs

Case décochée = défaut de rédaction du SKILL.md, à reformuler.
