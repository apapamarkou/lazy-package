#!/usr/bin/env bash

#  _                      ____            _                    
# | |    __ _ _____   _  |  _ \ __ _  ___| | ____ _  __ _  ___ 
# | |   / _` |_  / | | | | |_) / _` |/ __| |/ / _` |/ _` |/ _ \
# | |__| (_| |/ /| |_| | |  __/ (_| | (__|   < (_| | (_| |  __/
# |_____\__,_/___|\__, | |_|   \__,_|\___|_|\_\__,_|\__, |\___|
#                 |___/                             |___/      
#
# A unified package manager interface for linux systems
#
# Author: Andrianos Papamarkou
# email: papamarkoua@gmail.com
# web: https://github.com/apapamarkou/lazy-package
#

# Help text

show_help() {
    cat << 'EOF'
pkg - lazy-package: Fast TUI + CLI package manager wrapper
Supports: pacman/yay, apt, dnf, zypper

USAGE:
    pkg                          Launch interactive TUI
    pkg <command> [args]         Run CLI command

COMMANDS:
    install, i <package>...      Install package(s)
    remove, r <package>...       Remove package(s)
    info <package>               Show package information
    search, s <term>             Search packages
    search-names-only, sno <term> Search package names only
    update, u                    Update system
    clean-orphans, co            Remove orphan packages
    help, h                      Show this help

TUI KEY BINDINGS:
    Enter       Install/remove package
    Ctrl+U      System update
    Ctrl+O      Clean orphan packages
    Ctrl+B      Preview PKGBUILD (pacman/AUR only)
    Ctrl+Q/ESC  Exit

EXAMPLES:
    pkg install neovim
    pkg install vim git curl
    pkg info firefox
    pkg search firefox
    pkg update
EOF
}
