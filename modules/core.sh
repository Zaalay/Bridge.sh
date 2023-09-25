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

bridge() {
  local cmd=""
  local params=('')

  if [[ $# -ge 2 ]]; then
    cmd="bridge.${1}.${2}"
  elif [[ $# -ge 1 ]]; then
    cmd="bridge.${1}"
  else
    bridge.cli.write -e "bridge: Insufficient parameter"; exit 1
  fi

  if command -v "${cmd}" &> /dev/null; then
    if [[ $# -ge 3 ]]; then "${cmd}" "${@:3}"; else "${cmd}"; fi
  else
    bridge.cli.write -e "bridge: Command not found: ${cmd}"; exit 1
  fi
}

bridge.str.upper() {
  echo -e "${@:1}" | tr '[:lower:]' '[:upper:]'
}

bridge.str.lower() {
  echo -e "${@:1}" | tr '[:upper:]' '[:lower:]'
}

bridge.cli.write() {
  local color="${BRIDGE_CDEFAULT}"
  local text="${@:2}"

  case "${1}" in
    -i|--info)
      color="${BRIDGE_CCYAN}" ;;
    -a|--attention)
      color="${BRIDGE_CYELLOW}" ;;
    -e|--error)
      color="${BRIDGE_CRED}" ;;
    -s|--success)
      color="${BRIDGE_CGREEN}" ;;
    *)
      color="${BRIDGE_CMAGENTA}"; text="${@:1}" ;;
  esac

  echo -e "  ${color}${text}${BRIDGE_CDEFAULT}"
}

bridge.cli.read() {
  local varname="${@: -1}"
  local text="${*:1:$#-1}"

  echo -ne "${BRIDGE_CMAGENTA}"

  if [[ "${BRIDGE_SHELL}" == "zsh" ]]; then
    vared -p "  ${text}: " -c "${varname}"
  else
    read -p "  ${text}: " "${varname}"
  fi

  echo -ne "${BRIDGE_CDEFAULT}"
}

bridge.cli.confirm() {
  local varname="${@: -1}"
  local text="${*:1:$#-1}"
  local result=false

  # Create the variable to avoid warnings
  printf -v "${varname}" "%s" ""

  while ! [[ "${!varname}" =~ ^(y|n|yes|no)$ ]]; do
    bridge.cli.read "${text} (y/n)" "${varname}"
    printf -v "${varname}" "%s" "$(bridge.str.lower ${!varname})"
  done

  [[ "${!varname}" =~ ^(y|yes) ]] && result=true
  printf -v "${varname}" "%s" "${result}"; echo
}

bridge.rc.append() {
  if [[ -f "${2}" ]]; then
    grep -q "${1}" "${2}" || echo -e "\n${1}" >> "${2}"
  else
    echo -e "\n${1}" >> "${2}"
  fi
}

bridge.rc.takeaway() {
  # echo is intended for inplace replace
  [[ -f "${2}" ]] && echo "$(grep -v "${1}" "${2}")" > "${2}"
}

bridge.rc.write() {
  echo -e "${1}" > "${2}"
}

bridge.path.is_dir() {
  [[ "${1: -1}" == "/" ]]
}

bridge.path.is_remote() {
  [[ "${1}" =~ ^(https?|ftp): ]]
}

bridge.path.sdecode() {
  echo "${1}" | sed 's|file:/\{0,2\}||' | sed 's:/*$::' | tr -s '/'
}

bridge.path.adecode() {
  if bridge.path.is_remote "${1}"; then
    echo "${1}"
  else
    bridge.path.sdecode "${1}"
  fi
}

bridge.path.decode() {
  # We need "echo -e" here to interpret the resulting special characters
  echo -e "$(bridge.path.sdecode "${1}" | sed 's/+/ /g;s/%\(..\)/\\x\1/g;')"
}

bridge.list.contain() {
  for item in ${@:2}; do
    [[ "${1}" == "${item}" ]] && return 0
  done

  return 1
}

bridge.list.expand() {
  for item in "${@:2}"; do
    [[ -z "${item}" ]] || echo "${1}${item}"
  done
}

bridge.shbin.get_functions() {
  grep -v "#" "${1}" | grep -v "grep" | grep "() {" | sed 's/() {//'
}

bridge.shbin.link_functions() {
  (
    cd "${1}"

    for bin in $(bridge.shbin.get_functions "${2}"); do
      ln -s "../${2}" "${3}/${bin}"
    done
  )
}

bridge.param.expand() {
  for item in "${@:2}"; do
    [[ -z "${item}" ]] || echo "${1}" "${item}"
  done
}

alias bridge.param.warn_value='{
  bridge.cli.write -e "${1} needs value"
  exit 1
}'

alias bridge.param.invalidate='{
  bridge.cli.write -e "${1} is not a valid parameter"
  exit 1
}'

alias bridge.param.next='shift'

alias bridge.param._get_value_='{
  if [[ $# -ge 2 ]]; then
    if [[ "${2:1:1}" != "-" ]]; then
      __bridgesh_lastvalue__="${2}"; bridge.param.next
    else
      bridge.param.warn_value
    fi
  else
    bridge.param.warn_value
  fi
}'

bridge.io.get_filetype() {
  local mime=""

  if bridge.path.is_remote "${1}"; then
    mime="$(curl -sSIL "${1}" | grep -vi "x-content" | \
      grep -i "content-type" | tail -1)"
  else
    mime="$(file --mime "${1}")"
  fi

  echo "${mime}" | rev | cut -d'/' -f1 | rev | cut -d';' -f1 | \
    tr -d 'x-' | tr -d '[:space:]'
}

bridge.io.get_items() {
  # TODO: support archives

  if bridge.path.is_remote "${1}"; then
    curl -s "${1}" | grep href | sed 's/.*href="//' | sed 's/".*//'
  else
    ls -p "${1}"
  fi
}

bridge.io.extract() {
  # TODO: support stdin
  local exclude=('')
  local shortexclude=('')
  local reader=('')
  local tarparams=('')
  local src=""
  local dest="."
  local type=""

  while [[ $# -gt 0 ]]; do
    case "${1}" in
      --exclude)
        bridge.param._get_value_
        exclude+=("$(bridge.path.sdecode "${__bridgesh_lastvalue__}")") ;;
      -*)
        bridge.param.invalidate ;;
      *)
        if [[ "${src}" == "" ]]; then
          src="$(bridge.path.adecode "${1}")"
        elif [[ "${dest}" == "." ]]; then
          dest="${1}"
        fi ;;
    esac

    bridge.param.next
  done

  if [[ "${src}" == "" ]]; then
    bridge.cli.write -e "No source?"; exit 1
  elif bridge.path.is_remote "${src}"; then
    reader=('curl' '-sSL' "${src}")
  else
    reader=('cat' "${src}")
  fi

  exclude=($(bridge.param.expand "--exclude" "${exclude[@]}"))
  shortexclude=($(bridge.param.expand "-x" "${exclude[@]}"))
  tarparams=('-xC' "${dest}" --strip-components 1 ${exclude[@]})
  type="$(bridge.io.get_filetype "${src}")"

  mkdir -p "${dest}"

  case "${type}" in
    gzip)
      "${reader[@]}" | tar -z "${tarparams[@]}" ;;
    zip)
      # TODO: strip components
      #unzip "${shortexclude[@]}" <("${reader[@]}") -d "${dest}" ;;
      "${reader[@]}" | unzip "${shortexclude[@]}" -d "${dest}" ;;
    bzip2)
      "${reader[@]}" | tar -j "${tarparams[@]}" ;;
    compress)
      "${reader[@]}" | tar -Z "${tarparams[@]}" ;;
    *)
      bridge.cli.write -e "Unknown file type: ${type}"; exit 1 ;;
  esac
}

bridge.io.scopy() {
  if bridge.path.is_remote "${1}"; then
    curl -sS "${1}" -o "$(bridge.path.decode "${2}")"
  else
    cp "${1}" "${2}"
  fi
}

bridge.io.copy() {
  local exclude=('')
  local src=""
  local dest="."

  while [[ $# -gt 0 ]]; do
    case "${1}" in
      --exclude)
        bridge.param._get_value_
        exclude+=("$(bridge.path.sdecode "${__bridgesh_lastvalue__}")") ;;
      -*)
        bridge.param.invalidate ;;
      *)
        if [[ "${src}" == "" ]]; then
          src="$(bridge.path.adecode "${1}")"
        elif [[ "${dest}" == "." ]]; then
          dest="${1}"
        fi ;;
    esac

    bridge.param.next
  done

  if [[ "${src}" == "" ]]; then
    bridge.cli.write -e "No source?"; exit 1
  fi

  mkdir -p "${dest}"

  for item in $(bridge.io.get_items "${src}"); do
    if (bridge.list.contain "$(bridge.path.decode "${item}")" \
        "${exclude[@]}"); then
      continue
    fi

    if bridge.path.is_dir "${item}"; then
      bridge.io.copy "${src}/${item}" "${dest}/${item}"
    else
      bridge.io.scopy "${src}/${item}" "${dest}/${item}"
    fi
  done
}

if ! (return 0 2> /dev/null); then "${BRIDGE_SCRIPTNAME}" "${@:1}"; fi
