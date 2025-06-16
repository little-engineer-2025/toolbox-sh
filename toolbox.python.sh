#!/bin/bash
#
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Alejandro Visiedo <alejandro.visiedo@gmail.com>
#
# Prepare python profile

pkgs+=(python3 poetry python3-spdx-tools)
source "${TOOLBOX_PROFILE_PATH}/toolbox.common.sh"

toolbox_helper_install_vscode
toolbox_helper_install_pip_requirements
toolbox_helper_install_poetry_deps
