#!/bin/bash
#
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Alejandro Visiedo <alejandro.visiedo@gmail.com>
#
# @filename toolbox_helpers.sh
# @brief provide helpers function that are made available after include
# the file `toolbox.common.sh`.

# @description help to install vscode into the toolbox
# This is intended to be invoked from your toolbox.sh custom file or
# when creating a new profile.
# see: https://code.visualstudio.com/docs/setup/linux#_rhel-fedora-and-centos-based-distributions
toolbox_helper_install_vscode() {
	toolbox enter "${TOOLBOX}" <<EOF
# Add vscode repository
curl -L -s -o /tmp/microsoft.asc "https://packages.microsoft.com/keys/microsoft.asc"
sudo rpm --import /tmp/microsoft.asc
rm /tmp/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

# Install vscode
sudo dnf install -y code
EOF
}

# @description helper to install terraform in the toolbox.
# see: https://developer.hashicorp.com/terraform/install
toolbox_helper_install_terraform() {
	toolbox enter "${TOOLBOX}" <<EOF
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager addrepo --from-repofile="https://rpm.releases.hashicorp.com/fedora/hashicorp.repo"
sudo dnf -y install terraform
EOF
}

# @description help to install python dependencies into the toolbox.
# This is intended to be invoked from your toolbox.sh custom file or when
# creating a new profile. It only install the dependencies in a .venv virtual
# environment if the files requirements.txt or requirements-dev.txt files
# exist.
toolbox_helper_pip_install() {
	if [ -e "requirements.txt" ]; then
		# shellcheck disable=SC2154
		toolbox enter "${TOOLBOX}" <<EOF
[ -e .venv ] || python3 -m venv .venv
source .venv/bin/activate
if [ "${proxy}" != "" ]; then
	export http_proxy="${proxy}"
	export HTTPS_PROXY="${proxy}"
fi
pip install -U pip
pip install -r requirements.txt
[ ! -e requirements-dev.txt ] || {
  pip install -r requirements-dev.txt
}
exit
EOF
	fi
}

# @description help to install python dependencies by using poetry.
# It only installs the dependencies if a pyproject.toml file exists.
# see: https://python-poetry.org/
toolbox_helper_poetry_install() {
	if [ -e "pyproject.toml" ]; then
		# shellcheck disable=SC2154
		toolbox enter "${TOOLBOX}" <<EOF
if [ "${proxy}" != "" ]; then
	export http_proxy="${proxy}"
	export HTTPS_PROXY="${proxy}"
fi
poetry install --no-root
EOF
	fi
}
