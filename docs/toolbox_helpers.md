# # @filename toolbox_helpers.sh

provide helpers function that are made available after include

## Overview

help to install vscode into the toolbox
This is intended to be invoked from your toolbox.sh custom file or
when creating a new profile.
see: https://code.visualstudio.com/docs/setup/linux#_rhel-fedora-and-centos-based-distributions

## Index

* [toolbox_helper_install_vscode](#toolboxhelperinstallvscode)
* [toolbox_helper_install_terraform](#toolboxhelperinstallterraform)
* [toolbox_helper_pip_install](#toolboxhelperpipinstall)
* [toolbox_helper_poetry_install](#toolboxhelperpoetryinstall)

### toolbox_helper_install_vscode

help to install vscode into the toolbox
This is intended to be invoked from your toolbox.sh custom file or
when creating a new profile.
see: https://code.visualstudio.com/docs/setup/linux#_rhel-fedora-and-centos-based-distributions

### toolbox_helper_install_terraform

helper to install terraform in the toolbox.
see: https://developer.hashicorp.com/terraform/install

### toolbox_helper_pip_install

help to install python dependencies into the toolbox.
This is intended to be invoked from your toolbox.sh custom file or when
creating a new profile. It only install the dependencies in a .venv virtual
environment if the files requirements.txt or requirements-dev.txt files
exist.

### toolbox_helper_poetry_install

help to install python dependencies by using poetry.
It only installs the dependencies if a pyproject.toml file exists.
see: https://python-poetry.org/

