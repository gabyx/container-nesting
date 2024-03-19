#!/usr/bin/env bash
#
set -u
set -e

DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$DIR" || exit 1

function indent() {
    cat | sed "s@^@| @g"
}

function run_podman() {
    # When you specify `--root` , than `storage-opts`
    # in `/etc/containers/storage.conf` are ignored.
    podman \
        --root /podman-root/root \
        --runroot /podman-root/runroot \
        --storage-opt "additionalimagestore=/var/lib/shared" \
        "$@"
}

function with_tty() {
    [ "$with_tty" = "true" ] || return 1
}

function main() {
    # Build the image.
    echo "$msg: inside [version: $(cat /image.version)]"
    if with_tty; then
        echo "Bash when entering container:"
        bash
    fi

    # Run the image and build again.
    if [ "$level" -lt 5 ]; then
        echo "$msg: Launching a new container ..."

        # We need to make a new volume for the next podman
        # to have the stuff it needs separated.
        echo "$msg: create volume:"
        run_podman volume create "$vol_name" || {
            echo "create failed: $vol_name"
            exit 3
        }

        # We launch the new podman with root/runroot
        # on the current mounted volume `data`.
        # Then we mount the current data as
        # [`additionalimages`](https://www.redhat.com/sysadmin/image-stores-podman)
        # to next podman to have caching.

        echo "$msg: Simple container run test:"
        run_podman run \
            --privileged \
            "${tty_args[@]}" \
            "${ns_args[@]}" \
            ttl.sh/podman-test \
            head -1 /etc/os-release

        echo "$msg: Start new container:"

        echo
        run_podman \
            run \
            --privileged \
            "${tty_args[@]}" \
            "${ns_args[@]}" \
            -v "$vol_name:/podman-root:Z" \
            -v "/var/lib/shared:/var/lib/shared" \
            --rm ttl.sh/podman-test \
            ./run.sh "$((level + 1))" "$user" "$with_tty" || true

        echo

        if with_tty; then
            echo "Bash after container:"
            bash
        fi

    else
        echo "$msg: Finally reached container level: $level"
    fi

    echo "$msg: leaving"
}

level="$1"
user="${2:-root}"
with_tty="${3:-false}"

vol_name="podman-root-$level"
msg="-> $level. Container"

tty_args=()
if with_tty; then
    tty_args=(-it)
fi

ns_args=()
if [ "$user" != "root" ]; then
    ns_args=("--userns=keep-id")
fi

# Run the recursion.
if ! with_tty; then
    main 2>&1 | indent
else
    main
fi
