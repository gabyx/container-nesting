#!/usr/bin/env bash
# shellcheck disable=SC2015

set -eu

DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
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

echo "Run as user: $user"
ns_args=()
[ "$user" = "root" ] || ns_args=("--userns=keep-id:uid=1000,gid=1000")

podman volume rm podman-root &&
    podman volume create podman-root || true

echo " ==========================================================="
echo " ==========================================================="
echo " ==================== Start Recursion ======================"
echo " ==========================================================="
echo " ==========================================================="

podman run \
    --privileged \
    "${ns_args[@]}" \
    --device /dev/fuse \
    -v "podman-root:/podman-root" \
    -v "$HOME/.local/share/containers/storage:/var/lib/shared" \
    --rm \
    -it \
    "$name" \
    ./run.sh 1 "$user" "$with_tty"
