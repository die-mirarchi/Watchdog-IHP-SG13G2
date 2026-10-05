#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
if [[ -d /foss/pdks ]]; then
    echo 'Ejecutar setup.sh desde Ubuntu/WSL, fuera del contenedor de herramientas.' >&2
    exit 1
fi
[[ $(id -u) != 0 ]] || { echo 'Usar un usuario normal, sin sudo.' >&2; exit 1; }
[[ $(uname -m) == x86_64 ]] || { echo 'Esta versión fija requiere Linux x86_64.' >&2; exit 1; }
if ! command -v podman >/dev/null; then
    command -v apt-get >/dev/null || { echo 'Instalar Podman con el gestor de paquetes de tu distribución.' >&2; exit 1; }
    sudo apt-get update
    sudo apt-get install -y podman uidmap slirp4netns fuse-overlayfs
fi
source tools-config/toolchain.lock
if ! podman image exists "$OSIC_IMAGE"; then
    podman pull "$OSIC_IMAGE"
fi
bash scripts/eda.sh check
echo 'Instalación lista. Abrir con: bash scripts/eda.sh xschem / klayout / shell'
