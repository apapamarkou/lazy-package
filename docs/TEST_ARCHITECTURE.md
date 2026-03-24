# Test Architecture Proposal for lazy-pacman

## Overview

Comprehensive testing strategy for a Bash-based package manager wrapper with modular architecture.

## Test Layers

### 1. Unit Tests (tests/unit/)
Test individual functions in isolation with mocked dependencies.

**Coverage:**
- `core/utils.sh` - format_package_line, is_installed, get_package_source
- `core/loader.sh` - require function, duplicate prevention
- `core/prompt.sh` - ask_yn function
- `cache/cache.sh` - cache_needs_rebuild, build_cache, search_cache
- `cli/parser.sh` - command parsing logic
- `system/dependencies.sh` - dependency checking

**Approach:**
- Mock pacman/yay commands
- Test with fake package data
- Verify output formatting
- Test edge cases (empty input, special characters)

### 2. Integration Tests (tests/integration/)
Test module interactions and data flow.

**Coverage:**
- Cache → CLI search pipeline
- CLI commands → pacman operations
- TUI → preview generation
- Module loader → all modules
- Install/remove workflows

**Approach:**
- Use test fixtures (sample cache files)
- Mock system commands
- Verify module communication
- Test error propagation

### 3. Functional Tests (tests/functional/)
Test complete user workflows end-to-end.

**Coverage:**
- CLI: `pkg search`, `pkg install`, `pkg info`
- TUI: launch, navigation, package selection
- Cache rebuild scenarios
- Update checking
- Orphan cleaning

**Approach:**
- Use Docker container with Arch Linux
- Test against real pacman database
- Verify actual file operations
- Test user interaction flows

### 4. Performance Tests (tests/performance/)
Validate performance requirements.

**Coverage:**
- Cache build time (<10 seconds)
- Startup time (<1 second)
- Search performance (100k packages)
- Memory usage (<20 MB)
- Preview generation latency (<200ms)

**Approach:**
- Benchmark with large datasets
- Profile memory usage
- Measure response times
- Compare against baselines

## Test Structure

```
tests/
├── unit/
│   ├── test_utils.sh
│   ├── test_cache.sh
│   ├── test_loader.sh
│   ├── test_parser.sh
│   └── test_prompt.sh
├── integration/
│   ├── test_cli_workflow.sh
│   ├── test_cache_pipeline.sh
│   ├── test_module_loading.sh
│   └── test_preview_generation.sh
├── functional/
│   ├── test_cli_commands.sh
│   ├── test_tui_navigation.sh
│   ├── test_install_remove.sh
│   └── test_search_paging.sh
├── performance/
│   ├── test_cache_build.sh
│   ├── test_startup_time.sh
│   └── test_memory_usage.sh
├── fixtures/
│   ├── sample_cache.ndjson
│   ├── mock_pacman_output.txt
│   └── test_packages.txt
├── helpers/
│   ├── mock_commands.sh
│   ├── assertions.sh
│   └── test_utils.sh
└── run_all_tests.sh
```

## Test Framework

### Bash Testing Framework: bats-core

**Why bats-core:**
- Native Bash testing
- Simple syntax
- Good assertion library
- TAP output format
- CI/CD friendly

**Installation:**
```bash
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local
```

### Alternative: shunit2
Lightweight, no dependencies, pure Bash.

## Mock Strategy

### Mock Commands (tests/helpers/mock_commands.sh)
```bash
# Mock pacman
pacman() {
    case "$1" in
        -Q) cat "$TEST_FIXTURES/installed.txt" ;;
        -Si) cat "$TEST_FIXTURES/package_info.txt" ;;
        -Slq) cat "$TEST_FIXTURES/repo_packages.txt" ;;
    esac
}

# Mock yay
yay() {
    case "$1" in
        -Slq) cat "$TEST_FIXTURES/aur_packages.txt" ;;
    esac
}
```

## Assertion Library (tests/helpers/assertions.sh)

```bash
assert_equals() {
    local expected="$1"
    local actual="$2"
    [[ "$expected" == "$actual" ]] || {
        echo "FAIL: Expected '$expected', got '$actual'"
        return 1
    }
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    [[ "$haystack" =~ $needle ]] || {
        echo "FAIL: '$haystack' does not contain '$needle'"
        return 1
    }
}

assert_file_exists() {
    [[ -f "$1" ]] || {
        echo "FAIL: File '$1' does not exist"
        return 1
    }
}
```

## CI/CD Integration

### GitHub Actions (.github/workflows/test.yml)
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    container: archlinux:latest
    steps:
      - uses: actions/checkout@v2
      - name: Install dependencies
        run: pacman -Syu --noconfirm fzf jq curl bats
      - name: Run unit tests
        run: ./tests/run_all_tests.sh unit
      - name: Run integration tests
        run: ./tests/run_all_tests.sh integration
```

## Test Coverage Goals

- **Unit tests**: 80% function coverage
- **Integration tests**: All module interactions
- **Functional tests**: All CLI commands and TUI flows
- **Performance tests**: All benchmarks pass

## Priority Test Cases

### High Priority
1. Cache build and search
2. CLI install/remove commands
3. Module loader functionality
4. Package formatting with colors
5. Error handling

### Medium Priority
1. TUI navigation
2. Preview generation
3. Update checking
4. Orphan cleaning
5. PKGBUILD preview

### Low Priority
1. Edge cases (special characters)
2. Performance edge cases
3. Rare error conditions

## Test Execution

```bash
# Run all tests
./tests/run_all_tests.sh

# Run specific layer
./tests/run_all_tests.sh unit
./tests/run_all_tests.sh integration
./tests/run_all_tests.sh functional
./tests/run_all_tests.sh performance

# Run specific test file
bats tests/unit/test_cache.sh

# Run with verbose output
bats -t tests/unit/test_cache.sh
```

## Continuous Improvement

1. Add tests for each bug fix
2. Increase coverage incrementally
3. Profile and optimize slow tests
4. Update fixtures with real-world data
5. Monitor test execution time

## Benefits

- **Confidence**: Safe refactoring
- **Documentation**: Tests as examples
- **Quality**: Catch regressions early
- **Speed**: Fast feedback loop
- **Maintainability**: Clear test structure
