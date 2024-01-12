# Part of Bridge.sh, MIT-licensed
# Copyright (c) 2022 Zaalay Studio, Muhammad Rivan
#
# STATIC VARIABLES WILL BE PATCHED BY INSTALLER
# CHECK ABOVE THE COPYRIGHT
#
# * BRIDGE_BINDIR (above)
# * BRIDGE_OS (above)

export BRIDGE_DIR="${HOME}/.Bridge.sh"
export BRIDGE_SHELL="sh"

if ! [[ -z ${BASH_VERSION+x} ]]; then
  export BRIDGE_SHELL="bash"
elif ! [[ -z ${ZSH_VERSION+x} ]]; then
  export BRIDGE_SHELL="zsh"
fi

if [[ "${BRIDGE_SHELL}" == "zsh" ]]; then
  export BRIDGE_EMULATE="$(emulate)"
  emulate -L ksh
fi

source "${BRIDGE_DIR}/modules/core.sh" "preloaded"

if [[ "${BRIDGE_SHELL}" == "zsh" ]]; then
  emulate ${BRIDGE_EMULATE}
fi
