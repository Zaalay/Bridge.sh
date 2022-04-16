#!/usr/bin/env bash
# Part of Bridge.sh, MIT-licensed
# Copyright (c) 2022 Zaalay Studio, Muhammad Rivan
#
# * BRIDGESH_BINDIR
# * BRIDGESH_OS
# * BRIDGESH_DIR
#
# BRIDGESH_LOADLV=simple|preloaded|full

if [[ $# -eq 0 ]]; then
  exit 1
elif [[ $# -ge 1 ]]; then
  BRIDGESH_LOADLV="${1}"
elif ! (return 0 2> /dev/null); then
  BRIDGESH_LOADLV="full"
fi

if [[ "${BRIDGESH_LOADLV}" =~ ^(semifull|full)$ ]]; then
  export BRIDGESH_BINDIR="$(dirname "$(env which dirname)")"
  export BRIDGESH_OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
  [[ "${BRIDGESH_OS}" == *bsd ]] && export BRIDGESH_OS="bsd"
fi

if [[ "${BRIDGESH_LOADLV}" =~ ^(full)$ ]]; then
  export BRIDGESH_DIR="$(dirname "$(dirname "${0}")")"
fi

if [[ "${BRIDGESH_LOADLV}" =~ ^(semifull|full|preloaded)$ ]]; then
  BRIDGESH_USROSBINDIR="${BRIDGESH_DIR}/${BRIDGESH_OS}_binaries"
  BRIDGESH_SCRIPTNAME="$(basename ${0})"
  BRIDGESH_USRBINDIR="${BRIDGESH_DIR}/binaries"

  # Don't use "source" as it also used for terminal inits
  . "${BRIDGESH_DIR}/modules/${BRIDGESH_OS}.sh"
  export PATH="${BRIDGESH_USRBINDIR}:${BRIDGESH_USROSBINDIR}:${PATH}"
fi

BRIDGESH_SHELL="$(basename "${SHELL}")"
BRIDGESH_CDEFAULT="\033[0m"
BRIDGESH_CRED="\033[1;31m"
BRIDGESH_CGREEN="\033[1;32m"
BRIDGESH_CYELLOW="\033[1;33m"
BRIDGESH_CBLUE="\033[1;34m"
BRIDGESH_CMAGENTA="\033[1;35m"
BRIDGESH_CCYAN="\033[1;36m"

bridgesh::cli::write() {
  local color="${BRIDGESH_CDEFAULT}"

  case "${1}" in
    -i|--info)
      color="${BRIDGESH_CCYAN}" ;;
    -a|--attention)
      color="${BRIDGESH_CYELLOW}" ;;
    -e|--error)
      color="${BRIDGESH_CRED}" ;;
    -s|--success)
      color="${BRIDGESH_CGREEN}" ;;
  esac

  echo -e "  ${color}${@:2}${BRIDGESH_CDEFAULT}"
}

bridgesh::rc::append() {
  if [[ -f "${2}" ]]; then
    grep -q "${1}" "${2}" || echo -e "\n${1}" >> "${2}"
  else
    echo -e "\n${1}" >> "${2}"
  fi
}

bridgesh::rc::takeaway() {
  # echo is intended for inplace replace
  [[ -f "${2}" ]] && echo "$(grep -v "${1}" "${2}")" > "${2}"
}

bridgesh::rc::write() {
  echo -e "${1}" > "${2}"
}

bridgesh::path::decode() {
  echo -e "$(echo "${1}" | sed 's/+/ /g;s/%\(..\)/\\x\1/g;')" | sed 's:/*$::'
}

bridgesh::array::contain() {
  for item in ${@:2}; do
    [[ "${1}" == "${item}" ]] && return 0
  done

  return 1
}

bridgesh::shbin::get_functions() {
  grep -v "grep" "${1}" | grep "() {" | sed 's/() {//'
}

bridgesh::shbin::link_functions() {
  (
    cd "${1}"

    for bin in $(bridgesh::shbin::get_functions "${2}"); do
      ln -s "../${2}" "${3}/${bin}"
    done
  )
}

alias bridgesh::param::warn_value='{
  bridgesh::cli::write -e "${1} needs value"
  exit 1
}'

alias bridgesh::param::invalidate='{
  bridgesh::cli::write -e "${1} is not a valid parameter"
  exit 1
}'

alias bridgesh::param::next='shift'

alias bridgesh::param::_get_value='{
  if [[ $# -ge 2 ]]; then
    if [[ "${2:1:1}" != "-" ]]; then
      __bridgesh_lastvalue__="${2}"; bridgesh::param::next
    else
      bridgesh::param::warn_value
    fi
  else
    bridgesh::param::warn_value
  fi
}'

bridgesh::web::get_items() {
  curl -s "${1}" | grep href | sed 's/.*href="//' | sed 's/".*//'
}

bridgesh::web::scrap() {
  local exclude=('')
  local src=""
  local dest="."

  while [[ $# -gt 0 ]]; do
    case "${1}" in
      --exclude)
        bridgesh::param::_get_value
        exclude+=("$(bridgesh::path::decode "${__bridgesh_lastvalue__}")") ;;
      -*)
        bridgesh::param::invalidate ;;
      *)
        if [[ "${src}" == "" ]]; then
          src="${1}"
        elif [[ "${dest}" == "." ]]; then
          dest="${1}"
        fi ;;
    esac

    bridgesh::param::next
  done

  if [[ "${src}" == "" ]]; then
    bridgesh::cli::write -e "No source?"; exit 1
  fi

  (
    cd "${dest}"

    for item in $(bridgesh::web::get_items "${src}"); do
      if (bridgesh::array::contain "$(bridgesh::path::decode "${item}")" \
          "${exclude[@]}"); then
        continue
      fi

      # Space in "${item: -1}" is intented
      if [[ "${item: -1}" == "/" ]]; then
        mkdir -p "$(bridgesh::path::decode "${item}")"
        bridgesh::web::scrap "${src}/${item}" "${dest}/${item}"
      else
        curl -sS "${src}/${item}" -o "$(bridgesh::path::decode "${item}")"
      fi
    done
  )
}

if ! (return 0 2> /dev/null); then "${BRIDGESH_SCRIPTNAME}" "${@:1}"; fi
