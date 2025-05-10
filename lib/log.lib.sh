#!/bin/bash
#
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Alejandro Visiedo <alejandro.visiedo@gmail.com>
#
# Requires: check.lib.sh
#
# See: https://github.com/reconquest/shdoc
#
# @file log.lib.sh
# @brief provide log message primitives.
# @example
#   source "lib/log.lib.sh"
#   log_set_level $LOG_TRACE
#   log_trace "my-program trace"
#   log_info "my-program starts"
#   log_fatal "my-program forced to exit with error"
#
# The available levels are in the variables:
#   - LOG_DEBUG
#   - LOG_TRACE
#   - LOG_INFO
#   - LOG_WARNING
#   - LOG_ERROR
#   - LOG_FATAL

LOG_DEBUG=1
LOG_TRACE=2
LOG_INFO=3
LOG_WARNING=4
LOG_ERROR=5
LOG_FATAL=6

LOG_DEFAULT="${LOG_INFO}"
LOG_CURRENT="${LOG_DEFAULT}"

# @description Print a debug message on standard error. The message
# is printed out only if the minimum LOG_DEBUG level is active.
# @arg $1 are passed as part of the message to print out.
log_debug() {
	[ ! $LOG_DEBUG -ge $LOG_CURRENT ] || printf "debug: %s\n" "$*" >&2
}

# @description Print a trace message on standard error. The message
# is printed out only if the minimum LOG_TRACE level is active.
# @arg $1 are passed as part of the message to print out.
log_trace() {
	[ ! $LOG_TRACE -ge $LOG_CURRENT ] || printf "trace: %s\n" "$*" >&2
}

# @description Print an informative message on standard error. The message
# is printed out only if the minimum LOG_INFO level is active.
# @arg $1 are passed as part of the message to print out.
log_info() {
	[ ! $LOG_INFO -ge $LOG_CURRENT ] || printf "info: %s\n" "$*" >&2
}

# @description Print a warning message on standard error. The message
# is printed out only if the minimum LOG_WARNING level is active.
# @arg $1 are passed as part of the message to print out.
log_warning() {
	[ ! $LOG_WARNING -ge $LOG_CURRENT ] || printf "warning: %s\n" "$*" >&2
}

# @description Print an error message on standard error. The message
# is printed out only if the minimum LOG_ERROR level is active.
# @arg $1 are passed as part of the message to print out.
log_error() {
	[ ! $LOG_ERROR -ge $LOG_CURRENT ] || printf "error: %s\n" "$*" >&2
}

# @description Print a fatal error message on standard error and terminate the script.
# The message is printed out only if the minimum LOG_FATAL level is active.
# @arg $1 are passed as part of the message to print out.
# @exitcode 1
log_fatal() {
	[ ! $LOG_FATAL -ge $LOG_CURRENT ] || printf "fatal: %s\n" "$*" >&2
	exit 1
}

# @description Set the log level. If some message does not have the
# minimum level, the message is printed out.
# @arg $1 is a number in [$LOG_DEBUG..$LOG_FATAL]
# @return 0 on success.
# @return 1 on wrong log level.
log_set_level() {
	local new_level="$1"
	is_number "${new_level}" || return 1
	if [ "${new_level}" -lt $LOG_DEBUG ]; then
		return 1
	elif [ "${new_level}" -gt $LOG_FATAL ]; then
		return 1
	fi
	LOG_CURRENT="${new_level}"
	return 0
}

# Retrieve the level of the log messages
#
log_level() {
	return $LOG_CURRENT
}
