# lazy-package - Project Overview

## Architecture

This project follows a **modular Bash architecture** with a custom module loader system.

### Module System

The `core/loader.sh` implements a `require()` function that:
- Loads modules by name (e.g., `require core/config`)
- Prevents duplicate imports using an associative array
- Provides clear error messages for missing modules

### Module Organization

```
src/
├── pkg                    # Main entry point
├── core/                  # Core functionality
│   ├── loader.sh         # Module loader
│   ├── config.sh         # Configuration constants
│   ├── colors.sh         # ANSI color codes
│   ├── utils.sh          # Utility functions (format_package_line)
│   ├── prompt.sh         # User prompts
│   └── packager.sh       # Packager abstraction + dispatcher
├── packagers/             # Per-packager backends
│   ├── pacman.sh         # pacman + yay (Arch Linux)
│   ├── apt.sh            # apt-get (Debian/Ubuntu)
│   ├── dnf.sh            # dnf (Fedora/RHEL)
│   └── zypper.sh         # zypper (openSUSE)
├── cache/                 # Caching system
│   └── cache.sh          # Package cache management
├── cli/                   # CLI interface
│   ├── parser.sh         # Argument parser
│   ├── commands.sh       # Command implementations
│   └── help.sh           # Help text
├── tui/                   # TUI interface
│   ├── tui.sh            # Main TUI launcher (shows active packager)
│   ├── preview.sh        # Preview generation
│   └── actions.sh        # User actions
└── system/                # System operations
    ├── dependencies.sh   # Dependency checking (per packager)
    ├── updates.sh        # Update management
    └── orphan_cleaner.sh # Orphan removal
```

## Packager Abstraction

### `pkgType()`
Detects the active package manager by checking for binaries in order:
`pacman` → `apt-get` → `dnf` → `zypper`

Returns: `pacman`, `apt`, `dnf`, `zypper`, or `unknown`

### Wrapper Functions (in `core/packager.sh`)
All action functions dispatch to the active backend:

| Wrapper | Pacman | APT | DNF | Zypper |
|---------|--------|-----|-----|--------|
| `install_package` | `pacmanInstall` | `aptInstall` | `dnfInstall` | `zypperInstall` |
| `remove_package` | `pacmanRemove` | `aptRemove` | `dnfRemove` | `zypperRemove` |
| `update_packages` | `pacmanUpdate` | `aptUpdate` | `dnfUpdate` | `zypperUpdate` |
| `get_package_info` | `pacmanInfo` | `aptInfo` | `dnfInfo` | `zypperInfo` |
| `get_package_deps` | `pacmanGetDeps` | `aptGetDeps` | `dnfGetDeps` | `zypperGetDeps` |
| `is_installed` | `pacmanIsInstalled` | `aptIsInstalled` | `dnfIsInstalled` | `zypperIsInstalled` |
| `clean_orphans` | `pacmanCleanOrphans` | `aptCleanOrphans` | `dnfCleanOrphans` | `zypperCleanOrphans` |
| `check_updates` | `pacmanCheckUpdates` | `aptCheckUpdates` | `dnfCheckUpdates` | `zypperCheckUpdates` |

### Unsupported Platform
If no supported packager is found, `notify-send` is called and the program exits.

## Key Features

### 1. Minimal Cache + Lazy Preview
- **Minimal cache**: Only package names and sources (~3 MB for 100k packages)
- **Lazy preview**: Dependencies and metadata fetched on-demand
- **Fast startup**: < 1 second even with massive package lists
- Package cache: `~/.cache/lazy-package/packages.ndjson` (rebuilt daily)
- Update cache: `~/.cache/lazy-package/update_check` (6 hour interval)

### 2. Dependency Checking
- Detects packager at startup
- Checks common deps (`fzf`, `jq`, `curl`) + packager-specific deps
- Offers to install missing deps with a single keypress
- On refusal: `notify-send` + exit

### 3. TUI Packager Label
The fzf header shows the active packager: `lazy-package [PACMAN]`, `lazy-package [APT]`, etc.

### 4. Desktop Integration
The installer creates `~/.local/share/applications/lazy-package.desktop` for launcher integration.

## Installation Methods

1. **Local**: `./install` (creates symlink + .desktop file)
2. **Remote**: `curl -fsSL <url>/install | bash` (clones repo)

## Dependencies

Common: `fzf`, `jq`, `curl`
- pacman: `pacman`, `yay`
- apt: `apt-get`
- dnf: `dnf`
- zypper: `zypper`
