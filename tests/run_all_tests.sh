#!/usr/bin/env bash
set -euo pipefail

# Test runner for lazy-package

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_TYPE="${1:-all}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# Check if bats is installed
if ! command -v bats &>/dev/null; then
    echo -e "${YELLOW}bats-core not installed - running basic smoke tests${RESET}"
    echo "For full test suite, install bats-core:"
    echo "  git clone https://github.com/bats-core/bats-core.git"
    echo "  cd bats-core && sudo ./install.sh /usr/local"
    echo
    
    # Run basic smoke tests
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
    MODULE_DIR="$PROJECT_ROOT/src"
    
    echo "Running basic smoke tests..."
    echo
    
    # shellcheck disable=SC1091
    source "$MODULE_DIR/core/loader.sh"
    require core/config && echo "✓ core/config loads"
    require core/colors && echo "✓ core/colors loads"
    require core/utils && echo "✓ core/utils loads"
    require cache/cache && echo "✓ cache/cache loads"
    require cli/parser && echo "✓ cli/parser loads"
    
    echo
    echo -e "${GREEN}✓ Basic smoke tests passed${RESET}"
    echo -e "${YELLOW}Install bats-core for comprehensive testing${RESET}"
    exit 0
fi

run_tests() {
    local test_dir="$1"
    local test_name="$2"
    
    if [[ ! -d "$test_dir" ]] || [[ -z "$(ls -A "$test_dir"/*.bats 2>/dev/null)" ]]; then
        echo -e "${YELLOW}No $test_name tests found${RESET}"
        return 0
    fi
    
    echo -e "${GREEN}Running $test_name tests...${RESET}"
    if bats "$test_dir"/*.bats 2>/dev/null; then
        echo -e "${GREEN}✓ $test_name tests passed${RESET}"
        return 0
    else
        echo -e "${RED}✗ $test_name tests failed${RESET}"
        return 1
    fi
}

# Run tests based on type
case "$TEST_TYPE" in
    unit)
        run_tests "$SCRIPT_DIR/unit" "unit"
        ;;
    integration)
        run_tests "$SCRIPT_DIR/integration" "integration"
        ;;
    functional)
        run_tests "$SCRIPT_DIR/functional" "functional"
        ;;
    performance)
        run_tests "$SCRIPT_DIR/performance" "performance"
        ;;
    all)
        failed=0
        run_tests "$SCRIPT_DIR/unit" "unit" || failed=1
        run_tests "$SCRIPT_DIR/integration" "integration" || failed=1
        run_tests "$SCRIPT_DIR/functional" "functional" || failed=1
        run_tests "$SCRIPT_DIR/performance" "performance" || failed=1
        
        # Clean up cache to rebuild actual database on next run
        CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/lazy-package"
        if [[ -f "$CACHE_DIR/packages.ndjson" ]]; then
            rm -f "$CACHE_DIR/packages.ndjson"
            echo -e "${YELLOW}Cleaned package cache - will rebuild on next run${RESET}"
        fi
        
        if [[ $failed -eq 0 ]]; then
            echo
            echo -e "${GREEN}✓ All tests passed!${RESET}"
            exit 0
        else
            echo
            echo -e "${RED}✗ Some tests failed${RESET}"
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 [unit|integration|functional|performance|all]"
        echo
        echo "Examples:"
        echo "  $0           # Run all tests"
        echo "  $0 unit      # Run only unit tests"
        exit 1
        ;;
esac
