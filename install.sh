#!/usr/bin/env bash
# Installe les skills du repo pour Claude Code (~/.claude/skills),
# le standard agent-skills (~/.agents/skills, utilisé par Codex CLI)
# et Cursor (~/.cursor/commands, fichier commande pointant vers le SKILL.md).
# Par défaut : symlinks (git pull suffit à mettre à jour).
# ./install.sh --copy : copie réelle, à relancer après chaque git pull.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
MODE="${1:-link}"

for skill_dir in "$REPO_DIR"/skills/*/; do
  skill="$(basename "$skill_dir")"

  for target in "$HOME/.claude/skills" "$HOME/.agents/skills"; do
    mkdir -p "$target"
    rm -rf "${target:?}/$skill"
    if [ "$MODE" = "--copy" ]; then
      cp -R "$skill_dir" "$target/$skill"
    else
      ln -s "${skill_dir%/}" "$target/$skill"
    fi
    echo "✓ $target/$skill"
  done

  mkdir -p "$HOME/.cursor/commands"
  cat > "$HOME/.cursor/commands/$skill.md" <<EOF
# $skill

Lis le fichier \`$REPO_DIR/skills/$skill/SKILL.md\` et exécute-le exactement
comme prescrit, du préflight à la livraison, sans sauter d'étape.
EOF
  echo "✓ ~/.cursor/commands/$skill.md"
done
