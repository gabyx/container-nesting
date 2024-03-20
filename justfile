set positional-arguments
set shell := ["bash", "-cue"]
root_dir := justfile_directory()

run *args:
    cd "{{root_dir}}/src/podman" && just run {{args}}
