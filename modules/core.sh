# Part of Bridge.sh, MIT-licensed
# Copyright (c) 2022 Zaalay Studio, Muhammad Rivan

BRIDGESH_SCRIPTNAME="$(basename ${0})"
BRIDGESH_USRBINDIR="${BRIDGESH_DIR}/binaries"
BRIDGESH_USROSBINDIR="${BRIDGESH_DIR}/${BRIDGESH_OS}_binaries"

export PATH="${PATH}:${BRIDGESH_USRBINDIR}:${BRIDGESH_USROSBINDIR}"
