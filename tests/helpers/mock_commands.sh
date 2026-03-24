#!/usr/bin/env bash
# Mock command helpers for testing

mock_pacman_slq() {
    pacman() {
        [[ "$1" == "-Slq" ]] && printf 'vim\nneovim\ngit\ncurl\n'
    }
    export -f pacman
}

mock_yay_slq() {
    yay() {
        [[ "$1" == "-Slq" ]] && printf 'yay\nparu\nspotify\n'
    }
    export -f yay
}

mock_pacman_q() {
    pacman() {
        [[ "$1" == "-Q" ]] && { [[ "$2" == "vim" || "$2" == "git" ]] && return 0 || return 1; }
    }
    export -f pacman
}

mock_pacman_si() {
    pacman() {
        [[ "$1" == "-Si" ]] && cat << EOF
Name            : $2
Version         : 1.0.0
Description     : Test package
Architecture    : x86_64
Repository      : extra
Depends On      : glibc  bash
EOF
    }
    export -f pacman
}

mock_apt() {
    apt-get() { return 0; }
    dpkg() { [[ "$1" == "-s" && "$2" == "vim" ]] && return 0 || return 1; }
    apt-cache() {
        [[ "$1" == "pkgnames" ]] && printf 'vim\ngit\ncurl\n'
        [[ "$1" == "show" ]] && echo "Package: $2"
    }
    export -f apt-get dpkg apt-cache
}

mock_dnf() {
    dnf() { return 0; }
    rpm() { [[ "$1" == "-q" && "$2" == "vim" ]] && return 0 || return 1; }
    export -f dnf rpm
}

reset_mocks() {
    unset -f pacman yay pactree apt-get dpkg apt-cache dnf rpm zypper
}
