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

BRIDGESH_OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
BRIDGESH_BINDIR="$(dirname "$(type -P dirname)")"
BRIDGESH_SRCDIR="https://raw.githubusercontent.com/Zaalay/Bridge.sh/stable/modules"
BRIDGESH_DIR="${HOME}/.Bridge.sh"
BRIDGESH_RCFILE="${HOME}/.bridgeshrc"
BRIDGESH_RCSTR=". \"\${HOME}/.bridgeshrc\""
BASH_RCFILE="${HOME}/.bashrc"

bridgesh_core_sh_sum="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
bridgesh_bsd_sh_sum="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
bridgesh_linux_sh_sum="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
bridgesh_macos_sh_sum="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

bridgesh::dlcheck() {
  local var_name="bridgesh_${1}_sh_sum"
  local target_name=""
  
  [[ $# -eq 2 ]] && target_name="${2}" || target_name="${1}"

  if [[ "$(curl -sS "${BRIDGESH_SRCDIR}/${1}.sh" |
      tee "${BRIDGESH_DIR}/${target_name}.sh" | sha256sum |
      cut -d " " -f1)" == "${!var_name}" ]]; then
    echo "${1}.sh has been downloaded"
  else
    echo "Failed to download ${1}.sh"
    rm "${BRIDGESH_DIR}/${target_name}.sh"
    exit 1
  fi
}

case "${BRIDGESH_OS}" in
  *bsd)
    BRIDGESH_OS="bsd" ;;
  linux|darwin)
    ;;
  *)
    echo "Sorry, this platform is not (yet) supported"
    exit 1 ;;
esac

mkdir -p "${BRIDGESH_DIR}"
bridgesh::dlcheck core
bridgesh::dlcheck "${BRIDGESH_OS}" os

echo "BRIDGESH_BINDIR=${BRIDGESH_BINDIR}" > "${BRIDGESH_RCFILE}"

if ! grep -q "${BRIDGESH_RCSTR}" "${BASH_RCFILE}"; then
  echo -e "\n${BRIDGESH_RCSTR}" >> "${BASH_RCFILE}"
fi


