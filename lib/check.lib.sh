#!/bin/bash
#
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Alejandro Visiedo <alejandro.visiedo@gmail.com>
#
# @file check.lib.sh
# @description provides primitives to validate string arguments.

# @description check the argument is a string that represent a number.
# @arg $1 a string using
# @return 0 on success
# @return 1 on failure
is_number() {
	[[ "$1" =~ ^(-?[0-9]+)(\.[0-9]+)?$ ]]
}

# @description check the argument is a string that represent a aplha
# characters.
# @arg $1 a string using
# @return 0 on success
# @return 1 on failure
is_alpha() {
	[[ "$1" =~ ^[a-zA-Z]*$ ]]
}

# @description check the argument is a string that represent an
# alphanumeric sequence.
# @arg $1 a string using
# @return 0 on success
# @return 1 on failure
is_alphanum() {
	[[ "$1" =~ ^[a-zA-Z0-9\.\-]*$ ]]
}

# @description check the argument is a string that represent
# a sequence of white spaces (<space>, <tab>, <newline>).
# @arg $1 a string using
# @return 0 on success
# @return 1 on failure
is_whitespace() {
	[[ "$1" =~ ^[\ \\\t\\\n]*$ ]]
}

# @description check the argument is a sequence of chars
# that represent a full qualified domain name,
# for instance `alpha.example.com`
# @arg $1 a string using
# @return 0 on success
# @return 1 on failure
is_fqdn() {
	[[ "$1" =~ ^([a-z][a-z0-9\-]*\.){2,}([a-z][a-z0-9\-]*)$ ]]
}

# @description check the argument is a sequence of chars
# that represent a domain name.
# for instance `example.com`
# @arg $1 a string using
# @return 0 on success
# @return 1 on failure
is_domain() {
	[[ "$1" =~ ^([a-z][a-z0-9\-]*\.)+([a-z][a-z0-9\-]*)$ ]]
}
