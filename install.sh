#!/usr/bin/env bash
# Part of Bridge.sh, MIT-licensed
# Copyright (c) 2022 Zaalay Studio, Muhammad Rivan

set -euo pipefail
shopt -s expand_aliases

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
scriptname="$(basename ${0})"
# This makes we can't use spaces in our project structure
ignorelist=("--exclude "{".git",".gitignore","gitty.sh"})
executablelist=("${tmpdir}/"{"install.sh","templates/app.sh"})

rcfilestr="BRIDGESH_BINDIR=${bindir}\nBRIDGESH_OS=${os}"
bash_rcfilestr='. "${HOME}/.bridgeshrc"'

###################### UTILITIES ##############################

rcappend() {
  [[ -f "${2}" ]] || touch "${2}"
  grep -q "${1}" "${2}" || echo -e "\n${1}" >> "${2}"
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

alias novalue='echo "${1} needs value"; exit 1'
alias invalidparam='echo "${1} is not a valid parameter"; exit 1'
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
        fi
        ;;
    esac

    nextparam
  done

  # Can't do short circuit here, use "if" instead
  if [[ "${src}" == "" ]]; then echo "No source?"; exit 1; fi

  (
    cd "${dest}"

    for item in $(curl -s "${src}" | grep href | sed 's/.*href="//' |
      sed 's/".*//'); do
      (contain "$(pathify "${item}")" "${exclude[@]}") && continue

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
    echo "Removing old Bridge.sh installation..."
  else
    echo "Uninstalling Bridge.sh..."
  fi

  rm -rf "${dir}"
  rm -rf "${rcfile}"
  rctakeaway "${bash_rcfilestr}" "${bash_rcfile}"

  ${upgrade} || echo "Bridge.sh has been uninstalled"
else
  echo "Installing Bridge.sh..."

  if ! [[ "${os}" =~ ^(bsd|linux|darwin)$ ]]; then
    echo "Sorry, this platform is not (yet) supported"
    exit 1
  fi

  rm -rf "${tmpdir}"
  mkdir -p "${tmpdir}"

  if ${test}; then
    if [[ "${testsrc}" == http*://* ]]; then
      webscrap "${testsrc}" ${ignorelist[@]} "${tmpdir}"
      chmod +x "${executablelist[@]}"
    else
      (cd "${testsrc}"; tar -c ${ignorelist[@]} . | tar -x -C "${tmpdir}")
    fi
  else
    curl -sSL "${src}" |
    tar -xz -C "${tmpdir}" --strip-components 1 ${ignorelist[@]}
  fi

  [[ -f "${dir}/uninstall.sh" ]] && "${dir}/uninstall.sh" -u

  rcwrite "${rcfilestr}" "${rcfile}"
  rcappend "${bash_rcfilestr}" "${bash_rcfile}"
  cat "${tmpdir}/templates/rc.sh" >> "${rcfile}"

  mv "${tmpdir}/"{"install.sh","uninstall.sh"}
  mv "${tmpdir}" "${dir}"

  echo "Bridge.sh has been installed"
fi
