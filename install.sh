#!/usr/bin/env bash
# Part of Bridge.sh, MIT-licensed
# Copyright (c) 2022 Zaalay Studio, Muhammad Rivan
#
# Use "[[ ... ]] && ..." or "[[ ... ]] || ..." only for one condition
# Otherwise, it will cause disasters like "is_file_exist &&
# does_file_contain_this || write_that" where "write_that" is always
# executed

set -euo pipefail
shopt -s expand_aliases

###################### INIT ########################

c_default="\033[0m"
c_red="\033[1;31m"
c_cyan="\033[1;36m"

info() {
  echo -e "  ${c_cyan}${@:1}${c_default}"
}

error() {
  echo -e "  ${c_red}${@:1}${c_default}"
}

paramexpand() {
  for item in "${@:2}"; do
    echo "${1}" "${item}"
  done
}

listexpand() {
  for item in "${@:2}"; do
    echo "${1}${item}"
  done
}

###################### DATA ##############################

test=false
[[ $# -ge 1 && "${1}" == "-t" ]] && test=true
upgrade=false
[[ $# -ge 1 && "${1}" == "-u" ]] && upgrade=true
os="$(uname -s | tr '[:upper:]' '[:lower:]')"
[[ os == *bsd ]] && os="bsd"
# Used when this script is executed by su, sudo, and such
realuser="${SUDO_USER:-$(logname 2> /dev/null || echo "${USER}")}"

bindir="$(dirname "$(type -P dirname)")"
realhomedir="$(eval echo ~"${realuser}")"
dir="${realhomedir}/.Bridge.sh"
tmpdir="${realhomedir}/.Bridge.sh.bak"
rcfile="${realhomedir}/.bridgeshrc"
bash_rcfile="${realhomedir}/.bashrc"
zsh_rcfile="${realhomedir}/.zshrc"
scriptname="$(basename ${0})"
shell="$(basename "${SHELL}")"

ignorelist=(".git" ".gitignore" "gitty.sh" "tests.bats")
ignorelist=($(paramexpand "--exclude" "${ignorelist[@]}"))
exelist=(
  "install.sh" "utils.sh" "templates/app.sh" "modules/core.sh"
  "modules/linux.sh" "modules/darwin.sh" "modules/bsd.sh"
)
exelist=($(listexpand "${tmpdir}/" "${exelist[@]}"))

rcfilestr="export BRIDGESH_BINDIR=${bindir}\nexport BRIDGESH_OS=${os}"
bashzsh_rcfilestr='. "${HOME}/.bridgeshrc"'

###################### ALIASES ##############################

alias rctakeaway='bridgesh::rc::takeaway'
alias rcwrite='bridgesh::rc::write'
alias rcappend='bridgesh::rc::append'
alias webscrap='bridgesh::web::scrap'
alias binlinks='bridgesh::shbin::link_functions'
alias success='bridgesh::cli::write -s'
alias attention='bridgesh::cli::write -a'

###################### INSTALATION ##############################
export BRIDGESH_DIR="${dir}"

if [[ "${scriptname}" == "uninstall.sh" ]]; then
  source "${dir}/modules/core.sh" "simple"

  if ${upgrade}; then
    info "Removing old Bridge.sh installation..."
  else
    info "Uninstalling Bridge.sh..."
  fi

  rm -rf "${dir}"
  rm -rf "${rcfile}"
  rctakeaway "${bashzsh_rcfilestr}" "${bash_rcfile}"
  rctakeaway "${bashzsh_rcfilestr}" "${zsh_rcfile}"

  ${upgrade} || success "Bridge.sh has been uninstalled"
else
  info "Installing Bridge.sh..."

  if ! [[ "${os}" =~ ^(bsd|linux|darwin)$ ]]; then
    error "Sorry, this platform is not (yet) supported"
    exit 1
  elif ! [[ "${shell}" =~ ^(bash|zsh)$ ]]; then
    error "Sorry, this shell is not (yet) supported"
    exit 1
  fi

  rm -rf "${tmpdir}"
  mkdir -p "${tmpdir}"
  mkdir -p "${tmpdir}/binaries"
  mkdir -p "${tmpdir}/linux_binaries"
  mkdir -p "${tmpdir}/darwin_binaries"
  mkdir -p "${tmpdir}/bsd_binaries"

  if "${test}"; then
    if [[ $# -ge 2 ]]; then
      src="${2}"
      source <(curl -sS "${src}/modules/core.sh") "simple"

      webscrap "${src}" ${ignorelist[@]} "${tmpdir}"
      chmod +x "${exelist[@]}"
    else
      src="$(dirname "${0}")"
      source "${src}/modules/core.sh" "simple"

      (cd "${src}"; tar -c ${ignorelist[@]} . | tar -x -C "${tmpdir}")
    fi
  else
    src="https://api.github.com/repos/Zaalay/Bridge.sh/tarball/alpha"
    gitsrc="https://github.com/Zaalay/Bridge.sh/raw/alpha"
    source <(curl -sSL "${gitsrc}/modules/core.sh") "simple"

    curl -sSL "${src}" |
    tar -xz -C "${tmpdir}" --strip-components 1 ${ignorelist[@]}
  fi

  [[ -f "${dir}/uninstall.sh" ]] && "${dir}/uninstall.sh" -u

  rcwrite "${rcfilestr}" "${rcfile}"
  rcappend "${bashzsh_rcfilestr}" "${bash_rcfile}"
  rcappend "${bashzsh_rcfilestr}" "${zsh_rcfile}"
  cat "${tmpdir}/templates/rcloader.sh" >> "${rcfile}"

  binlinks "${tmpdir}" "utils.sh" "binaries"
  binlinks "${tmpdir}" "modules/core.sh" "binaries"
  binlinks "${tmpdir}" "modules/linux.sh" "linux_binaries"
  binlinks "${tmpdir}" "modules/darwin.sh" "darwin_binaries"
  binlinks "${tmpdir}" "modules/bsd.sh" "bsd_binaries"

  mv "${tmpdir}/"{"install.sh","uninstall.sh"}
  mv "${tmpdir}" "${dir}"

  echo; success "Bridge.sh has been installed"
  attention "You need to reopen this terminal to take effect"
fi
