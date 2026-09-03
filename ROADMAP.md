# Roadmap

Pipeline visé : **« du vibecode au shippable »** —
`spec-lite` → vibecode → `safety-net` → `cleanup-pass` → `docs-pass` → `ship-check`,
avec `doc-ingest` en utilitaire transverse.

| Skill | Statut | Rôle |
|---|---|---|
| `cleanup-pass` | ✅ v1, rodée (video-trimmer, 31/08/2026) | Repasse qualité à validité constante |
| `doc-ingest` | ✅ v1 | Documents (PDF/Office) → markdown pour le contexte agent (markitdown) |
| `safety-net` | ✅ v1 livrée (02/09/2026), à roder | Tests de caractérisation sur repo non testé — débloque le gate de cleanup-pass |
| `ship-check` | ✅ v1 livrée (03/09/2026), à roder | Audit pré-publication GO/NO-GO : secrets, deps, hygiène+légal, RLS Supabase, surface vibecode (checklist des captures) |
| `docs-pass` | 📋 backlog | README/quickstart dont chaque commande est réellement exécutée, CONTEXT.md pour la reprise |
| `spec-lite` | 📋 backlog | Une page de critères d'acceptation avant de vibecoder (spec-kit allégé, moteur grilling) |

Méthode par skill : design par grilling (rounds de décisions verrouillées) →
rodage mesuré sur un vrai repo (protocole `RODAGE.md`) → publication ici.

Inspirations : [andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills)
(les 4 principes), [mattpocock-skills](https://github.com/mattpocock) (grilling,
writing-for-agents), [spec-kit](https://github.com/github/spec-kit) (critères
d'acceptation avant le code), [BMAD](https://github.com/bmad-code-org/bmad-method)
(QA avant merge, process scale-adaptive), [markitdown](https://github.com/microsoft/markitdown),
[autoresearch](https://github.com/karpathy/autoresearch) (boucle agent = un fichier
modifiable + une métrique + un budget fixe + keep/discard ; « program.md is
essentially a super lightweight skill »), [rendergit](https://github.com/karpathy/rendergit)
(repo → une page, intégré à doc-ingest), [llm-council](https://github.com/karpathy/llm-council)
(délibération multi-LLM — piste future pour une revue en second avis ;
anonymiser les réponses pour juger sans favoritisme),
[graphify](https://github.com/Graphify-Labs/graphify) (repo → graphe de
connaissances interrogeable, AST déterministe local, chaque arête taguée
EXTRACTED/INFERRED).

## Intégrations outillées envisagées (après pilote graphify sur un vrai repo)

- **cleanup-pass couche 2** : preuve d'inatteignabilité du dead code par le
  graphe (arêtes EXTRACTED = preuve ; INFERRED ou absence = doute → rapport)
  au lieu du grep multi-angles.
- **safety-net préflight** : ordre de ROI des cibles par centralité (degree)
  des nœuds du graphe.
- **install.sh** : adopter le pattern `--project` de graphify (install
  par-repo committable en plus du global).
- **Enforcement par hook plutôt que par consigne** (leur « strict mode » :
  bloquer/rediriger une action au niveau harness) — la réponse structurelle
  au constat de Karpathy « instructions in CLAUDE.md don't suffice ».
