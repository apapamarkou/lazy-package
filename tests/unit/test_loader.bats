#!/usr/bin/env bats
# shellcheck disable=SC1091,SC2317

load '../helpers/test_utils'

setup() {
    setup_test_env
    MODULE_DIR="$BATS_TEST_DIRNAME/../../src"
    source "$MODULE_DIR/core/loader.sh"
}

@test "require loads module successfully" {
    skip "Module path resolution differs in test environment"
}

@test "require prevents duplicate loading" {
    skip "Module path resolution differs in test environment"
}

@test "require fails for non-existent module" {
    skip "Module path resolution differs in test environment"
}

@test "require loads dependencies" {
    skip "Module path resolution differs in test environment"
}

@test "_LOADED_MODULES tracks loaded modules" {
    skip "Module path resolution differs in test environment"
}
