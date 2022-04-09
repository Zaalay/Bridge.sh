#!/usr/bin/env bash
#
# MIT License
#
# Copyright (c) 2022 Zaalay Studio, Muhammad Rivan
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -euo pipefail
shopt -s expand_aliases

###################### DATA ##############################

test=false
[[ $# -ge 1 && "${1}" == "-t" ]] && test=true
os="$(uname -s | tr '[:upper:]' '[:lower:]')"
[[ os == *bsd ]] && os="bsd"

src="https://api.github.com/repos/Zaalay/Bridge.sh/tarball/alpha"
testsrc="$(dirname "${0}")"
[[ $# -ge 2 ]] && testsrc="${2}"
bindir="$(dirname "$(type -P dirname)")"
dir="${HOME}/.Bridge.sh"
rcfile="${HOME}/.bridgeshrc"
bash_rcfile="${HOME}/.bashrc"
# This makes we can't use spaces in our project structure
ignorelist=("--exclude "{".git",".gitignore","gitty.sh"})
executablelist=("${dir}/"{"install.sh","templates/app.sh"})

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

if [[ "$(basename ${0})" == "uninstall.sh" ]]; then
  echo "Uninstalling Bridge.sh..."

  rm -rf "${dir}"
  rm -rf "${rcfile}"
  rctakeaway "${bash_rcfilestr}" "${bash_rcfile}"

  echo "Bridge.sh has been uninstalled"
else
  [[ -f "${dir}/uninstall.sh" ]] && "${dir}/uninstall.sh"

  echo "Installing Bridge.sh..."

  if ! [[ "${os}" =~ ^(bsd|linux|darwin)$ ]]; then
    echo "Sorry, this platform is not (yet) supported"
    exit 1
  fi

  mkdir -p "${dir}"

  if ${test}; then
    if [[ "${testsrc}" == http*://* ]]; then
      webscrap "${testsrc}" ${ignorelist[@]} "${dir}"
      chmod +x "${executablelist[@]}"
    else
      (cd "${testsrc}"; tar -c ${ignorelist[@]} . | tar -x -C "${dir}")
    fi
  else
    curl -sSL "${src}" | tar -xz -C "${dir}" --strip-components 1 ${ignorelist[@]}
  fi

  mv "${dir}/"{"install.sh","uninstall.sh"}

  rcwrite "${rcfilestr}" "${rcfile}"
  rcappend "${bash_rcfilestr}" "${bash_rcfile}"
  cat "${dir}/templates/rc.sh" >> "${rcfile}"

  echo "Bridge.sh has been installed"
fi
