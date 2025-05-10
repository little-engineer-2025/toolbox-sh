#!/bin/bash
#
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Alejandro Visiedo <alejandro.visiedo@gmail.com>
#
# shell include helper to prepare a toolbox
#
# Expectations:
#   TOOLBOX a non empty string with the name of the toolbox to prepare
#   pkgs    an array with the rpm required
#
# Setup common settings such as using https for the package sources
# and use a proxy if the host environment is using it.
#
# Check for the existence of some package dependencies in
# several languages to initially prepare the environment inside
# the toolbox.

# Check TOOLBOX is set
if [ -z "${TOOLBOX}" ]; then
	printf "error: TOOLBOX cannot be an empty string or unset\n" >&3
	exit 1
fi

source "${TOOLBOX_PROFILE_PATH}/toolbox_helpers.sh"

# Set common settings
# shellcheck disable=SC2154
toolbox enter "${TOOLBOX}" <<EOF
# Update repos to use https protocol
for item in /etc/yum.repos.d/*.repo; do
  sudo sed -i '/^metalink=/ { /&protocol=https$/! s/$/\&protocol=https/ }' "\${item}"
done

# Update repos to use host proxy configuration
[ "${proxy}" == "" ] || grep -q "^proxy=" /etc/dnf/dnf.conf || {
  echo "proxy=${proxy}" | sudo tee -a /etc/dnf/dnf.conf
}
exit
EOF

# Install rpm packages
pkgs+=(direnv pre-commit hadolint vim bat ripgrep silver)
if [ "${#pkgs[@]}" -gt 0 ]; then
	toolbox enter "${TOOLBOX}" <<EOF
# Install required packages
sudo dnf install -y ${pkgs[@]}
exit
EOF
fi
