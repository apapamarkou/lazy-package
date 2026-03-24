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

# TUI interface — fast startup with lazy preview

launch_tui() {
    local update_msg=""
    if check_updates; then
        update_msg="${COLOR_RESET}${COLOR_YELLOW} | Updates available — Ctrl+U"
    fi

    ensure_cache

    export MODULE_DIR
    local pkg_label; pkg_label=$(pkgType | tr '[:lower:]' '[:upper:]')
    local pkgbuild_hint="" pkgbuild_bind=""
    if [[ $(pkgType) == "pacman" ]]; then
        pkgbuild_hint=" | Ctrl+B: view PKGBUILD"
        pkgbuild_bind="--bind ctrl-b:execute($MODULE_DIR/tui/fzf_pkgbuild.sh {})"
    fi

    while true; do
        local selected
        selected=$("$MODULE_DIR/tui/fzf_list.sh" | fzf \
            --ansi \
            --layout=reverse \
            --height=100% \
            --border \
            --preview-window=right:60% \
            --preview "$MODULE_DIR/tui/fzf_preview.sh {}" \
            --header "$(echo -e "${COLOR_CYAN}${COLOR_BOLD}lazy-package [${pkg_label}]${update_msg}${COLOR_RESET}\n${COLOR_DIM}Enter: install/remove | Ctrl+O: delete orphans${pkgbuild_hint} | Ctrl+Q: quit${COLOR_RESET}")" \
            --bind "enter:execute($MODULE_DIR/tui/fzf_action.sh {})+reload($MODULE_DIR/tui/fzf_list.sh)" \
            --bind "ctrl-u:execute($MODULE_DIR/tui/fzf_update.sh)" \
            --bind "ctrl-o:execute($MODULE_DIR/tui/fzf_orphans.sh)" \
            ${pkgbuild_bind} \
            --bind "ctrl-q:abort" \
            --bind "esc:abort")

        [[ -z "$selected" ]] && break
    done
}
