# Veille — AI-Builder-Club/skills (analysé le 03/09/2026)

Repo : https://github.com/AI-Builder-Club/skills (Jason Zhou / AI Builder
Club) — plugin marketplace « loop engineer » : harnais de codebase + boucles
d'agents sur base de connaissances fichiers. Décision record : ce qu'on a
pris, rejeté, et gardé à miner.

## Leur pile, une ligne chacun

- `setup-codebase-harness` — orchestrateur : rendre un repo « legible,
  executable, verifiable » (carte ~100 lignes + lints custom à message
  remédiateur, stack une commande, gate e2e, boucle /verify).
- `verifier-setup` — génère un `/verify` par-repo : sous-agent vérificateur
  frais qui pilote la vraie app, preuve screenshot/vidéo embarquée en PR.
- `dev-local-setup` — scaffolde `scripts/dev-local.sh` (tmux, up/down/status).
- `e2e-setup` — gate e2e per-PR : flux réels (OTP lu depuis Mailpit, jamais
  de code en dur), helper de session (auth vérifiée une fois, court-circuitée
  ensuite), assertions client→serveur→produit, triage du rouge
  (bug/périmé/flaky), garde anti-clé live.
- `crabbox-setup` — box cloud isolée par agent (parallélisme, Daytona).
- `agent-context-audit` — audit CLAUDE.md/skills/outils : six bascules +
  quiz de connaissance + fraîcheur git.
- `new-loop` — base de connaissances fichiers (`signals/ docs/ domains/` +
  `LOG.md`) et boucles récurrentes dessus.
- `open-agent-teams` — délégation à tout CLI (claude/codex/grok…) en tmux
  détaché, sentinelles fichiers (`tdel`).
- `seo-growth`, `visual-flow-gif` — hors pipeline code.

## Adopté (fusionné avec nos règles)

| Trouvaille | Destination |
|---|---|
| Vérificateur indépendant + preuve embarquée en PR | `proof-run` v1 — durci : sabotage du vérificateur (RODAGE), gate différentiel baseline nommée, driver agent-browser |
| Les tests dynamiques s'exécutent, pas seulement se listent | `proof-run --checks` — bras dynamique de ship-check |
| Six bascules + quiz de connaissance + fraîcheur git | `docs-pass` v1 |
| Helper de session — auth vérifiée une fois, rechargée ensuite | `proof-run` §1 |
| Triage du rouge : vrai bug / test périmé / flaky-env | `proof-run` §3 |
| Garde anti-clé live sur services externes | `proof-run --checks` |
| Lint custom à message remédiateur (« X interdit — fais Y ») | `cleanup-pass` couche 3, en sortie de rapport |

## Rejeté (avec raison)

- **SOP générés par-repo hardcodant les faits** (leur pattern verifier-setup) :
  carte qui diverge du territoire ; notre découverte + cache re-vérifié
  (`.proof-run/stack.md`) fait le travail sans dette de fraîcheur.
- **crabbox / open-agent-teams** : infra de parallélisme et de délégation,
  orthogonale au pipeline qualité. À reconsidérer si nos boucles deviennent
  concurrentes.
- **dev-local-setup** : utile mais pas notre angle mort — nos repos portent
  déjà leurs commandes de dev, proof-run les découvre.
- **Aucun protocole de mesure chez eux** : le RODAGE reste notre signature.

## À re-miner plus tard

- `new-loop` : le modèle base-de-connaissances fichiers résonne avec des
  boucles récurrentes (veille, SEO) si on en monte un jour.
- Leur « carte, pas manuel » (CLAUDE.md ≈ 100 lignes = table des matières,
  profondeur dans `docs/`) : déjà l'esprit de la bascule n°2 de docs-pass ;
  à ériger en cible chiffrée si le rodage de docs-pass le confirme.
- `tdel` (sentinelles fichiers plutôt que `tmux wait-for`) : si on pilote
  un jour codex/grok comme exécuteurs.
