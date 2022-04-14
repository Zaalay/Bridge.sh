#!/usr/bin/env bash
#
# utils.sh
# Part of Bridge.sh, MIT-licensed
# Copyright (c) 2022 Zaalay Studio, Muhammad Rivan
#
# Don't use any 'exit' here as this file is sourced, not directly executed

set -euo pipefail
source "${HOME}/.bridgeshrc"

create-bridge-app() {
  # TODO: Improve this one
  mkdir -p "${1}/"{"bridge_modules","src","data"}

  echo -e "#!/usr/bin/env ${BRIDGESH_SHELL}\n" > "${1}/${1}.sh"
  cat "${BRIDGESH_DIR}/templates/app.sh" >> "${1}/${1}.sh"
  chmod +x "${1}/${1}.sh"

  cp -r "${BRIDGESH_DIR}/modules" "${1}/bridge_modules/bridgesh"
  cp "${BRIDGESH_DIR}/templates/init.sh" "${1}/bridge_modules/init.sh"
}

bridgesh-upgrade() {
  curl -sS https://raw.githubusercontent.com/Zaalay/Bridge.sh/alpha/install.sh |
  bash
}

bridgesh-update() {
  bridgesh-upgrade
}

bridgesh-uninstall() {
  "${BRIDGESH_DIR}/uninstall.sh"
}

"${BRIDGESH_SCRIPTNAME}" "${@:1}"
