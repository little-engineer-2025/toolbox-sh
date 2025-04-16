#!/bin/bash

# Helper to install vscode
# https://code.visualstudio.com/docs/setup/linux#_rhel-fedora-and-centos-based-distributions
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

toolbox_helper_pip_install() {
  if [ -e "requirements.txt" ]; then
    # shellcheck disable=SC2154
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
}
