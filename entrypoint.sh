#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later
# Author  : Pedro Alves (pedro@palves.net)

if [ $# -gt 0 ]; then
    exec sh -c "cd $ISOLATE_GPU_CWD && \
		unset ISOLATE_GPU_CWD && \
		$*"
else
    exec sh -c "cd $ISOLATE_GPU_CWD && \
		unset ISOLATE_GPU_CWD && \
		$SHELL --login"
fi
