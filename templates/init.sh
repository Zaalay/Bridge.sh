# Part of Bridge.sh, MIT-licensed
# Copyright (c) 2022 Zaalay Studio, Muhammad Rivan

export BRIDGESH_SHELL="$(basename "${SHELL}")"
export BRIDGESH_OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
[[ "${BRIDGESH_OS}" == *bsd ]] && BRIDGESH_OS="bsd"

if [[ "${BRIDGESH_SHELL}" == "bash" ]]; then
  export BRIDGESH_DIR="$(dirname "${0}")/bridge_modules/bridgesh"
  export BRIDGESH_BINDIR="$(dirname "$(type -P dirname)")"
else
  export BRIDGESH_DIR="${0:a:h}/bridgesh"
  export BRIDGESH_BINDIR="$(dirname "$(command -v dirname)")"
fi

source "${BRIDGESH_DIR}/core.sh"
source "${BRIDGESH_DIR}/${BRIDGESH_OS}.sh"
