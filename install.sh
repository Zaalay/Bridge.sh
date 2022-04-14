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

#################### INIT UTILITIES ########################

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

src="https://api.github.com/repos/Zaalay/Bridge.sh/tarball/alpha"
testsrc="$(dirname "${0}")"
[[ $# -ge 2 ]] && testsrc="${2}"
bindir="$(dirname "$(type -P dirname)")"
dir="${HOME}/.Bridge.sh"
tmpdir="${HOME}/.Bridge.sh.bak"
rcfile="${HOME}/.bridgeshrc"
bash_rcfile="${HOME}/.bashrc"
zsh_rcfile="${HOME}/.zshrc"
scriptname="$(basename ${0})"
shell="$(basename "${SHELL}")"

c_default="\033[0m"
c_red="\033[1;31m"
c_green="\033[1;32m"
c_yellow="\033[1;33m"
c_blue="\033[1;34m"
c_magenta="\033[1;35m"
c_cyan="\033[1;36m"

ignorelist=(".git" ".gitignore" "gitty.sh")
ignorelist=($(paramexpand "--exclude" "${ignorelist[@]}"))
exelist=(
  "install.sh" "utils.sh" "templates/app.sh" "utils.sh"
  "modules/linux.sh" "modules/darwin.sh" "modules/bsd.sh"
)
exelist=($(listexpand "${tmpdir}/" "${exelist[@]}"))

rcfilestr="export BRIDGESH_BINDIR=${bindir}\nexport BRIDGESH_OS=${os}"
bashzsh_rcfilestr='. "${HOME}/.bridgeshrc"'

###################### UTILITIES ##############################

prompt() {
  local color="${c_default}"

  case "${1}" in
    -i|--info)
      color="${c_cyan}" ;;
    -a|--attention)
      color="${c_yellow}" ;;
    -e|--error)
      color="${c_red}" ;;
    -s|--success)
      color="${c_green}" ;;
  esac

  echo -e "  ${color}${@:2}${c_default}"
}

rcappend() {
  if [[ -f "${2}" ]]; then
    grep -q "${1}" "${2}" || echo -e "\n${1}" >> "${2}"
  else
    echo -e "\n${1}" >> "${2}"
  fi
}

rctakeaway() {
  # echo is intended for inplace replace
  [[ -f "${2}" ]] && echo "$(grep -v "${1}" "${2}")" > "${2}"
}

rcwrite() {
  echo -e "${1}" > "${2}"
}

urldecode() {
  echo -e "$(echo "${1}" | sed 's/+/ /g;s/%\(..\)/\\x\1/g;')"
}

pathify() {
  echo "${1}" | sed 's:/*$::'
}

contain() {
  for item in ${@:2}; do
    [[ "${1}" == "${item}" ]] && return 0
  done

  return 1
}

getfuns() {
  grep "() {" "${1}" | sed 's/() {//'
}

binlinks() {
  (
    cd "${1}"

    for bin in $(getfuns "${2}"); do
      ln -s "../${2}" "${3}/${bin}"
    done
  )
}

alias novalue='prompt -e "${1} needs value"; exit 1'
alias invalidparam='prompt -e "${1} is not a valid parameter"; exit 1'
alias nextparam='shift'
alias chkvalue='{
  if [[ $# -ge 2 ]]; then
    if [[ "${2:1:1}" != "-" ]]; then
      __lastvalue__="${2}"; nextparam
    else
      novalue
    fi
  else
    novalue
  fi
}'

webscrap() {
  local exclude=()
  local src=""
  local dest="."

  while [[ $# -gt 0 ]]; do
    case "${1}" in
      --exclude)
        chkvalue; exclude+=("$(pathify "${__lastvalue__}")") ;;
      -*)
        invalidparam ;;
      *)
        if [[ "${src}" == "" ]]; then
          src="${1}"
        elif [[ "${dest}" == "." ]]; then
          dest="${1}"
        fi ;;
    esac

    nextparam
  done

  if [[ "${src}" == "" ]];
  then prompt -e "No source?"; exit 1
  fi

  (
    cd "${dest}"

    for item in $(curl -s "${src}" | grep href | sed 's/.*href="//' |
      sed 's/".*//'); do
      (contain "$(pathify "${item}")" "${exclude[@]}") && continue

      # Space in "${item: -1}" is intented
      # TODO: test on mac
      if [[ "${item: -1}" == "/" ]]; then
        mkdir -p "$(urldecode "${item}")"

        (
          cd "${item}"
          webscrap "${src}/${item}" "${dest}/${item}"
        )
      else
        curl -sS "${src}/${item}" -o "$(urldecode "${item}")"
      fi
    done
  )
}

###################### INSTALATION ##############################

if [[ "${scriptname}" == "uninstall.sh" ]]; then
  if ${upgrade}; then
    prompt -i "Removing old Bridge.sh installation..."
  else
    prompt -i "Uninstalling Bridge.sh..."
  fi

  rm -rf "${dir}"
  rm -rf "${rcfile}"
  rctakeaway "${bashzsh_rcfilestr}" "${bash_rcfile}"
  rctakeaway "${bashzsh_rcfilestr}" "${zsh_rcfile}"

  ${upgrade} || prompt -s "Bridge.sh has been uninstalled"
else
  prompt -i "Installing Bridge.sh..."

  if ! [[ "${os}" =~ ^(bsd|linux|darwin)$ ]]; then
    prompt -e "Sorry, this platform is not (yet) supported"
    exit 1
  elif ! [[ "${shell}" =~ ^(bash|zsh)$ ]]; then
    prompt -e "Sorry, this shell is not (yet) supported"
    exit 1
  fi

  rm -rf "${tmpdir}"
  mkdir -p "${tmpdir}"
  mkdir -p "${tmpdir}/binaries"
  mkdir -p "${tmpdir}/linux_binaries"
  mkdir -p "${tmpdir}/darwin_binaries"
  mkdir -p "${tmpdir}/bsd_binaries"

  if ${test}; then
    if [[ "${testsrc}" == http*://* ]]; then
      webscrap "${testsrc}" ${ignorelist[@]} "${tmpdir}"
      chmod +x "${exelist[@]}"
    else
      (cd "${testsrc}"; tar -c ${ignorelist[@]} . | tar -x -C "${tmpdir}")
    fi
  else
    curl -sSL "${src}" |
    tar -xz -C "${tmpdir}" --strip-components 1 ${ignorelist[@]}
  fi

  [[ -f "${dir}/uninstall.sh" ]] && "${dir}/uninstall.sh" -u

  rcwrite "${rcfilestr}" "${rcfile}"
  rcappend "${bashzsh_rcfilestr}" "${bash_rcfile}"
  rcappend "${bashzsh_rcfilestr}" "${zsh_rcfile}"
  cat "${tmpdir}/templates/rc.sh" >> "${rcfile}"

  binlinks "${tmpdir}" "utils.sh" "binaries"
  binlinks "${tmpdir}" "modules/linux.sh" "linux_binaries"
  binlinks "${tmpdir}" "modules/darwin.sh" "darwin_binaries"
  binlinks "${tmpdir}" "modules/bsd.sh" "bsd_binaries"

  mv "${tmpdir}/"{"install.sh","uninstall.sh"}
  mv "${tmpdir}" "${dir}"

  echo; prompt -s "Bridge.sh has been installed"
  prompt -a "You need to reopen this terminal to take effect"
fi
