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

## Running Nested Containers as Non-`root`

Note: This is considered **Rootless Containers**.

So far this test does not work because some files get mounted wrongly after the
first level even if `userns=keep-id` works on the first level it does not when
going deeper (?).

```shell
just run "custom" "podman"
```

to see that we can build `Containerfile` (`podman` engine) then run the built
container as **non-root user** with `podman` (as current **non-root** user) and
