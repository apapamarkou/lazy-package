#!/usr/bin/env bats

load '../helpers/test_utils'

setup() {
    setup_test_env
    MODULE_DIR="$BATS_TEST_DIRNAME/../../src"
    source "$MODULE_DIR/core/loader.sh"
    require core/config
    require cache/cache
}

@test "cache build completes in reasonable time" {
    # Mock with 1000 packages
    pacman() {
        [[ "$1" == "-Slq" ]] && seq 1 1000 | sed 's/^/package/'
    }
    yay() {
        [[ "$1" == "-Slq" ]] && seq 1 100 | sed 's/^/aur-package/'
    }
    export -f pacman yay
    
    start=$(date +%s%N)
    build_cache
    end=$(date +%s%N)
    
    duration=$(( (end - start) / 1000000 ))  # Convert to ms
    
    # Should complete in under 5 seconds (5000ms)
    [ "$duration" -lt 5000 ]
}

@test "search performance on large cache" {
    # Create large cache
    mkdir -p "$CACHE_DIR"
    for i in {1..10000}; do
        echo "{\"name\":\"package$i\",\"source\":\"repo\"}" >> "$CACHE_FILE"
    done
    
    start=$(date +%s%N)
    search_cache "package5000" > /dev/null
    end=$(date +%s%N)
    
    duration=$(( (end - start) / 1000000 ))
    
    # Should complete in under 500ms
    [ "$duration" -lt 500 ]
}

@test "get_all_packages streams efficiently" {
    # Create cache with 5000 packages
    mkdir -p "$CACHE_DIR"
    for i in {1..5000}; do
        echo "{\"name\":\"package$i\",\"source\":\"repo\"}" >> "$CACHE_FILE"
    done
    
    start=$(date +%s%N)
    count=$(get_all_packages | wc -l)
    end=$(date +%s%N)
    
    duration=$(( (end - start) / 1000000 ))
    
    # Allow for whitespace/empty lines
    [ "$count" -ge 5000 ]
    # Should complete in under 1 second (1000ms)
    [ "$duration" -lt 1000 ]
}

@test "cache file size is minimal" {
    pacman() {
        [[ "$1" == "-Slq" ]] && seq 1 100 | sed 's/^/package/'
    }
    yay() {
        [[ "$1" == "-Slq" ]] && seq 1 10 | sed 's/^/aur-package/'
    }
    export -f pacman yay
    
    build_cache
    
    size=$(stat -f%z "$CACHE_FILE" 2>/dev/null || stat -c%s "$CACHE_FILE")
    
    # 110 packages should be under 5KB
    [ "$size" -lt 5120 ]
}
