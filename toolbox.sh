#!/bin/bash
#
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Alejandro Visiedo <alejandro.visiedo@gmail.com>
#
# Create and enter into the toolbox with all the necessary
# tools for the learning.

set -e

# NOTE If using direnv TOOLBOX could be defined on it
# shellcheck disable=SC2269
TOOLBOX="${TOOLBOX}"
# shellcheck disable=SC2269
TOOLBOX_PROFILE="${TOOLBOX_PROFILE}"
TOOLBOX_PROFILE_PATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

LOG_DEBUG=0
LOG_TRACE=1
LOG_WARNING=2
LOG_INFO=3
LOG_ERROR=4
LOG_FATAL=5

LOG_DEFAULT="${LOG_INFO}"
LOG_DEFAULT="${LOG_DEBUG}"
LOG_LEVEL=${LOG_LEVEL:-${LOG_DEFAULT}}

log_set_level() {
  local level="$1"
  case "${level}" in
    "$LOG_DEBUG" | "$LOG_TRACE" | "$LOG_WARNING" | "$LOG_INFO" | "$LOG_ERROR" | "$LOG_FATAL" )
      LOG_LEVEL="${level}"
      ;;
    * )
      log_fatal "log_set_level: log level should be between $LOG_DEBUG..$LOG_FATAL"
      ;;
  esac
}

log_print_level() {
  printf "%s" "${LOG_LEVEL}"
}

log_msg() {
  local level="$1"
  shift 1
  case "${level}" in
    "$LOG_DEBUG" )
      log_debug "$*"
      ;;
    "$LOG_TRACE" )
      log_trace "$*"
      ;;
    "$LOG_WARNING" )
      log_warning "$*"
      ;;
    "$LOG_INFO" )
      log_info "$*"
      ;;
    "$LOG_ERROR" )
      log_error "$*"
      ;;
    "$LOG_FATAL" )
      log_fatal "$*"
      ;;
    * )
      log_fatal "log_msg: log level should be between $LOG_DEBUG..$LOG_FATAL"
      ;;
  esac
}

log_debug() {
  printf "debug: %s\n" "$*" >&2
}

log_trace() {
  printf "trace: %s\n" "$*" >&2
}

log_warning() {
  printf "warning: %s\n" "$*" >&2
}

log_info() {
  printf "info: %s\n" "$*" >&2
}

log_error() {
  printf "error: %s\n" "$*" >&2
}

log_fatal() {
  printf "fatal: %s\n" "$*" >&2
  exit 1
}

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

toolbox-create() {
  check_toolbox_is_not_empty
  # In Fedora 41 is observed by default create a Fedora 40 container
  # Using os-release evoke creating the same release as the current host
  # shellcheck disable=SC1091
  source /etc/os-release
  toolbox create -r "$VERSION_ID" "${TOOLBOX}" || {
    log_fatal "maybe the toolbox already exists: try 'toolbox list' or './toolbox.sh enter'\n"
  }
  toolbox-prepare "${TOOLBOX}"
}

toolbox-enter() {
  check_toolbox_is_not_empty
  log_info "Entering to '${TOOLBOX}' toolbox"
  toolbox enter "${TOOLBOX}" || {
    log_fatal "ret=$? it seems the toolbox '${TOOLBOX}' does not exist: try toolbox list or './toolbox.sh create'"
  }
}

toolbox-rm() {
  check_toolbox_is_not_empty
  podman kill "${TOOLBOX}" || true
  toolbox rm "${TOOLBOX}" || {
    log_fatal "it seems the '${TOOLBOX}' does not exist: try toolbox list"
  }
}

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

toolbox-localcfg() {
  local profile="$1"
  if [ -e "toolbox.sh" ]; then
    log_fatal "already exists a 'toolbox.sh' file: exiting with no file creation"
  fi
  if [ "${profile}" == "" ]; then
    cat > "toolbox.sh" <<EOFCFG
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

toolbox-install() {
  local install_dir
  if [ -e ~/bin ]; then
    install_dir=~/bin
  elif [ -e ~/.local/bin ]; then
    install_dir=~/.local/bin
  else
    log_fatal "$HOME/bin nor $HOME/.local/bin not found"
  fi
  cat > ${install_dir}/toolbox.sh <<EOF
#!/bin/bash
exec ${TOOLBOX_PROFILE_PATH}/toolbox.sh "\$@"
EOF
  chmod u+x ${install_dir}/toolbox.sh
  log_info "toolbox.sh wrapper installed at ${install_dir}"
  return 0
}

toolbox-help() {
  cat <<EOF
toolbox.sh is a helper script which wrap 'toolbox' to prepare a specific
toolbox for your needs.

Usage: ./toolbox.sh { create | enter | help }
  help     Display this content to provide guidelines about leverage this
           script.
  install  Install wrapper at ~/bin or ~/.local/bin to call this script.
  profiles Enumerate all the profiles available.
  create   Create the toolbox '$TOOLBOX' and install the required
           dependencies on it.
  prepare  It require the '$TOOLBOX' already exists. This re-run the
           preparation process.
  enter    Enter into the toolbox '$TOOLBOX' so that you can start your
           experience in a ready environment.
  rm       Delete the existing '$TOOLBOX' toolbox.
  localcfg Create a quick local profile 'toolbox.sh' to start to customize it.

EOF
}

main() {
  local subcommand="$1"
  case "$subcommand" in
    "create" | "enter" | "help" | "rm" | "prepare" | "profiles" | "localcfg" | "install" )
      shift 1
      "toolbox-$subcommand" "$@"
      ;;
    "" )
      toolbox-help
      ;;
    * )
      log_fatal "unexpected '$1' subcommand: try './toolbox.sh help'"
      ;;
  esac
}

if [ "${BASH_SOURCE[0]}" == "$0" ]; then
    main "$@"
fi

