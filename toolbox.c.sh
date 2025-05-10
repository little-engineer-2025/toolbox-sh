#!/bin/bash
#
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Alejandro Visiedo <alejandro.visiedo@gmail.com>
#
# Prepare c profile

pkgs+=(make clang libtool cmake clang-tools-extra)
source "${TOOLBOX_PROFILE_PATH}/toolbox.common.sh"

# Sometimes python tools are used in the repository
if [ -e "requirements.txt" ] || [ -e "requirements-dev.txt" ]; then
	source "${TOOLBOX_PROFILE_PATH}/toolbox.python.sh"
fi

if [ -e "tools/go.mod" ]; then
	printf "error: todo: add local tool installation process\n" >&3
	exit 1
	# shellcheck disable=SC2317
	toolbox enter "${TOOLBOX}" <<EOF
EOF
fi
