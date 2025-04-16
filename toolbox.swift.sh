#!/bin/bash
#
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Alejandro Visiedo <alejandro.visiedo@gmail.com>
#
# Prepare swift profile

pkgs+=(swift-lang)
source "${TOOLBOX_PROFILE_PATH}/toolbox.common.sh"

# Sometimes python tools are used in the repository
if [ -e "requirements.txt" ] || [ -e "requirements-dev.txt" ]; then
  source "${TOOLBOX_PROFILE_PATH}/toolbox.python.sh"
fi

