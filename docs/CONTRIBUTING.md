# Contributing to lazy-package

Thank you for your interest in contributing!

## Development Setup

```bash
git clone https://github.com/apapamarkou/lazy-package.git
cd lazy-package
make link       # creates ./pkg symlink for direct run without installing
./pkg           # run directly from the repo
```

To install system-wide:
```bash
make install
```

## Project Structure

```
src/
├── pkg                  # Main entry point
├── core/                # Loader, config, colors, utils, packager abstraction
├── packagers/           # Per-distro backends: pacman, apt, dnf, zypper
├── cache/               # Package cache management
├── cli/                 # CLI parser and commands
├── tui/                 # fzf TUI, preview, actions
└── system/              # Updates, orphans, dependency checking
tests/
├── unit/                # Unit tests (bats)
├── integration/         # Integration tests (bats)
├── performance/         # Performance benchmarks (bats)
└── helpers/             # Shared mocks and assertions
```

## Supported Packagers

| Distro | Packager |
|--------|----------|
| Arch Linux | pacman + yay |
| Debian/Ubuntu | apt |
| Fedora/RHEL | dnf |
| openSUSE | zypper |

When adding a feature, implement the corresponding function in **all four** backends.

## Coding Standards

- `set -euo pipefail` in all scripts
- Use the `require` module loader for imports
- Keep functions small and single-purpose
- No comments unless logic is non-obvious

## Testing

```bash
make test                              # Run full test suite
bats tests/unit/test_packager.bats     # Run a single file
```

Tests run against all supported distros in CI via a matrix build.

## Submitting Changes

1. Fork the repository
2. Create a feature branch
3. Implement changes in all relevant backends
4. Run `make test` and ensure tests pass
5. Submit a pull request

## Reporting Issues

Please include:
- Your distro and version
- Steps to reproduce
- Expected vs actual behavior
- Error messages if any
