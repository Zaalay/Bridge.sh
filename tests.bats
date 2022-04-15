#!/usr/bin/env bats
# Part of Bridge.sh, MIT-licensed
# Copyright (c) 2022 Zaalay Studio, Muhammad Rivan

@test "Can install Bridge.sh in standard way" {
    ./install.sh
}

@test "Can install Bridge.sh locally" {
    ./install.sh -t
}
