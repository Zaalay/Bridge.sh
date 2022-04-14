#!/usr/bin/env bash
# Part of Bridge.sh, MIT-licensed
# Copyright (c) 2022 Zaalay Studio, Muhammad Rivan

sed() {
  local cmd=("${BRIDGESH_BINDIR}/sed")

  while [[ $# -gt 0 ]]; do
    case "${1}" in
      -i)
        if [[ $# -ge 3 && ${2} == '-e' ]]; then
          cmd+=('-i' '' '-e' "${3}")
          shift 3
        elif [[ $# -ge 2 && ${2:0:1} == 's' ]]; then
          cmd+=('-i' '' '-e' "${2}")
          shift 2
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
  source "${BRIDGESH_DIR}/modules/core.sh"
  "${BRIDGESH_SCRIPTNAME}" "${@:1}"
fi
