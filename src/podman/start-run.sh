#!/usr/bin/env bash
# shellcheck disable=SC2015

set -eu

DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
. "$DIR/container/general.sh"

cd "$DIR" || exit 1

name="ttl.sh/podman-test"
target="$1"
user="$2"
with_tty="$3"

podman build \
    -f container/Containerfile \
    -t "$name" \
    --target "$target" \
    ./container

podman push "$name"

log::info "Run as user: $user"
rootless_args=()
if [ "$user" != "root" ]; then
    rootless_args=(
        "--userns=keep-id:uid=1000,gid=1000"
        "--device" "/dev/fuse:rw"
    )
fi

log::info "Creating 'podman-root' volume"
podman volume rm podman-root &&
    podman volume create podman-root || true

log::info " ==========================================================="
log::info " ==========================================================="
log::info " ==================== Start Recursion ======================"
log::info " ==========================================================="
log::info " ==========================================================="

podman run \
    --privileged \
    "${rootless_args[@]}" \
    -v "podman-root:/podman-root" \
    --rm \
    -it \
    "$name" \
    ./run.sh 1 "$user" "$with_tty"

# -v "$HOME/.local/share/containers/storage:/var/lib/shared" \
