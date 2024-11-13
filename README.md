# Isolate GPU

Run commands or a shell, with only given GPU devices visible.

`isolate-gpu` is a script that is useful when you have more than one
GPU in your machine, and you want to restrict the access of
applications to a subset of GPUs, aka isolating GPUs.

The ROCm documentation teaches you how to do that with Docker,
[here](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/how-to/docker.html#docker-restrict-gpus).

However, that leaves open the question of what OS to run within the
container?

`isolate-gpu` answers that question with "none".  It uses a thin
Docker container under the hood that exposes the host filesystem and
OS inside the container, and restricts the available GPUs within the
spawned shell environment to the ones you specify.

The container image is practically empty; it is mostly a wrapper
around the host's filesystem.  I.e., there is no separate distribution
inside the container.  The idea is to be able to work inside the
container mostly as if you were outside.

The non-user-data OS directories are mounted readonly within the
container.  That is, `/usr/`, `/etc`, `/var/`, etc.  This is to avoid
the possibility of the container corrupting the host.  `/home`,
`/net`, and `/mnt`, are mounted read-write.

## Features

- Transparent usage:
  - Commands in the container are run with the same user/group id as
    the user running the container, so that any created files have the
    expected ownership, and the build commands can access source files
    as expected.
  - Container is super thin, it's actually empty other than the entry
    pointer script.  The container runs the host OS, mounted read-only.
  - The container's workdir is the calling user's current directory.
- The hostname inside the container is tweaked to
  "$HOSTNAME-isolate-gpu(-$GPU)*", to make it easy to tell when inside
  the container in shell prompts.
- Can be run without arguments, which launches a shell ready for
  invoking commands (e.g., make) interactively, or,
- Can be run with arguments, which are passed as commands to the
  non-interative shell inside the container.

## Installation

To install the `isolate-gpu` script, simply copy or symlink it to some
directory found in your `$PATH`.  E.g., you can download it directly
from github, like so:

```bash
$ cd ~/bin
$ wget https://raw.githubusercontent.com/palves/isolate-gpu/refs/heads/main/isolate-gpu
$ chmod u+x isolate-gpu
```

When you run `isolate-gpu` for the first time, it downloads the Docker
image from Docker Hub automatically, you don't need to build it
yourself.

## Usage

```bash
$ isolate-gpu [opts...] [command] [args...]
```

If a command is not specified, then `isolate-gpu` spawns an
interactive shell within the isolated environment.  Exiting the shell
exits the container.

If a command is specified, then `isolate-gpu` executes the command
inside the container, and exits the container when the command exits.

See `isolate-gpu --help` for more details.

## Examples

1. Run an interactive shell inside the container, exposing GPU 1,
   preserving current directory:

```bash
$ isolate-gpu --device 1
```

2. Invoke make with the *Makefile* found in the current directory:

```bash
$ isolate-gpu --device 1 make
```

## Rebuilding the image

This isn't normally needed, because the image is available on [docker
hub](https://hub.docker.com/r/palves79/isolate-gpu), but if you want
to, you can rebuild it with:

```bash
git clone https://github.com/palves/isolate-gpu.git
cd isolate-gpu
./build-docker
```
