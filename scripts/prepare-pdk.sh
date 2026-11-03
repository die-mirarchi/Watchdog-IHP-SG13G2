#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/tools-config/toolchain.lock"
PDK_SOURCE="$ROOT/.local/pdks/IHP-Open-PDK"
if [[ ! -d "$PDK_SOURCE/.git" ]]; then
    mkdir -p "$(dirname "$PDK_SOURCE")"
    git clone https://github.com/IHP-GmbH/IHP-Open-PDK.git "$PDK_SOURCE"
fi
if [[ $(git -C "$PDK_SOURCE" rev-parse HEAD) != "$IHP_PDK_COMMIT" ]]; then
    git -C "$PDK_SOURCE" diff --quiet && git -C "$PDK_SOURCE" diff --cached --quiet || {
        echo 'El PDK tiene cambios locales. Conservarlos antes de actualizar.' >&2; exit 1;
    }
    git -C "$PDK_SOURCE" fetch origin "$IHP_PDK_COMMIT"
    git -C "$PDK_SOURCE" checkout --detach "$IHP_PDK_COMMIT"
fi
git -C "$PDK_SOURCE" submodule update --init --recursive
bash "$ROOT/scripts/eda.sh" prepare-pdk
printf '%s\n' "$IHP_PDK_COMMIT" > "$PDK_SOURCE/ihp-sg13g2/COMMIT"
