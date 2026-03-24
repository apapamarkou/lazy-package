# lazy-package - Quick Reference

## Installation
```bash
# Remote (auto-installs git if needed)
curl -fsSL https://raw.githubusercontent.com/apapamarkou/lazy-package/main/install | bash

# Local
git clone https://github.com/apapamarkou/lazy-package.git && cd lazy-package && ./install
```

## CLI Commands
```bash
pkg                    # Launch TUI
pkg i <pkg>...         # Install package(s)
pkg r <pkg>...         # Remove package(s)
pkg info <pkg>         # Show package info
pkg s <term>           # Search (auto-paged if >24)
pkg sno <term>         # Search names only
pkg u                  # Update system
pkg co                 # Clean orphans
pkg h                  # Help
```

## TUI Keys
```
Enter      Install/remove
Ctrl+U     Update
Ctrl+O     Clean orphans
Ctrl+B     Preview PKGBUILD (pacman/AUR only)
Ctrl+Q     Quit
ESC        Quit
```

## Files
```
~/.local/bin/pkg                           # Executable
~/.cache/lazy-package/packages.ndjson      # Package cache (24h)
~/.cache/lazy-package/update_check         # Update cache (6h)
~/.local/share/applications/lazy-package.desktop  # Desktop entry
```

## Module Structure
```
require core/config           # Load config
require cache/cache           # Load cache functions
require cli/parser            # Load CLI parser
```

## Development
```bash
./tests/run_tests.sh          # Run tests
./uninstall                   # Uninstall
```
