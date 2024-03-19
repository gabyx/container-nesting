set positional-arguments
set shell := ["bash", "-cue"]
root_dir := justfile_directory()

podman *args:
    cd "{{root_dir}}/podman" && just run {{args}}
