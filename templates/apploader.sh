# Part of Bridge.sh, MIT-licensed
# Copyright (c) 2022 Zaalay Studio, Muhammad Rivan

export BRIDGE_SHELL="sh"

if ! [[ -z ${BASH_VERSION+x} ]]; then
  export BRIDGE_SHELL="bash"
elif ! [[ -z ${ZSH_VERSION+x} ]]; then
  export BRIDGE_SHELL="zsh"
fi

if [[ "${BRIDGE_SHELL}" == "zsh" ]]; then
  export BRIDGE_EMULATE="$(emulate)"
  export BRIDGE_DIR="${0:a:h}/bridgesh"
  emulate -L ksh
else
  export BRIDGE_DIR="$(dirname "${0}")/bridge_modules/bridgesh"
fi

# FIXME
source "${BRIDGE_DIR}/modules/core.sh" "semifull"

if [[ "${BRIDGE_SHELL}" == "zsh" ]]; then
  emulate ${BRIDGE_EMULATE}
fi
