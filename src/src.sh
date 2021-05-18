src::get_file() {
  readlink -m "${BASH_SOURCE[0]:-$0}"
}

src::get_dir() {
  dirname "$(src::get_dir)"
}

src::init() {

}
