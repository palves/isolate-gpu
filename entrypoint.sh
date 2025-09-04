#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later
# Author  : Pedro Alves (pedro@palves.net)

cd "$ISOLATE_GPU_CWD" || exit 1
unset ISOLATE_GPU_CWD

if [ $# -gt 0 ]; then
    exec "$@"
else
    exec $SHELL --login
fi
