#!/bin/bash
#
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Alejandro Visiedo <alejandro.visiedo@gmail.com>
#
# Create and enter into the toolbox with all the necessary
# tools for the learning.

# @file toolbox.sh
# @brief toolbox helper script to automate toolbox creation/preparation.

set -e
SHELL_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
# shellcheck disable=SC1091
source "${SHELL_DIR}/lib/log.lib.sh"

# NOTE If using direnv TOOLBOX could be defined on it
# shellcheck disable=SC2269
TOOLBOX="${TOOLBOX}"
# shellcheck disable=SC2269
TOOLBOX_PROFILE="${TOOLBOX_PROFILE}"
TOOLBOX_PROFILE_PATH="${SHELL_DIR}"

is_the_default_script() {
	[ "${TOOLBOX_PROFILE_PATH}/toolbox.sh" == "$PWD/toolbox.sh" ]
}

check_toolbox_is_not_empty() {
	[ "${TOOLBOX}" != "" ] || {
		log_fatal "TOOLBOX is an empty string: try 'direnv allow' if using direnv in your directory"
	}
}

check_toolbox_profile_is_not_empty() {
	[ "${TOOLBOX_PROFILE}" != "" ] || {
		log_fatal "TOOLBOX_PROFILE is empty or not specified"
	}
}

# @brief prepare an already created toolbox.
toolbox-prepare() {
	check_toolbox_is_not_empty
	local pkgs=()
	local proxy=""
	# shellcheck disable=SC2154
	if [ "${http_proxy}" != "" ] || [ "${HTTPS_PROXY}" != "" ]; then
		proxy="${proxy:-${HTTPS_PROXY}}"
		proxy="${proxy:-${http_proxy}}"
	fi

	# shellcheck source=toolbox.common.sh
	if [ -e "./toolbox.sh" ] && ! is_the_default_script; then
		log_info "TOOLBOX_PROFILE override by local 'toolbox.sh' file"
		source "./toolbox.sh"
	else
		check_toolbox_profile_is_not_empty
		local toolbox_include_path="${TOOLBOX_PROFILE_PATH}/toolbox.${TOOLBOX_PROFILE}.sh"
		[ -e "${toolbox_include_path}" ] || {
			log_fatal "it does not exist '${toolbox_include_path}' file to match TOOLBOX_PROFILE='${TOOLBOX_PROFILE}'"
		}
		source "${toolbox_include_path}"
	fi
}

# @brief create the toolbox container and call prepare to
# automate the tools installation.
# It uses TOOLBOX env var to match which toolbox to use.
toolbox-create() {
	check_toolbox_is_not_empty
	# In Fedora 41 is observed by default create a Fedora 40 container
	# Using os-release evoke creating the same release as the current host
	# shellcheck disable=SC1091
	source /etc/os-release
    TOOLBOX_RELEASE="${TOOLBOX_RELEASE:-${VERSION_ID}}"
	echo toolbox create --release "${TOOLBOX_RELEASE}" "${TOOLBOX}"
	toolbox create --release "${TOOLBOX_RELEASE}" "${TOOLBOX}" || {
		log_fatal "maybe the toolbox already exists: try 'toolbox list' or './toolbox.sh enter'\n"
	}
	toolbox-prepare "${TOOLBOX}"
}

# @brief Enter into the toolbox.
# It uses the TOOLBOX environment variable; if you are using
# direnv, you can define this environment variable on .envrc
# file.
toolbox-enter() {
	check_toolbox_is_not_empty
	log_info "Entering to '${TOOLBOX}' toolbox"
	exec toolbox enter "${TOOLBOX}"
}

# @brief Remove the toolbox.
# It uses the TOOLBOX environment variable to figure out
# which toolbox container to remove.
toolbox-rm() {
	check_toolbox_is_not_empty
	podman kill "${TOOLBOX}" || true
	exec toolbox rm "${TOOLBOX}"
}

# @brief List the profiles available, which can be
# used with localcfg or directly with create and prepare
# to use a predefined profile.
toolbox-profiles() {
	local item
	printf "List of available profiles:\n"
	for item in "${TOOLBOX_PROFILE_PATH}"/toolbox.*.sh; do
		item="${item%%.sh}"
		item="${item##*/toolbox.}"
		printf "  %s\n" "${item}"
	done
	if [ -e "toolbox.sh" ]; then
		printf "Exists a local profile 'toolbox.sh' file in the current directory\n"
		printf "This file override any TOOLBOX_PROFILE value\n"
	fi
}

# @brief Generate a toolbox.sh file based on the profile
# indicated by TOOLBOX_PROFILE environment variable.
toolbox-localcfg() {
	local profile="$1"
	if [ -e "toolbox.sh" ]; then
		log_fatal "already exists a 'toolbox.sh' file: exiting with no file creation"
	fi
	if [ "${profile}" == "" ]; then
		cat >"toolbox.sh" <<EOFCFG
#!/bin/bash

# TODO Add your required rpm packages here
pkgs+=()
source "\${TOOLBOX_PROFILE_PATH}/toolbox.common.sh"

toolbox enter "\${TOOLBOX}" <<EOF
# TODO Add any additional customization for your toolbox here.
#      Remember to escape the '\$' symbol depending
#      on your expected result.
exit
EOF
EOFCFG
	else
		local src_profile="${TOOLBOX_PROFILE_PATH}/toolbox.${profile}.sh"
		[ -e "${src_profile}" ] || {
			log_fatal "profile '${profile}' does not exist: try toolbox.sh list, or toolbox.sh localcfg"
		}
		cp -vf "${TOOLBOX_PROFILE_PATH}/toolbox.${profile}.sh" "toolbox.sh"
	fi
}

# @brief Install wrapper to call the helper script into your
# local bin path.
toolbox-install() {
	local install_dir
	if [ -e ~/bin ]; then
		install_dir=~/bin
	elif [ -e ~/.local/bin ]; then
		install_dir=~/.local/bin
	else
		log_fatal "$HOME/bin nor $HOME/.local/bin not found"
	fi
	cat >${install_dir}/toolbox.sh <<EOF
#!/bin/bash
exec ${TOOLBOX_PROFILE_PATH}/toolbox.sh "\$@"
EOF
	chmod u+x ${install_dir}/toolbox.sh
	log_info "toolbox.sh wrapper installed at ${install_dir}"
	return 0
}

# @brief Print out the commands that you can use with the
# toolbox.sh helper script.
toolbox-help() {
	cat <<EOF
toolbox.sh is a helper script which wrap 'toolbox' to prepare a specific
toolbox for your needs.

Usage: ./toolbox.sh { help | install | profiles | create | prepare | enter | rm | localcfg }
  help     Display this content to provide guidelines about leverage this
           script.
  install  Install wrapper at ~/bin or ~/.local/bin to call this script.
  profiles Enumerate all the profiles available.
  create   Create the toolbox '\$TOOLBOX' and install the required
           dependencies on it.
  prepare  It require the '\$TOOLBOX' already exists. This re-run the
           preparation process.
  enter    Enter into the toolbox '\$TOOLBOX' so that you can start your
           experience in a ready environment.
  rm       Delete the existing '\$TOOLBOX' toolbox.
  localcfg Create a quick local profile 'toolbox.sh' to start to customize it.

EOF
}

main() {
	local subcommand="$1"
	case "$subcommand" in
	"create" | "enter" | "help" | "rm" | "prepare" | "profiles" | "localcfg" | "install")
		shift 1
		"toolbox-$subcommand" "$@"
		;;
	"")
		toolbox-help
		;;
	*)
		log_fatal "unexpected '$1' subcommand: try './toolbox.sh help'"
		;;
	esac
}

if [ "${BASH_SOURCE[0]}" == "$0" ]; then
	main "$@"
fi
