#!/usr/bin/env bash
# Test utilities and assertions for bats

setup_test_env() {
    export TEST_DIR="$BATS_TEST_TMPDIR"
    export CACHE_DIR="$TEST_DIR/cache"
    export CACHE_FILE="$CACHE_DIR/packages.ndjson"
    export UPDATE_CHECK_FILE="$CACHE_DIR/update_check"
    export CACHE_MAX_AGE=86400
    export UPDATE_CHECK_INTERVAL=21600
    mkdir -p "$CACHE_DIR"
}

create_sample_cache() {
    mkdir -p "$CACHE_DIR"
    cat > "$CACHE_FILE" << 'EOF'
{"name":"vim","source":"repo"}
{"name":"neovim","source":"repo"}
{"name":"git","source":"repo"}
{"name":"yay","source":"aur"}
EOF
}

assert_contains() { [[ "$1" =~ $2 ]]; }
assert_file_exists() { [[ -f "$1" ]]; }
assert_success() { [ "${status:-0}" -eq 0 ]; }
assert_failure() { [ "${status:-1}" -ne 0 ]; }
