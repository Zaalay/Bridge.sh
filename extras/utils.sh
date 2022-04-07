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
  "${BRIDGESH_DIR}/uninstall.sh"
}
