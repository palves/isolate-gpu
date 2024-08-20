# SPDX-License-Identifier: GPL-3.0-or-later
# Author  : Pedro Alves (pedro@palves.net)
#
# Dockerfile for isolate-gpu.  It is mostly empty, because we mount
# the host's OS in the container.  If the special "scratch" image was
# available in the Docker registry, we wouldn't even need to build any
# image.

FROM scratch

LABEL maintainer="Pedro Alves <pedro@palves.net>"

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
