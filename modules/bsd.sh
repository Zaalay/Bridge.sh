#!/usr/bin/env bash
# Part of Bridge.sh, MIT-licensed
# Copyright (c) 2022 Zaalay Studio, Muhammad Rivan

if ! (return 0 2> /dev/null); then
  source "$(dirname "$(dirname "${0}")")/modules/core.sh" "full"
  "${BRIDGE_SCRIPTNAME}" "${@:1}"
fi
