# Nesting Containers with Podman

## Running `podman` as `root`

Run

```shell
just run "original" "root"
```

to see that we can build `Containerfile` (`podman` engine) then execute the
built container and inside call `./run.sh` again which recursively nests
containers. You can also use the `alpine` image with:

```shell
just run "custom" "root"
```

To start a bash after entering and after leaving the containers use:

```shell
just run "custom" "root" "true"
```

Its just too cool that this works? 🤣

## Running as Non-Root

So far this test does not work because some files get mounted wrongly after the first level
even if `userns=keep-id` works on the first level it does not when going deeper (?).

```shell
just run "custom" "podman"
```
