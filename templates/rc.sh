# Part of Bridge.sh, MIT-licensed
# Copyright (c) 2022 Zaalay Studio, Muhammad Rivan
#
# STATIC VARIABLES WILL BE PATCHED BY INSTALLER
# CHECK ABOVE THE COPYRIGHT
#
# * BRIDGESH_BINDIR
# * BRIDGESH_OS

export BRIDGESH_SHELL="$(basename "${SHELL}")"
export BRIDGESH_DIR="${HOME}/.Bridge.sh"

. "${BRIDGESH_DIR}/modules/core.sh"
. "${BRIDGESH_DIR}/modules/${BRIDGESH_OS}.sh"

