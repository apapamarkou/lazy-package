#!/usr/bin/env bats
# shellcheck disable=SC1091,SC2317

load '../helpers/test_utils'

setup() {
    setup_test_env
    export MODULE_DIR="$BATS_TEST_DIRNAME/../../src"
    source "$MODULE_DIR/core/loader.sh"
    require core/prompt
}

@test "ask_yn returns true for Y" {
    run bash -c "source \"$MODULE_DIR/core/loader.sh\"; require core/prompt; echo Y | ask_yn 'Test?'"
    assert_success
}

@test "ask_yn returns true for y" {
    run bash -c "source \"$MODULE_DIR/core/loader.sh\"; require core/prompt; echo y | ask_yn 'Test?'"
    assert_success
}

@test "ask_yn returns false for N" {
    run bash -c "source \"$MODULE_DIR/core/loader.sh\"; require core/prompt; echo N | ask_yn 'Test?'"
    assert_failure
}

@test "ask_yn returns false for n" {
    run bash -c "source \"$MODULE_DIR/core/loader.sh\"; require core/prompt; echo n | ask_yn 'Test?'"
    assert_failure
}

@test "ask_yn returns false for other input" {
    run bash -c "source \"$MODULE_DIR/core/loader.sh\"; require core/prompt; echo x | ask_yn 'Test?'"
    assert_failure
}
