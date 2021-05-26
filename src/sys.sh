sys::get_username() {
  logname 2> /dev/null || echo ${SUDO_USER:-${USER}}
}

sys::is_root() {
  [[ -w "/" ]]
}

sys::is_kernel() {
  [[ "$(uname -s)" =~ "${1}" ]]
}

sys::is_distro() {
  [[ "$(cat '/etc/os-release' | awk -F '=' '/ID/{print $2}')" =~ "${1}" ]]
}
