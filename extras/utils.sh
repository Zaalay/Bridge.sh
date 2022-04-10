# Part of Bridge.sh, MIT-licensed
# Copyright (c) 2022 Zaalay Studio, Muhammad Rivan
#
# Don't use any 'exit' here as this file is sourced, not directly executed 

create-bridge-app() {
  mkdir -p "${1}/"{"bridge_modules","src","data"}

  cp -r "${BRIDGESH_DIR}/modules" "${1}/bridge_modules/bridgesh"
  cp "${BRIDGESH_DIR}/templates/app.sh" "${1}/${1}.sh"
  cp "${BRIDGESH_DIR}/templates/init.sh" "${1}/bridge_modules/init.sh"
}

bridgesh-update() {
  curl -sS https://raw.githubusercontent.com/Zaalay/Bridge.sh/alpha/install.sh | bash
}

bridgesh-uninstall() {
  if [[ -f "${BRIDGESH_DIR}/uninstall.sh" ]]; then
    "${BRIDGESH_DIR}/uninstall.sh"
  else
    echo "No Bridge.sh installation found"
    return 1
  fi
}
