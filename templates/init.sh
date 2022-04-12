# Part of Bridge.sh, MIT-licensed
# Copyright (c) 2022 Zaalay Studio, Muhammad Rivan

BRIDGESH_OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
[[ BRIDGESH_OS == *bsd ]] && BRIDGESH_OS="bsd"

if [[ BRIDGESH_SHELL == "bash" ]]; then
  BRIDGESH_DIR="$(dirname "${0}")/bridge_modules"
  BRIDGESH_BINDIR="$(dirname "$(type -P dirname)")"
else
  BRIDGESH_DIR="${0:a:h}"
  BRIDGESH_BINDIR="$(dirname "$(command -v dirname)")"
fi

source "${BRIDGESH_DIR}/bridgesh/core.sh"
source "${BRIDGESH_DIR}/bridgesh/${BRIDGESH_OS}.sh"
