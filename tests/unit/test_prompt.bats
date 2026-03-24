#!/usr/bin/env bats

load '../helpers/test_utils'

setup() {
    setup_test_env
    MODULE_DIR="$BATS_TEST_DIRNAME/../../src"
    source "$MODULE_DIR/core/loader.sh"
    require core/prompt
}

@test "ask_yn returns true for Y" {
    echo "Y" | run ask_yn "Test? (Y/N): "
    assert_success
}

@test "ask_yn returns true for y" {
    echo "y" | run ask_yn "Test? (Y/N): "
    assert_success
}

@test "ask_yn returns false for N" {
    echo "N" | run ask_yn "Test? (Y/N): "
    assert_failure
}

@test "ask_yn returns false for n" {
    echo "n" | run ask_yn "Test? (Y/N): "
    assert_failure
}

@test "ask_yn returns false for other input" {
    echo "x" | run ask_yn "Test? (Y/N): "
    assert_failure
}
