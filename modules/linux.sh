#!/usr/bin/env bash
# Part of Bridge.sh, MIT-licensed
# Copyright (c) 2024 Zaalay Studio, Muhammad Rivan

sed() {
  local cmd=("${BRIDGE_BINDIR}/sed")

  while [[ $# -gt 0 ]]; do
    case "${1}" in
      -i)
        if [[ $# -ge 3 && ${2} == '-e' ]]; then
          cmd+=('-i' "${3}")
          shift 3
        elif [[ $# -ge 4 && ${2} == '' && ${3} == '-e' ]]; then
          cmd+=('-i' "${4}")
          shift 4
        else
          cmd+=("${1}")
          shift
        fi
        ;;
      *)
        cmd+=("${1}")
        shift
        ;;
    esac
  done

  echo "${cmd[@]}"
  "${cmd[@]}"
}

if ! (return 0 2> /dev/null); then
  source "$(dirname "$(dirname "${0}")")/modules/core.sh" "full"
  "${BRIDGE_SCRIPTNAME}" "${@:1}"
fi
