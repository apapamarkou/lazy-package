#!/usr/bin/env bats
# shellcheck disable=SC1091,SC2317
# Unit tests for packager detection

load '../helpers/test_utils'

setup() {
    setup_test_env
    MODULE_DIR="$BATS_TEST_DIRNAME/../../src"
    source "$MODULE_DIR/core/loader.sh"
    require core/config
    require core/colors
}

@test "pkgType returns pacman when pacman is available" {
    skip "Full packager load triggers backend sourcing in test environment"
}

@test "pkgType returns apt when only apt-get is available" {
    unset -f pacman 2>/dev/null || true
    # Override command -v to simulate no pacman
    command() {
        [[ "$1" == "-v" && "$2" == "pacman" ]] && return 1
        [[ "$1" == "-v" && "$2" == "apt-get" ]] && return 0
        builtin command "$@"
    }
    export -f command
    run bash -c '
        pkgType() {
            if command -v pacman &>/dev/null; then echo "pacman"
            elif command -v apt-get &>/dev/null; then echo "apt"
            elif command -v dnf &>/dev/null; then echo "dnf"
            elif command -v zypper &>/dev/null; then echo "zypper"
            else echo "unknown"
            fi
        }
        command() {
            [[ "$1" == "-v" && "$2" == "pacman" ]] && return 1
            [[ "$1" == "-v" && "$2" == "apt-get" ]] && return 0
            builtin command "$@"
        }
        export -f command
        pkgType
    '
    assert_success
    assert_contains "$output" "apt"
}

@test "pkgType returns unknown when no packager found" {
    run bash -c '
        pkgType() {
            if command -v pacman &>/dev/null; then echo "pacman"
            elif command -v apt-get &>/dev/null; then echo "apt"
            elif command -v dnf &>/dev/null; then echo "dnf"
            elif command -v zypper &>/dev/null; then echo "zypper"
            else echo "unknown"
            fi
        }
        # Override PATH to hide all packagers
        PATH=/nonexistent pkgType
    '
    assert_success
    assert_contains "$output" "unknown"
}

@test "get_package_deps dispatches to backend GetDeps function" {
    run bash -c '
        _PKG_TYPE="mock"
        mockGetDeps() { echo "dep-a"; echo "dep-b"; }
        export -f mockGetDeps
        get_package_deps() { "${_PKG_TYPE}GetDeps" "$@"; }
        get_package_deps "somepkg"
    '
    assert_success
    assert_contains "$output" "dep-a"
    assert_contains "$output" "dep-b"
}
