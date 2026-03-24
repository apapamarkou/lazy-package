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

# TUI preview generation — lazy on-demand loading

colorize_deps() {
    local text="$1" result="$1"
    local words; read -ra words <<< "$text"
    for word in "${words[@]}"; do
        local pkg="${word%%[:<>=]*}"
        if [[ -n "$pkg" ]] && is_installed "$pkg"; then
            result="${result/"$word"/"${COLOR_GREEN}${word}${COLOR_GREY}"}"
        fi
    done
    echo -n "$result"
}

generate_preview() {
    local line="$1"
    local pkg; pkg=$(echo "$line" | awk '{print $3}')
    [[ -z "$pkg" ]] && { echo "No package selected"; return; }

    local info; info=$(get_package_info "$pkg" 2>/dev/null)

    if [[ -n "$info" ]]; then
        echo -e "${COLOR_CYAN}╭────────────────────────────────────────${COLOR_RESET}"
        mapfile -t lines <<< "$info"
        for line in "${lines[@]}"; do
            if [[ "$line" =~ ^[[:space:]] ]]; then
                echo -e "${COLOR_CYAN}│${COLOR_RESET} ${COLOR_GREY}$(colorize_deps "$line")${COLOR_RESET}"
            elif [[ "$line" =~ ^([^:]+):(.*)$ ]]; then
                local field="${BASH_REMATCH[1]}" value="${BASH_REMATCH[2]# }"
                if [[ "$field" =~ "Depends On"|"Optional Deps"|"Depends"|"Recommends" ]]; then
                    local cv; cv=$(colorize_deps "$value")
                    echo -e "${COLOR_CYAN}│${COLOR_RESET} ${COLOR_BLUE}${field}:${COLOR_RESET} ${COLOR_GREY}${cv:-None}${COLOR_RESET}"
                else
                    echo -e "${COLOR_CYAN}│${COLOR_RESET} ${COLOR_BLUE}${field}:${COLOR_RESET} ${COLOR_GREY}${value:-None}${COLOR_RESET}"
                fi
            fi
        done
        echo -e "${COLOR_CYAN}╰────────────────────────────────────────${COLOR_RESET}"
        echo

        echo -e "${COLOR_CYAN}▶ Dependencies${COLOR_RESET}"
        if is_installed "$pkg" && command -v pactree &>/dev/null; then
            pactree "$pkg" 2>/dev/null | while IFS= read -r l; do
                [[ "$l" == "$pkg" ]] && echo -e "  ${COLOR_BOLD}${COLOR_GREEN}$l${COLOR_RESET}" || echo -e "  ${COLOR_DIM}$l${COLOR_RESET}"
            done
        else
            local deps; deps=$(get_package_deps "$pkg" 2>/dev/null)
            if [[ -n "$deps" && "$deps" != "None" ]]; then
                echo -e "  ${COLOR_BOLD}${COLOR_GREY}$pkg${COLOR_RESET}"
                mapfile -t dep_array <<< "$deps"
                local total=${#dep_array[@]} i=0
                for dep in "${dep_array[@]}"; do
                    [[ -z "$dep" ]] && continue
                    i=$((i+1))
                    local dep_name="${dep%%[<>=]*}"
                    local prefix="  ├─"; [[ $i -eq $total ]] && prefix="  └─"
                    if is_installed "$dep_name"; then
                        echo -e "${prefix} ${COLOR_GREEN}$dep_name${COLOR_RESET}"
                    else
                        echo -e "${prefix} ${COLOR_DIM}$dep_name${COLOR_RESET}"
                    fi
                done
            else
                echo -e "  ${COLOR_DIM}None${COLOR_RESET}"
            fi
        fi
    else
        echo -e "${COLOR_CYAN}╭────────────────────────────────────────${COLOR_RESET}"
        echo -e "${COLOR_CYAN}│${COLOR_RESET} ${COLOR_CYAN}Package:${COLOR_RESET} ${COLOR_GREY}$pkg${COLOR_RESET}"
        echo -e "${COLOR_CYAN}│${COLOR_RESET} ${COLOR_CYAN}Status:${COLOR_RESET} ${COLOR_GREY}Information not available${COLOR_RESET}"
        echo -e "${COLOR_CYAN}╰────────────────────────────────────────${COLOR_RESET}"
    fi
}

preview_pkgbuild() {
    local pkg="$1"
    [[ -z "$pkg" ]] && return
    if ! command -v yay &>/dev/null; then
        echo "PKGBUILD preview requires yay (pacman/AUR only)"
        read -rp "Press Enter to continue..."
        return
    fi
    local tmpdir; tmpdir=$(mktemp -d)
    cd "$tmpdir" || return
    echo "Fetching PKGBUILD for $pkg..."
    if yay -G "$pkg" &>/dev/null && [[ -f "$pkg/PKGBUILD" ]]; then
        $PAGER "$pkg/PKGBUILD"
    else
        echo "PKGBUILD not available for $pkg"
        read -rp "Press Enter to continue..."
    fi
    cd - &>/dev/null || exit
    rm -rf "$tmpdir"
}
