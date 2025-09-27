# Nesting Containers with Podman

The following expects that the container runtime `podman` is run as non-root
user on your system.

## What are Rootless Containers

[See here.](https://rootlesscontaine.rs/#what-are-rootless-containers-and-what-are-not)

> When we say Rootless Containers, it means running the entire container runtime
> as well as the containers without the root privileges.

## Running Nested Containers as `root`

Note: This is not considered **Rootless Containers**.

Run

```shell
just run "original" "root"
```

to see that we can build `Containerfile` (`podman` engine) then run the built
container as **root** user with `podman` (as current **non-root** user) and
inside call `./run.sh` again which recursively nests containers. You can also
use the `alpine` image with:

```shell
just run "custom" "root"
```

To start a bash after entering and after leaving the containers use:

```shell
just run "custom" "root" "true"
```

Its just too cool that this works? 🤣

> [!NOTE
>
> - When running the containers with `root` there is no need to set
>   `mount_program` to `fuse-overlayfs` and one can just use the kernels
>   `overlayfs` and it works. Test it with the
>   `just run custom-pipglr root true`. This directly changes when running as
>   `non-root` and overlay-in-overlay is not possible anymore without using
>   `fuse-overlayfs` (to my best knowledge). I could however not get it to
>   [work](https://github.com/containers/podman/discussions/22049#discussioncomment-8868211).

## Running Nested Containers as Non-`root`

Note: This is considered **Rootless Containers**.

> [!NOTE
>
> You need also to mount the `--device /dev/fuse:rw` device cause Podman uses
> `fuse-overlayfs` in rootless mode to provide layered container filesystems
> without kernel support.
>
> That requires the `/dev/fuse`.
>
> So, the `--device /dev/fuse:rw` ensures your inner Podman can mount images
> properly. On `docker` when using `--privileged` it adds all host devices.

So far this test does not work because some files get mounted wrongly after the
first level even if `userns=keep-id` works on the first level it does not when
going deeper (?).

```shell
just run "custom" "podman"
```

to see that we can build `Containerfile` (`podman` engine) then run the built
container as **non-root user** with `podman` (as current **non-root** user) and

### Inspect the Podman Storage Configuration

```shell
just run "custom" "podman" "true"
```

and in the first shell

```shell
podman info
```

- Should show that the its using `fuse-overlayfs` when running as non-root.

### Running Rootless Podman Service & Using it in Another Container

```shell
just run "custom" "podman" true
```

then in the first container we start **the service**:

```shell
podman system service --time=0 unix:///podman-root/podman.sock --log-level debug
```

then on the host (where you ran `just run "custom" "podman" true`) you start a
new container in the terminal:

```shell
podman run -it --rm -v podman-root:/run/podman ttl.sh/podman-test \
  podman --url unix:///run/podman/podman.sock info

# or run a container directly.

podman run -it --rm -v podman-root:/run/podman ttl.sh/podman-test \
  podman --url unix:///run/podman/podman.sock run -it alpine
```
