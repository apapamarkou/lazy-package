#!/usr/bin/env bats
# shellcheck disable=SC1091,SC2317
# Unit tests for cache module

setup() {
    export CACHE_DIR="$BATS_TEST_TMPDIR/cache"
    export CACHE_FILE="$CACHE_DIR/packages.ndjson"
    export CACHE_MAX_AGE=86400
    
    MODULE_DIR="$BATS_TEST_DIRNAME/../../src"
    source "$MODULE_DIR/core/loader.sh"
    require cache/cache
}

teardown() {
    rm -rf "$BATS_TEST_TMPDIR/cache"
}

@test "cache_needs_rebuild returns true when cache missing" {
    run cache_needs_rebuild
    [ "$status" -eq 0 ]
}

@test "cache_needs_rebuild returns false when cache fresh" {
    mkdir -p "$CACHE_DIR"
    touch "$CACHE_FILE"
    run cache_needs_rebuild
    [ "$status" -eq 1 ]
}

@test "search_cache finds packages" {
    mkdir -p "$CACHE_DIR"
    cat > "$CACHE_FILE" << EOF
{"name":"vim","source":"repo"}
{"name":"neovim","source":"repo"}
EOF
    
    run search_cache "vim"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "vim" ]]
}
