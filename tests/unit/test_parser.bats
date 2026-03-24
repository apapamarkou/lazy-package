#!/usr/bin/env bats
# shellcheck disable=SC1091,SC2317
    require cli/help

    cli_install() { echo "install $*"; }
    cli_remove() { echo "remove $*"; }
    cli_search() { echo "search $*"; }
    cli_update() { echo "update"; }
    cli_clean_orphans() { echo "clean_orphans"; }
    cli_info() { echo "info $*"; }
    export -f cli_install cli_remove cli_search cli_update cli_clean_orphans cli_info
}

@test "parse_cli handles install command" {
    run parse_cli install vim
    assert_success
    assert_contains "$output" "install vim"
}

@test "parse_cli handles install short form" {
    run parse_cli i vim
    assert_success
    assert_contains "$output" "install vim"
}

@test "parse_cli handles remove command" {
    run parse_cli remove vim
    assert_success
    assert_contains "$output" "remove vim"
}

@test "parse_cli handles search command" {
    run parse_cli search firefox
    assert_success
    assert_contains "$output" "search firefox"
}

@test "parse_cli handles info command" {
    run parse_cli info vim
    assert_success
    assert_contains "$output" "info vim"
}

@test "parse_cli handles update command" {
    run parse_cli update
    assert_success
    assert_contains "$output" "update"
}

@test "parse_cli handles help command" {
    run parse_cli help
    assert_success
    [[ "$output" =~ "pkg" ]]
}

@test "parse_cli fails on unknown command" {
    run parse_cli unknown
    assert_failure
    assert_contains "$output" "Unknown command"
}
