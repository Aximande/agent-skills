# Roadmap

Pipeline visé : **« du vibecode au shippable »** —
`spec-lite` → vibecode → `proof-run` → `safety-net` → `cleanup-pass` →
`docs-pass` → `ship-check`, avec `react-doctor` avant cleanup-pass sur les
repos React, et `doc-ingest`, `llm-handover`, `excalidraw-slides` en
transverses.

À venir : `spec-lite` — une page de critères d'acceptation avant de vibecoder
(spec-kit allégé).

Méthode : design par grilling (rounds de décisions verrouillées), puis rodage
mesuré sur un vrai repo, puis publication ici. Le détail des rodages est tenu
hors de ce dépôt ; ce qu'un rodage apprend finit en lignes du `SKILL.md`.

## Inspirations

- [andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) — les 4 principes
- [mattpocock/skills](https://github.com/mattpocock/skills) — grilling, writing-for-agents, handoff
- [AI-Builder-Club/skills](https://github.com/AI-Builder-Club/skills) — vérificateur indépendant, audit de contexte agent
- [spec-kit](https://github.com/github/spec-kit) — critères d'acceptation avant le code
- [BMAD](https://github.com/bmad-code-org/bmad-method) — QA avant merge
- [markitdown](https://github.com/microsoft/markitdown) — moteur de `doc-ingest`
- karpathy : [rendergit](https://github.com/karpathy/rendergit),
  [autoresearch](https://github.com/karpathy/autoresearch),
  [llm-council](https://github.com/karpathy/llm-council)
- [graphify](https://github.com/Graphify-Labs/graphify) — repo → graphe de connaissances
