# Part of Bridge.sh, MIT-licensed
# Copyright (c) 2022 Zaalay Studio, Muhammad Rivan
#
# * BRIDGESH_BINDIR (in core)
# * BRIDGESH_OS (in core)
# * BRIDGESH_DIR (in core)

if [[ "$(basename "${SHELL}")" == "bash" ]]; then
  export BRIDGESH_DIR="$(dirname "${0}")/bridge_modules/bridgesh"
else
  export BRIDGESH_DIR="${0:a:h}/bridgesh"
fi

source "${BRIDGESH_DIR}/modules/core.sh" "semifull"
