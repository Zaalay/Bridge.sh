#!/usr/bin/env bash
#
# utils.sh
# Part of Bridge.sh, MIT-licensed
# Copyright (c) 2022 Zaalay Studio, Muhammad Rivan
#
# Don't use any 'exit' here as this file is sourced, not directly executed

set -euo pipefail

bridge() {
  local cmd="bridge"
  local wcmd=""
  local params=("")

  for menu in "${@:1}"; do
    cmd+=".${menu}"

    if command -v "${cmd}" &> /dev/null ; then
      wcmd="${cmd}"
      params=("")
    else
      params+=("${menu}")
    fi
  done

  [[ -z "${wcmd}" || "${wcmd}" == "bridge" ]] || "${wcmd}" "${params[@]:1}"
}

create-bridge-app() {
  # TODO: Add exception to utils stuff

  if [[ -e "${1}" ]]; then
    bridge.cli.write "\"${1}\" is already exist..."
    bridge.cli.confirm "Wanna override?" override

    if "${override}"; then
      rm -rf "${1}"
    else
      bridge.cli.write -s "Got you..."
      return 0
    fi
  fi

  mkdir -p "${1}/"{"bridge_modules","src","data"}

  echo -e "#!/usr/bin/env ${BRIDGE_SHELL}\n" > "${1}/${1}.sh"
  cat "${BRIDGE_DIR}/templates/app.sh" >> "${1}/${1}.sh"
  chmod +x "${1}/${1}.sh"

  cp -r "${BRIDGE_DIR}" "${1}/bridge_modules/bridgesh"
  cp "${BRIDGE_DIR}/templates/apploader.sh" "${1}/bridge_modules/init.sh"

  bridge.cli.write -s "Done! \"${1}\" has been created."
}

bridge-upgrade() {
  curl -sSL https://github.com/Zaalay/Bridge.sh/raw/alpha/install.sh | bash
}

bridge-update() {
  bridge-upgrade
}

bridge-uninstall() {
  "${BRIDGE_DIR}/uninstall.sh"
}

if ! (return 0 2> /dev/null); then
  source "$(dirname "$(dirname "${0}")")/modules/core.sh" "full"
  "${BRIDGE_SCRIPTNAME}" "${@:1}"
fi
