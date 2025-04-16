#!/bin/bash
#
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Alejandro Visiedo <alejandro.visiedo@gmail.com>
#
# Prepare shell profile

pkgs+=(make shellcheck)
source "${TOOLBOX_PROFILE_PATH}/toolbox.common.sh"

if [ -e "requirements.txt" ]; then
  toolbox enter "${TOOLBOX}" <<EOF
[ -e .venv ] || python3 -m venv .venv
source .venv/bin/activate
export http_proxy="${proxy}"
export HTTPS_PROXY="${proxy}"
pip install -U pip
pip install -r requirements.txt
[ ! -e requirements-dev.txt ] || {
  pip install -r requirements-dev.txt
}
exit
EOF
fi

# Additional steps
toolbox enter "${TOOLBOX}" <<EOF
sudo dnf install -y neovim --exclude=nodejs
exit
EOF

