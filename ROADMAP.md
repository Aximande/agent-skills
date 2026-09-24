# Roadmap

Pipeline visé : **« du vibecode au shippable »** —
`spec-lite` → vibecode → `proof-run` → `safety-net` → `cleanup-pass` →
`docs-pass` → `ship-check`, avec `react-doctor` (repos React) et
`fluid-pass` (produits UI) avant cleanup-pass, et `doc-ingest`,
`llm-handover`, `excalidraw-slides` en transverses.

Le pipeline est complet (11 skills). Prochaines pistes : les intégrations
graphify (voir Inspirations) et un handoff exécutable pour `llm-handover`.

Méthode : design par grilling (rounds de décisions verrouillées), puis rodage
mesuré sur un vrai repo, puis publication ici. Le détail des rodages est tenu
hors de ce dépôt ; ce qu'un rodage apprend finit en lignes du `SKILL.md`.

## Inspirations

- [andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) — les 4 principes (réfléchir avant de coder, simplicité d'abord, changements chirurgicaux, exécution guidée par des critères vérifiables)
- [mattpocock/skills](https://github.com/mattpocock/skills) — grilling, writing-for-agents, handoff
- [AI-Builder-Club/skills](https://github.com/AI-Builder-Club/skills) — vérificateur indépendant, audit de contexte agent
- [spec-kit](https://github.com/github/spec-kit) — critères d'acceptation avant le code
- [BMAD](https://github.com/bmad-code-org/bmad-method) — QA avant merge
- [markitdown](https://github.com/microsoft/markitdown) — moteur de `doc-ingest`
- karpathy : [rendergit](https://github.com/karpathy/rendergit),
  [autoresearch](https://github.com/karpathy/autoresearch),
  [llm-council](https://github.com/karpathy/llm-council)
- [graphify](https://github.com/Graphify-Labs/graphify) — repo → graphe de connaissances
- le skill `apple-design` (WWDC fluid interfaces, typographie, principes — distillé web) et [dickwu/apple-design-skill](https://github.com/dickwu/apple-design-skill) (review HIG) — croisés dans `fluid-pass`
