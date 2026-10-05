#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/tools-config/toolchain.lock"
[[ ! -d /foss/pdks ]] || { echo 'Ejecutar desde Ubuntu/WSL, fuera de Distrobox.' >&2; exit 1; }
command -v podman >/dev/null || { echo 'Ejecutar bash setup.sh primero.' >&2; exit 1; }
podman image exists "$OSIC_IMAGE" || { echo 'Falta la imagen. Ejecutar bash setup.sh.' >&2; exit 1; }
mkdir -p "$ROOT/.local/home" "$ROOT/build" "$ROOT/results"
args=(run --rm --init --hostname "$(hostname)" --userns=keep-id --user "$(id -u):$(id -g)"
    --security-opt=no-new-privileges --cap-drop=all
    --volume "$ROOT:/workspace:rw" --workdir /workspace
    --env HOME=/workspace/.local/home --env PDK=ihp-sg13g2
    --env PDK_ROOT=/foss/pdks --env THESIS_IMAGE="$OSIC_IMAGE"
    --entrypoint /bin/bash)
[[ -t 0 && -t 1 ]] && args+=(-it)
if [[ -n ${DISPLAY:-} && -d /tmp/.X11-unix ]]; then
    args+=(--env "DISPLAY=$DISPLAY" --volume /tmp/.X11-unix:/tmp/.X11-unix:ro)
fi
if [[ -n ${XAUTHORITY:-} && -f $XAUTHORITY ]]; then
    args+=(--volume "$XAUTHORITY:/tmp/thesis.xauthority:ro" --env XAUTHORITY=/tmp/thesis.xauthority)
fi
exec podman "${args[@]}" "$OSIC_IMAGE" /workspace/scripts/container-entry.sh "$@"
