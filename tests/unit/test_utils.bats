#!/usr/bin/env bats

load '../helpers/test_utils'
load '../helpers/mock_commands'

setup() {
    setup_test_env
    MODULE_DIR="$BATS_TEST_DIRNAME/../../src"
    source "$MODULE_DIR/core/loader.sh"
    require core/colors
    require core/utils

    # Stub packager functions so core/packager.sh doesn't run detection
    pkgType() { echo "pacman"; }
    is_installed() { [[ "$1" == "vim" ]]; }
    get_package_source() { echo "repo"; }
    export -f pkgType is_installed get_package_source
}

@test "format_package_line shows installed marker for installed package" {
    run format_package_line "vim" "repo" "1"
    assert_success
    assert_contains "$output" "[I]"
    assert_contains "$output" "vim"
}

@test "format_package_line shows not installed marker" {
    run format_package_line "vim" "repo" "0"
    assert_success
    assert_contains "$output" "[_]"
    assert_contains "$output" "vim"
}

@test "format_package_line shows repo label" {
    run format_package_line "vim" "repo" "0"
    assert_success
    assert_contains "$output" "[Rep]"
}

@test "format_package_line shows AUR label" {
    run format_package_line "yay" "aur" "0"
    assert_success
    assert_contains "$output" "[AUR]"
}
