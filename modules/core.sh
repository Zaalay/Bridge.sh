#!/usr/bin/env bash
# Part of Bridge.sh, MIT-licensed
# Copyright (c) 2022 Zaalay Studio, Muhammad Rivan
#
# * BRIDGE_BINDIR
# * BRIDGE_OS
# * BRIDGE_DIR
#
# BRIDGE_LOADLV=simple|preloaded|full

# Make this more sensible
shopt -s expand_aliases 2> /dev/null || setopt aliases

if ! (return 0 2> /dev/null); then
  BRIDGE_LOADLV="full"
elif [[ $# -ge 1 ]]; then
  BRIDGE_LOADLV="${1}"
elif [[ $# -eq 0 ]]; then
  exit 1
fi

if [[ "${BRIDGE_LOADLV}" =~ ^(semifull|full)$ ]]; then
  export BRIDGE_BINDIR="$(dirname "$(env which dirname)")"
  export BRIDGE_OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
  [[ "${BRIDGE_OS}" == *bsd ]] && export BRIDGE_OS="bsd"
fi

if [[ "${BRIDGE_LOADLV}" =~ ^(full)$ ]]; then
  export BRIDGE_DIR="$(dirname "$(dirname "${0}")")"
fi

if [[ "${BRIDGE_LOADLV}" =~ ^(semifull|full|preloaded)$ ]]; then
  BRIDGE_USROSBINDIR="${BRIDGE_DIR}/${BRIDGE_OS}_binaries"
  BRIDGE_SCRIPTNAME="$(basename ${0})"
  BRIDGE_USRBINDIR="${BRIDGE_DIR}/binaries"

  # Don't use "source" as it also used for terminal inits
  . "${BRIDGE_DIR}/modules/${BRIDGE_OS}.sh"
  export PATH="${BRIDGE_USRBINDIR}:${BRIDGE_USROSBINDIR}:${PATH}"
fi

export BRIDGE_SHELL="sh"

if ! [[ -z ${BASH_VERSION+x} ]]; then
  export BRIDGE_SHELL="bash"
elif ! [[ -z ${ZSH_VERSION+x} ]]; then
  export BRIDGE_SHELL="zsh"
fi

BRIDGE_CDEFAULT="\033[0m"
BRIDGE_CRED="\033[1;31m"
BRIDGE_CGREEN="\033[1;32m"
BRIDGE_CYELLOW="\033[1;33m"
BRIDGE_CBLUE="\033[1;34m"
BRIDGE_CMAGENTA="\033[1;35m"
BRIDGE_CCYAN="\033[1;36m"

bridge::cli::write() {
  local color="${BRIDGE_CDEFAULT}"

  case "${1}" in
    -i|--info)
      color="${BRIDGE_CCYAN}" ;;
    -a|--attention)
      color="${BRIDGE_CYELLOW}" ;;
    -e|--error)
      color="${BRIDGE_CRED}" ;;
    -s|--success)
      color="${BRIDGE_CGREEN}" ;;
  esac

  echo -e "  ${color}${@:2}${BRIDGE_CDEFAULT}"
}

bridge::rc::append() {
  if [[ -f "${2}" ]]; then
    grep -q "${1}" "${2}" || echo -e "\n${1}" >> "${2}"
  else
    echo -e "\n${1}" >> "${2}"
  fi
}

bridge::rc::takeaway() {
  # echo is intended for inplace replace
  [[ -f "${2}" ]] && echo "$(grep -v "${1}" "${2}")" > "${2}"
}

bridge::rc::write() {
  echo -e "${1}" > "${2}"
}

bridge::path::decode() {
  echo -e "$(echo "${1}" | sed 's/+/ /g;s/%\(..\)/\\x\1/g;')" | sed 's:/*$::'
}

bridge::array::contain() {
  for item in ${@:2}; do
    [[ "${1}" == "${item}" ]] && return 0
  done

  return 1
}

bridge::shbin::get_functions() {
  grep -v "grep" "${1}" | grep "() {" | sed 's/() {//'
}

bridge::shbin::link_functions() {
  (
    cd "${1}"

    for bin in $(bridge::shbin::get_functions "${2}"); do
      ln -s "../${2}" "${3}/${bin}"
    done
  )
}

alias bridge::param::warn_value='{
  bridge::cli::write -e "${1} needs value"
  exit 1
}'

alias bridge::param::invalidate='{
  bridge::cli::write -e "${1} is not a valid parameter"
  exit 1
}'

alias bridge::param::next='shift'

alias bridge::param::_get_value='{
  if [[ $# -ge 2 ]]; then
    if [[ "${2:1:1}" != "-" ]]; then
      __bridgesh_lastvalue__="${2}"; bridge::param::next
    else
      bridge::param::warn_value
    fi
  else
    bridge::param::warn_value
  fi
}'

bridge::web::get_items() {
  curl -s "${1}" | grep href | sed 's/.*href="//' | sed 's/".*//'
}

bridge::web::scrap() {
  local exclude=('')
  local src=""
  local dest="."

  while [[ $# -gt 0 ]]; do
    case "${1}" in
      --exclude)
        bridge::param::_get_value
        exclude+=("$(bridge::path::decode "${__bridgesh_lastvalue__}")") ;;
      -*)
        bridge::param::invalidate ;;
      *)
        if [[ "${src}" == "" ]]; then
          src="${1}"
        elif [[ "${dest}" == "." ]]; then
          dest="${1}"
        fi ;;
    esac

    bridge::param::next
  done

  if [[ "${src}" == "" ]]; then
    bridge::cli::write -e "No source?"; exit 1
  fi

  mkdir -p "${dest}"

  for item in $(bridge::web::get_items "${src}"); do
    if (bridge::array::contain "$(bridge::path::decode "${item}")" \
        "${exclude[@]}"); then
      continue
    fi

    # Space in "${item: -1}" is intented
    if [[ "${item: -1}" == "/" ]]; then
      bridge::web::scrap "${src}/${item}" "${dest}/${item}"
    else
      curl -sS "${src}/${item}" -o "$(bridge::path::decode "${dest}/${item}")"
    fi
  done
}

if ! (return 0 2> /dev/null); then "${BRIDGE_SCRIPTNAME}" "${@:1}"; fi
