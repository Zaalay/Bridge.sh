create-bridge-app() {
  echo "Under development..."
}

bridgesh-update() {
  curl -sS https://raw.githubusercontent.com/Zaalay/Bridge.sh/alpha/install.sh | bash
}

bridgesh-uninstall() {
  "${BRIDGESH_DIR}/uninstall.sh"
}
