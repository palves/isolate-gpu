# Isolate GPU

Run commands or a shell, with only given GPU devices visible.

This script uses a thin Docker container under the hood that exposes
the host filesystem and OS inside the container, and restricts the
available GPUs within the spawned shell environment to the ones you
specify.

This is useful when you have more than one GPU in your machine, and
you want to restrict the access of applications to a subset of GPUs,
aka isolating GPUs.

The ROCm documentation teaches you how to do that with Docker, see
here:

https://rocm.docs.amd.com/projects/install-on-linux/en/latest/how-to/docker.html#docker-restrict-gpus

However, that leaves open the question of what OS to run within the
container?

isolate-gpu answers that question with "none".  Its container image is
practically empty; it is mostly a wrapper around the host's
filesystem.  I.e., there is no separate distribution inside the
container.  The idea is to be able to work inside the container mostly
as if you were outside.

The non-user-data OS directories are mounted readonly within the
container.  That is, /usr/, /etc, /var/, etc.  This is to avoid the
possibility of the container corrupting the host.  /home, /net, and
/mnt, are mounted read-write.

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

## Building the image

```bash
git clone https://github.com/palves/isolate-gpu.git
cd isolate-gpu
./build-docker
```

## Installation

This image is not meant to be run directly.  Instead, there is a
**isolate-gpu** helper script you use to enter the container
environment and/or execute build commands on build directories that
exist on the local host filesystem.

To install the helper script, simply copy or symlink it to some
directory found in your \$PATH.  E.g.:

```bash
ln -s /path/to/isolate-gpu-git/isolate-gpu ~/bin/
```

## Examples

1. `isolate-gpu --device 1`: Run an interactive shell inside the
   container, exposing GPU 1, preserving current directory.

2. `isolate-gpu --device 1 make`: Invoke make with the *Makefile*
   found in the current directory.

## Usage

For example, here\'s how to run the ROCm-specific tests in GDB's
testsuite, on GPU 1:

```bash
cd /path/to/gdb/build/gdb/
isolate-gpu --device 1
# You're now inside the container, in the same directory as you were.
 make check -j32 RUNTESTFLAGS="gdb.rocm/*.exp"
```

Alternatively, you can invoke any command inside the container by
prepending the **isolate-gpu** script on the commandline.  Assuming
**isolate-gpu** can be found in your PATH, you can run:

```bash
$ isolate-gpu [opts...] [command] [args...]
```

For example:

```bash
$ isolate-gpu --device 1 make check -j32 RUNTESTFLAGS="gdb.rocm/*.exp"
```
