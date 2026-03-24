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

# CLI command implementations

require tui/preview

colorize_deps_cli() {
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

cli_install() {
    [[ $# -eq 0 ]] && { echo "Usage: pkg install <package> [package2] ..."; exit 1; }
    for pkg in "$@"; do install_package "$pkg"; done
}

cli_remove() {
    [[ $# -eq 0 ]] && { echo "Usage: pkg remove <package> [package2] ..."; exit 1; }
    for pkg in "$@"; do remove_package "$pkg"; done
}

cli_info() {
    local pkg="$1"
    [[ -z "$pkg" ]] && { echo "Usage: pkg info <package>"; exit 1; }

    local info; info=$(get_package_info "$pkg" 2>/dev/null)
    if [[ -n "$info" ]]; then
        (
            mapfile -t lines <<< "$info"
            for line in "${lines[@]}"; do
                if [[ "$line" =~ ^[[:space:]] ]]; then
                    echo -e " ${COLOR_GREY}$(colorize_deps_cli "$line")${COLOR_RESET}"
                elif [[ "$line" =~ ^([^:]+):(.*)$ ]]; then
                    local field="${BASH_REMATCH[1]}" value="${BASH_REMATCH[2]# }"
                    if [[ "$field" =~ "Depends On"|"Depends"|"Optional Deps"|"Recommends" ]]; then
                        echo -e " ${COLOR_BLUE}${field}:${COLOR_RESET} ${COLOR_GREY}$(colorize_deps_cli "${value:-None}")${COLOR_RESET}"
                    else
                        echo -e " ${COLOR_BLUE}${field}:${COLOR_RESET} ${COLOR_GREY}${value:-None}${COLOR_RESET}"
                    fi
                fi
            done
            echo
            if is_installed "$pkg" && command -v pactree &>/dev/null; then
                echo -e "${COLOR_CYAN}▶ Dependency Tree${COLOR_RESET}"
                pactree "$pkg" 2>/dev/null | while IFS= read -r l; do
                    [[ "$l" == "$pkg" ]] && echo -e "  ${COLOR_BOLD}${COLOR_GREEN}$l${COLOR_RESET}" || echo -e "  ${COLOR_DIM}$l${COLOR_RESET}"
                done
            fi
        ) | $PAGER
    else
        echo -e "${COLOR_RED}Package '$pkg' not found${COLOR_RESET}"
        exit 1
    fi
}

cli_search() {
    local term="$1"
    [[ -z "$term" ]] && { echo "Usage: pkg search <term>"; exit 1; }

    declare -A installed_map
    while read -r pkg; do installed_map[$pkg]=1; done < <(list_installed)

    local results; results=$(search_cache "$term")
    local count; count=$(echo "$results" | grep -c .)

    _render_results() {
        echo "$results" | while read -r pkg source; do
            local is_inst=0
            [[ -n "${installed_map[$pkg]:-}" ]] && is_inst=1
            format_package_line "$pkg" "$source" "$is_inst"
        done
    }

    if [[ $count -gt 24 ]]; then
        _render_results | $PAGER
    else
        _render_results
    fi
}

cli_update() { perform_update; }

cli_clean_orphans() { clean_orphans; }
