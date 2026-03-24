[![Release](https://img.shields.io/github/v/release/apapamarkou/lazy-package?style=for-the-badge)](https://github.com/apapamarkou/lazy-package/releases)
[![License](https://img.shields.io/github/license/apapamarkou/lazy-package?style=for-the-badge)](LICENSE)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/andrianos)

# lazy-package

Fast TUI + CLI package manager wrapper for Linux.
Supports **pacman/yay** (Arch), **apt** (Debian/Ubuntu), **dnf** (Fedora/RHEL), **zypper** (openSUSE).

> Every Linux distro ships with a different package manager, each with its own commands, flags, and quirks.
> lazy-package aims to unify that experience — one interface, one set of commands, regardless of your distro.

<img width="70%" alt="pkg" src="https://github.com/user-attachments/assets/94aa9b68-ecae-43ee-9f43-d9e716ea4d82" />

## Features

- **Multi-packager** — Auto-detects pacman, apt, dnf, or zypper
- **Interactive TUI** — Browse and manage packages with a beautiful terminal interface
- **Fast CLI** — Quick commands for common operations with multi-package support
- **Minimal Cache** — Lightweight cache (name + source only) for instant startup
- **Lazy Preview** — Package details loaded on-demand for optimal performance
- **Colored Preview** — Syntax-highlighted package info with dependency tree visualization
- **AUR Support** — Seamless yay integration (pacman only)
- **Dependency Warnings** — Shows reverse dependencies before removal
- **Update Notifications** — Lazy update checking every 6 hours
- **Orphan Cleaning** — Easy removal of unused dependencies
- **PKGBUILD Preview** — Inspect AUR build scripts before installation (pacman only)
- **Smart Paging** — Automatic pager for long search results
- **Desktop Entry** — `.desktop` file created on install for launcher integration

## Installation

### Quick Install (curl)

```bash
curl -fsSL https://raw.githubusercontent.com/apapamarkou/lazy-package/main/install | bash
```

### Manual Install

```bash
git clone https://github.com/apapamarkou/lazy-package.git
cd lazy-package
make install
```

The installer automatically adds `~/.local/bin` to your PATH if needed.

### Try Without Installing

```bash
git clone https://github.com/apapamarkou/lazy-package.git
cd lazy-package
export PATH="$PWD:$PATH"
pkg
```

### Development (no install)

```bash
git clone https://github.com/apapamarkou/lazy-package.git
cd lazy-package
make link   # creates ./pkg symlink
./pkg
```

## Dependencies

Common (all distros):
- `fzf` — Fuzzy finder
- `jq` — JSON processor
- `curl` — HTTP client

Per packager:
- **pacman**: `pacman`, `yay`
- **apt**: `apt-get` (pre-installed on Debian/Ubuntu)
- **dnf**: `dnf` (pre-installed on Fedora)
- **zypper**: `zypper` (pre-installed on openSUSE)

Optional:
- `most` — Pager (falls back to `less`)
- `pacman-contrib` — Dependency tree visualization (pacman only)

Missing dependencies are detected at startup and you will be prompted to install them.

## Usage

### Interactive TUI

```bash
pkg
```

The TUI header shows the active package manager (e.g. `lazy-package [PACMAN]`).

### CLI Commands

```bash
pkg install <package>...       # Install one or more packages
pkg i <package>...             # Short form

pkg remove <package>...        # Remove one or more packages
pkg r <package>...             # Short form

pkg info <package>             # Show package information

pkg search <term>              # Search packages (auto-paged if >24 results)
pkg s <term>                   # Short form

pkg search-names-only <term>   # Search names only
pkg sno <term>                 # Short form

pkg update                     # Update system
pkg u                          # Short form

pkg clean-orphans              # Remove orphan packages
pkg co                         # Short form

pkg help                       # Show help
pkg h                          # Short form
```

## TUI Key Bindings

| Key | Action |
|-----|--------|
| `Enter` | Install/remove selected package |
| `Ctrl+U` | System update |
| `Ctrl+O` | Clean orphan packages |
| `Ctrl+B` | Preview PKGBUILD (pacman/AUR only) |
| `Ctrl+Q` / `ESC` | Exit |

## Examples

```bash
pkg install neovim
pkg install vim git curl htop
pkg info firefox
pkg search firefox
pkg update
pkg
```

## Performance

lazy-package uses a **minimal cache + lazy preview** architecture:

- **Minimal cache**: Only package names and sources stored (~3 MB)
- **Lazy preview**: Dependencies and metadata fetched on-demand when selected
- **Fast startup**: < 1 second even with 100k+ packages

Cache locations:
- Package cache: `~/.cache/lazy-package/packages.ndjson` (rebuilt daily)
- Update cache: `~/.cache/lazy-package/update_check` (6 hour interval)

## Uninstall

```bash
./uninstall
```

Or manually:

```bash
rm ~/.local/bin/pkg
rm -f ~/.local/share/applications/lazy-package.desktop
rm -rf ~/.cache/lazy-package
rm -rf ~/.local/share/lazy-package
```

## License

GPL-3.0

## Contributing

Contributions welcome! Please open an issue or pull request.

<a href="https://buymeacoffee.com/andrianos" target="_blank">
  <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png"
       alt="Buy Me A Coffee"
       style="height: 60px !important;width: 217px !important;" >
</a>
