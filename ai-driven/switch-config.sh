#!/usr/bin/env bash
# Usage: switch-config.sh [spark|cloud|hybrid]
# Commute le dossier agents de opencode ET de Claude Code (symlink) — mêmes profils.
#   spark  : tout sur qwen3.6-35b (soludevtech)
#   cloud  : implémentations glm-5.3 (ollama-cloud), reviewers + QA kimi-k3
#   hybrid : implémentations qwen3.6-35b (soludevtech), reviewers + QA glm-5.3-flash
# Sans argument: affiche la config active des deux outils.
set -eu

OC_DIR=~/.config/opencode
CC_DIR=~/.claude
profiles=(spark cloud hybrid)
target="${1:-}"

show() {
  echo "Profil actif:"
  echo "  opencode    : $(readlink "${OC_DIR}/agents" 2>/dev/null || echo '(dossier direct)')"
  echo "  claude code : $(readlink "${CC_DIR}/agents" 2>/dev/null || echo '(dossier direct)')"
  echo
  echo "Profils disponibles: ${profiles[*]}"
  echo "Usage: $0 <${profiles[*]}>"
}

if [[ -z "$target" ]]; then
  show
  exit 0
fi

case "$target" in
  spark|cloud|hybrid) ;;
  *) echo "Profil inconnu: $target" >&2; echo "Usage: $0 <${profiles[*]}> (sans arg = état)" >&2; exit 1 ;;
esac

[[ -d "${OC_DIR}/agents-${target}" ]] || { echo "Manquant: ${OC_DIR}/agents-${target}" >&2; exit 1; }
[[ -d "${CC_DIR}/agents-${target}" ]] || { echo "Manquant: ${CC_DIR}/agents-${target}" >&2; exit 1; }

# opencode
rm -f "${OC_DIR}/agents"
ln -s "agents-${target}" "${OC_DIR}/agents"

# claude code
rm -f "${CC_DIR}/agents"
ln -s "agents-${target}" "${CC_DIR}/agents"

# claude code : modèle par défaut dans settings.json
python3 - "$CC_DIR/settings.json" "$target" <<'PY'
import json, sys
path, profile = sys.argv[1], sys.argv[2]
default_model = {
    "spark": "qwen3.6-35b",
    "cloud": "glm-5.3",
    "hybrid": "qwen3.6-35b",
}[profile]
with open(path) as f:
    s = json.load(f)
s.setdefault("env", {})
s["env"]["ANTHROPIC_MODEL"] = default_model
with open(path, "w") as f:
    json.dump(s, f, indent=2)
    f.write("\n")
PY

echo "Profil actif: ${target}"
echo "  opencode    : agents -> $(readlink "${OC_DIR}/agents")"
echo "  claude code : agents -> $(readlink "${CC_DIR}/agents")"