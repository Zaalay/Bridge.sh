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

###################### DATA ##############################

BRIDGESH_OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
[[ BRIDGESH_OS == *bsd ]] && BRIDGESH_OS="bsd"
BRIDGESH_BINDIR="$(dirname "$(type -P dirname)")"
BRIDGESH_SRCDIR="https://raw.githubusercontent.com/Zaalay/Bridge.sh/alpha/modules"
BRIDGESH_DIR="${HOME}/.Bridge.sh"
BRIDGESH_RCFILE="${HOME}/.bridgeshrc"
BASH_RCFILE="${HOME}/.bashrc"

BRIDGESH_RCSTR="\"\${HOME}/.bridgeshrc\""
BRIDGESH_DIRSTR="\"\${HOME}/.Bridge.sh\""

BRIDGESH_DIRRAW="\"\${BRIDGESH_DIR}\""
BRIDGESH_OSRAW="\"\${BRIDGESH_OS}\""

bridgesh_defaults="BRIDGESH_BINDIR=${BRIDGESH_BINDIR}\n"
bridgesh_defaults+="BRIDGESH_DIR=${BRIDGESH_DIRSTR}\n"
bridgesh_defaults+="BRIDGESH_OS=${BRIDGESH_OS}\n\n"
bridgesh_defaults+=". ${BRIDGESH_DIRRAW}/modules/core.sh\n"
bridgesh_defaults+=". ${BRIDGESH_DIRRAW}/modules/${BRIDGESH_OSRAW}.sh"

###################### UTILITIES ##############################

bridgesh::rcappend() {
  ! grep -q "${1}" "${2}" && echo -e "\n${1}" >> "${2}"
}

bridgesh::rctakeaway() {
  grep -qv "${1}" "${2}" > "${2}.bak"
  mv -f "${2}"{".bak",""}
}

bridgesh::rcwrite() {
  echo -e "${1}" > "${2}"
}

###################### INSTALATION ##############################

if [[ ${0} == "uninstall.sh" ]]; then
  rm -rf "${BRIDGESH_DIR}"
  rm -rf "${BRIDGESH_RCFILE}"
  bridgesh::rctakeaway ". ${BRIDGESH_RCSTR}" "${BASH_RCFILE}"
  
  echo "Bridge.sh has been uninstalled"
else
  [[ -f "${BRIDGESH_DIR}/uninstall.sh" ]] && "${BRIDGESH_DIR}/uninstall.sh"

  if ! [[ "${BRIDGESH_OS}" =~ ^(bsd|linux|darwin)$ ]]; then
    echo "Sorry, this platform is not (yet) supported"
    exit 1
  fi

  mkdir -p "${BRIDGESH_DIR}"
  curl -L https://api.github.com/repos/Zaalay/Bridge.sh/tarball/alpha |
    tar -xz -C "${BRIDGESH_DIR}" --strip-components 1 --exclude ".gitignore"
  mv "${BRIDGESH_DIR}/"{"install.sh","uninstall.sh"}

  bridgesh::rcwrite "${bridgesh_defaults}" "${BRIDGESH_RCFILE}"
  bridgesh::rcappend ". ${BRIDGESH_RCSTR}" "${BASH_RCFILE}"
  
  echo "Bridge.sh has been installed"
fi
