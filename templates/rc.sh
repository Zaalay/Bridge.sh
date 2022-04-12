# Part of Bridge.sh, MIT-licensed
# Copyright (c) 2022 Zaalay Studio, Muhammad Rivan

BRIDGESH_DIR="${HOME}/.Bridge.sh"
BRIDGESH_USRBINDIR="${BRIDGESH_DIR}/binaries"

. "${BRIDGESH_DIR}/modules/core.sh"
. "${BRIDGESH_DIR}/modules/${BRIDGESH_OS}.sh"

export PATH="${PATH}:${BRIDGESH_USRBINDIR}"