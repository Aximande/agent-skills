# agent-skills

Skills d'agent au format ouvert [Agent Skills](https://agentskills.io) (`SKILL.md`),
utilisables tels quels dans Claude Code, Codex CLI et tout outil compatible.
*(Agent skills in the open SKILL.md format — work as-is in Claude Code, Codex CLI
and any compatible tool.)*

## Skills

| Skill | Description |
|---|---|
| [`cleanup-pass`](skills/cleanup-pass/SKILL.md) | Repasse de nettoyage sur un repo fonctionnel issu de vibecoding : maximise la qualité (code plus court, dead code retiré, docstrings publiques) à validité constante (aucune nouvelle failure tests/typecheck/build). Python, TS/JS, notebooks. |
| [`doc-ingest`](skills/doc-ingest/SKILL.md) | Amène des documents (PDF, DOCX, PPTX, XLSX) dans le contexte agent en markdown propre via markitdown — avec la logique de décision lecture native vs conversion. |

Skills à venir : voir la [ROADMAP](ROADMAP.md) (`safety-net`, `ship-check`,
`docs-pass`, `spec-lite`).

Chaque skill est accompagné de son protocole de mesure (`RODAGE.md`) : grille de
débrief, KPI (taux d'acceptation par commit ≥ 80 %), checklist de compliance.

## Installation

```bash
git clone https://github.com/Aximande/agent-skills.git
cd agent-skills && ./install.sh
```

`install.sh` symlinke les skills vers les emplacements standards (un seul
exemplaire, mis à jour par `git pull`) :

- `~/.claude/skills/` — **Claude Code** : `/cleanup-pass` disponible dans toute
  session (ou « nettoie / épure ce repo »).
- `~/.agents/skills/` — **Codex CLI** (et tout outil du standard agent-skills) :
  chargé automatiquement quand la tâche correspond.
- `~/.cursor/commands/cleanup-pass.md` — **Cursor** : commande `/cleanup-pass`
  générée, qui pointe vers le SKILL.md du clone.

`./install.sh --copy` copie au lieu de symlinker (si votre outil ne suit pas
les symlinks) ; relancer après chaque `git pull`.

### Autre agent (Gemini CLI, aider, etc.)

Le SKILL.md est du markdown autoporteur : collez dans le prompt
« Lis `skills/cleanup-pass/SKILL.md` et exécute la repasse exactement comme
prescrit, du préflight à la livraison. »

### Par projet plutôt que global

Copiez `skills/cleanup-pass/` dans `.claude/skills/` (Claude Code) ou le
fichier commande dans `.cursor/commands/` du projet : le skill voyage alors
avec le repo pour toute l'équipe.

## Philosophie

Fondé sur les [4 principes d'Andrej Karpathy](https://github.com/multica-ai/andrej-karpathy-skills)
(MIT) : un code meilleur est un code plus court, mais **jamais au prix du
comportement** — chaque passe est gatée par les tests/typecheck/build du repo,
et tout ce qui ne peut pas être prouvé part en rapport plutôt qu'en commit.

## Licence

[MIT](LICENSE). Le socle conceptuel hérite d'andrej-karpathy-skills (MIT).
