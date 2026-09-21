<p align="center">
  <img src="assets/banner.svg" alt="agent-skills — du vibecode au shippable" width="100%">
</p>

<div align="center">

**Des skills rodés, pas des prompts.**

Chaque skill est mesuré sur un vrai repo avant publication : on sabote le code
pour vérifier qu'il détecte, et les leçons du terrain sont réécrites dans le skill.

*(Battle-tested agent skills in the open [SKILL.md](https://agentskills.io) format —
for Claude Code, Codex CLI, Cursor and any compatible tool.)*

<br/>

[![Format SKILL.md](https://img.shields.io/badge/format-SKILL.md-58A6FF?style=flat-square)](https://agentskills.io)
![Skills](https://img.shields.io/badge/skills-10-3FB950?style=flat-square)
![Compatible](https://img.shields.io/badge/Claude_Code_·_Codex_·_Cursor-compatible-8957E5?style=flat-square)
[![Licence MIT](https://img.shields.io/badge/licence-MIT-8B949E?style=flat-square)](LICENSE)

</div>

---

## Le pipeline

Partir d'un repo vibecodé qui « marche sur ma machine » et le rendre shippable,
chaque étape gatée par une preuve. (*vibecode* n'est pas un skill : c'est vous.)

```mermaid
flowchart LR
    SL([spec-lite]) --> VC{{vibecode}} --> PR([proof-run]) --> SN([safety-net]) --> CP([cleanup-pass]) --> DP([docs-pass]) --> SC([ship-check])
    SN -. repo React .-> RD([react-doctor])
    RD -.-> CP
    SN -. produit UI .-> FP([fluid-pass])
    FP -.-> CP
```

| Skill | Rôle |
|---|---|
| [`proof-run`](skills/proof-run/SKILL.md) | Un vérificateur indépendant pilote la vraie app et embarque la preuve dans la PR |
| [`safety-net`](skills/safety-net/SKILL.md) | Tests de caractérisation sur un repo non testé, prouvés par sabotage |
| [`react-doctor`](skills/react-doctor/SKILL.md) | Diagnostic React/Next : pose le lint hooks, audite ce que le lint ne voit pas |
| [`fluid-pass`](skills/fluid-pass/SKILL.md) | Repasse « feel » à la Apple : gestes 1:1, springs interruptibles, latences mesurées dans la vraie app ; mode amélioration anti-template |
| [`cleanup-pass`](skills/cleanup-pass/SKILL.md) | Code plus court à comportement constant, gaté par les tests du repo |
| [`docs-pass`](skills/docs-pass/SKILL.md) | Un README dont chaque commande a réellement été exécutée |
| [`ship-check`](skills/ship-check/SKILL.md) | Audit pré-publication : secrets, dépendances, RLS, surface applicative |

`spec-lite`, en tête de pipeline, est encore en backlog ([ROADMAP](ROADMAP.md)).

En dehors du pipeline, trois skills transverses :

| Skill | Rôle |
|---|---|
| [`doc-ingest`](skills/doc-ingest/SKILL.md) | PDF et documents Office convertis en markdown pour le contexte agent |
| [`llm-handover`](skills/llm-handover/SKILL.md) | Handover vers un autre LLM, vérifié par un agent frais qui ne voit que le document |
| [`excalidraw-slides`](skills/excalidraw-slides/SKILL.md) | Présentations Excalidraw éditables, avec notes orales et contrôle visuel |

## Installation

```bash
git clone https://github.com/Aximande/agent-skills.git
cd agent-skills && ./install.sh
```

`install.sh` symlinke les skills vers les emplacements standards — un seul
exemplaire, mis à jour par `git pull` (`--copy` pour copier au lieu de symlinker).

<details>
<summary><strong>Claude Code</strong></summary>
<br/>

Symlinks vers `~/.claude/skills/` : slash commands (`/cleanup-pass`,
`/ship-check`…) ou langage naturel (« nettoie ce repo »).

</details>

<details>
<summary><strong>Codex CLI et le standard agent-skills</strong></summary>
<br/>

Symlinks vers `~/.agents/skills/`, chargés automatiquement quand la tâche
correspond.

</details>

<details>
<summary><strong>Cursor</strong></summary>
<br/>

Commandes générées dans `~/.cursor/commands/`, pointant vers le SKILL.md du clone.

</details>

<details>
<summary><strong>Sans cloner</strong></summary>
<br/>

```bash
npx skills add Aximande/agent-skills
```

Copie les skills choisis comme fichiers éditables dans votre projet.
`npx skills update` pour récupérer les dernières versions.

</details>

<details>
<summary><strong>Autre agent (Gemini CLI, aider…)</strong></summary>
<br/>

Le SKILL.md est du markdown autoporteur — collez dans le prompt :
« Lis `skills/cleanup-pass/SKILL.md` et exécute exactement comme prescrit. »

</details>

Pour un usage par projet plutôt que global : copiez `skills/<nom>/` dans le
`.claude/skills/` du repo, le skill voyage alors avec lui pour toute l'équipe.

## La méthode

Un skill naît d'une session de grilling : des rounds de questions serrées
jusqu'à ce que les décisions soient verrouillées. La v1 arrive avec son
protocole de mesure, écrit avant le premier run. Le rodage se fait sur un
vrai repo, jamais sur un exemple jouet — on y injecte des pathologies connues
pour vérifier que le skill les attrape, et chaque défaut observé devient une
ligne du SKILL.md.

Le socle vient des [4 principes d'Andrej Karpathy](https://github.com/multica-ai/andrej-karpathy-skills) :
un code meilleur est un code plus court, jamais au prix du comportement. Ce qui
ne peut pas être prouvé part en rapport, pas en commit. Les autres inspirations
sont créditées dans la [ROADMAP](ROADMAP.md).

## Licence

[MIT](LICENSE). Le socle conceptuel hérite d'andrej-karpathy-skills (MIT).
