# Roadmap

Pipeline visé : **« du vibecode au shippable »** —
`spec-lite` → vibecode → `safety-net` → `cleanup-pass` → `docs-pass` → `ship-check`,
avec `doc-ingest` en utilitaire transverse.

| Skill | Statut | Rôle |
|---|---|---|
| `cleanup-pass` | ✅ v1, rodée (video-trimmer, 31/08/2026) | Repasse qualité à validité constante |
| `doc-ingest` | ✅ v1 | Documents (PDF/Office) → markdown pour le contexte agent (markitdown) |
| `safety-net` | 🔨 en design (grilling) | Tests de caractérisation sur repo non testé — débloque le gate de cleanup-pass |
| `ship-check` | 📋 backlog | Passe pré-publication : secrets (historique + tree), .gitignore, env, RLS Supabase, licence, visibilité |
| `docs-pass` | 📋 backlog | README/quickstart dont chaque commande est réellement exécutée, CONTEXT.md pour la reprise |
| `spec-lite` | 📋 backlog | Une page de critères d'acceptation avant de vibecoder (spec-kit allégé, moteur grilling) |

Méthode par skill : design par grilling (rounds de décisions verrouillées) →
rodage mesuré sur un vrai repo (protocole `RODAGE.md`) → publication ici.

Inspirations : [andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills)
(les 4 principes), [mattpocock-skills](https://github.com/mattpocock) (grilling,
writing-for-agents), [spec-kit](https://github.com/github/spec-kit) (critères
d'acceptation avant le code), [BMAD](https://github.com/bmad-code-org/bmad-method)
(QA avant merge, process scale-adaptive), [markitdown](https://github.com/microsoft/markitdown).
