#!/usr/bin/env bats

load '../helpers/test_utils'
load '../helpers/mock_commands'

setup() {
    setup_test_env
    MODULE_DIR="$BATS_TEST_DIRNAME/../../src"
    source "$MODULE_DIR/core/loader.sh"
    require core/config
    require core/colors
    require core/utils
    require cache/cache
}

@test "cache build and search integration" {
    # Mock commands
    pacman() {
        [[ "$1" == "-Slq" ]] && echo -e "vim\nneovim\ngit"
    }
    yay() {
        [[ "$1" == "-Slq" ]] && echo -e "yay\nparu"
    }
    export -f pacman yay
    
    # Build cache
    run build_cache
    assert_success
    assert_file_exists "$CACHE_FILE"
    
    # Search cache
    run search_cache "vim"
    assert_success
    assert_contains "$output" "vim"
}

@test "cache rebuild on old cache" {
    # Create old cache
    mkdir -p "$CACHE_DIR"
    touch -d "2 days ago" "$CACHE_FILE"
    
    run cache_needs_rebuild
    assert_success
}

@test "get_all_packages returns formatted output" {
    create_sample_cache
    
    run get_all_packages
    assert_success
    assert_contains "$output" "vim repo"
    assert_contains "$output" "yay aur"
}

@test "search with installed status" {
    create_sample_cache
    
    pacman() {
        [[ "$1" == "-Qq" ]] && echo -e "vim\ngit"
    }
    export -f pacman
    
    # Search and format
    result=$(search_cache "vim" | while read -r pkg source; do
        is_installed=$(pacman -Q "$pkg" &>/dev/null && echo "1" || echo "0")
        format_package_line "$pkg" "$source" "$is_installed"
    done)
    
    assert_contains "$result" "vim"
}
