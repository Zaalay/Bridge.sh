# Part of Bridge.sh, MIT-licensed
# Copyright (c) 2022 Zaalay Studio, Muhammad Rivan

BRIDGESH_OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
[[ BRIDGESH_OS == *bsd ]] && BRIDGESH_OS="bsd"
BRIDGESH_BINDIR="$(dirname "$(type -P dirname)")"
BRIDGESH_DIR="$(dirname "${0}")/bridge_modules"

source "${BRIDGESH_DIR}/bridgesh/core.sh"
source "${BRIDGESH_DIR}/bridgesh/${BRIDGESH_OS}.sh"
