app::cache() {

}

app::get_file() {
  readlink -m "${0}"
}

app::get_dir() {
  dirname "$(app::get_file)"
}

app::get_lib_dir() {
  dirname "$(readlink -m "${BASH_SOURCE[0]:-$0}")"
}

app::get_shell() {

}

app::init() {

}

