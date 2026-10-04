#!/usr/bin/env bash
# Usage: ./switch-config.sh [spark|cloud|hybrid]
# Bascule uniquement le dossier agents — opencode.json est un fichier unique fusionné
# (tous les providers/modèles des profils y sont déclarés, l'auth ollama-cloud est globale via /connect)
#   spark  : tous les agents sur soludevtech/qwen3.6-35b
#   cloud  : implémentations sur ollama-cloud/glm-5.3, reviewers + QA sur ollama-cloud/kimi-k3
#   hybrid : implémentations sur soludevtech/qwen3.6-35b, reviewers + QA sur ollama-cloud/glm-5.3-flash
# Sans argument: affiche la config active et les profils disponibles
set -eu
cd ~/.config/opencode

profiles=(spark cloud hybrid)
target="${1:-}"

if [[ -z "$target" ]]; then
  echo "Config active:"
  if [[ -L agents ]]; then
    echo "  agents -> $(readlink agents)"
  else
    echo "  agents (dossier direct)"
  fi
  echo
  echo "Profils disponibles: ${profiles[*]}"
  echo "Usage: $0 <${profiles[*]}>"
  exit 0
fi

case "$target" in
  spark|cloud|hybrid) ;;
  *) echo "Profil inconnu: $target" >&2; echo "Usage: $0 <${profiles[*]}>" >&2; exit 1 ;;
esac

[[ -d "agents-${target}" ]] || { echo "Manquant: agents-${target}" >&2; exit 1; }

rm -f agents
ln -s "agents-${target}" agents

echo "Config active: ${target}"
echo "  agents -> $(readlink agents)"
