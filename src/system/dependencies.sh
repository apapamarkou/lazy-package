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

# Dependency checking — per packager

# Common deps required regardless of packager
_COMMON_DEPS=(fzf jq curl)

# Per-packager extra deps
_PACMAN_DEPS=(pacman yay)
_APT_DEPS=(apt-get)
_DNF_DEPS=(dnf)
_ZYPPER_DEPS=(zypper)

# Install a missing dep using whatever is available
_install_dep() {
    local dep="$1"
    local pkg_type="$2"
    case "$pkg_type" in
        pacman) sudo pacman -S --needed --noconfirm "$dep" ;;
        apt)    sudo apt-get install -y "$dep" ;;
        dnf)    sudo dnf install -y "$dep" ;;
        zypper) sudo zypper install -y "$dep" ;;
    esac
}

check_dependencies() {
    # Detect packager first (before core/packager.sh loads)
    local pkg_type
    if command -v pacman &>/dev/null; then pkg_type="pacman"
    elif command -v apt-get &>/dev/null; then pkg_type="apt"
    elif command -v dnf &>/dev/null; then pkg_type="dnf"
    elif command -v zypper &>/dev/null; then pkg_type="zypper"
    else
        notify-send "lazy-package" "Unsupported platform: no supported package manager found." 2>/dev/null || true
        echo -e "${COLOR_RED}Error: No supported package manager found.${COLOR_RESET}" >&2
        return 1
    fi

    local extra_deps_var="_${pkg_type^^}_DEPS[@]"
    local all_deps=("${_COMMON_DEPS[@]}" "${!extra_deps_var}")
    local missing=()

    for dep in "${all_deps[@]}"; do
        command -v "$dep" &>/dev/null || missing+=("$dep")
    done

    [[ ${#missing[@]} -eq 0 ]] && return 0

    echo -e "${COLOR_YELLOW}Missing dependencies: ${missing[*]}${COLOR_RESET}"
    echo -n "Install missing dependencies? (Y/N): "
    read -n 1 -r response; echo
    if [[ "$response" =~ ^[Yy]$ ]]; then
        for dep in "${missing[@]}"; do
            echo "Installing $dep..."
            _install_dep "$dep" "$pkg_type" || {
                notify-send "lazy-package" "Failed to install dependency: $dep" 2>/dev/null || true
                echo -e "${COLOR_RED}Failed to install: $dep${COLOR_RESET}" >&2
                return 1
            }
        done
    else
        notify-send "lazy-package" "Missing dependencies: ${missing[*]}" 2>/dev/null || true
        echo -e "${COLOR_RED}Dependency error: ${missing[*]} required.${COLOR_RESET}" >&2
        return 1
    fi
}
