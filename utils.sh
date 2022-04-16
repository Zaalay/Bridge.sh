#!/usr/bin/env bash
#
# utils.sh
# Part of Bridge.sh, MIT-licensed
# Copyright (c) 2022 Zaalay Studio, Muhammad Rivan
#
# Don't use any 'exit' here as this file is sourced, not directly executed

set -euo pipefail

create-bridge-app() {
  # TODO: Improve this one
  # Add exception to utils stuff
  mkdir -p "${1}/"{"bridge_modules","src","data"}

  echo -e "#!/usr/bin/env ${BRIDGE_SHELL}\n" > "${1}/${1}.sh"
  cat "${BRIDGE_DIR}/templates/app.sh" >> "${1}/${1}.sh"
  chmod +x "${1}/${1}.sh"

  cp -r "${BRIDGE_DIR}" "${1}/bridge_modules/bridgesh"
  cp "${BRIDGE_DIR}/templates/apploader.sh" "${1}/bridge_modules/init.sh"
}

bridgesh-upgrade() {
  curl -sSL https://github.com/Zaalay/Bridge.sh/raw/alpha/install.sh | bash
}

bridgesh-update() {
  bridgesh-upgrade
}

bridgesh-uninstall() {
  "${BRIDGE_DIR}/uninstall.sh"
}

if ! (return 0 2> /dev/null); then
  source "$(dirname "$(dirname "${0}")")/modules/core.sh" "full"
  "${BRIDGE_SCRIPTNAME}" "${@:1}"
fi
