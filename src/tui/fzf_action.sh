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

# shellcheck disable=SC1091

MODULE_DIR="${MODULE_DIR:-$(dirname "$0")}"
source "$MODULE_DIR/core/loader.sh"

require core/config
require core/colors
require core/utils
require core/packager
require cache/cache
require tui/actions

clear
# shellcheck disable=SC2016,SC1003
echo '  _                      ____            _                    '
echo ' | |    __ _ _____   _  |  _ \ __ _  ___| | ____ _  __ _  ___ '
echo ' | |   / _` |_  / | | | | |_) / _` |/ __| |/ / _` |/ _` |/ _ \'
echo ' | |__| (_| |/ /| |_| | |  __/ (_| | (__|   < (_| | (_| |  __/'
echo ' |_____\__,_/___|\__, | |_|   \__,_|\___|_|\_\__,_|\__, |\___|'
echo '                 |___/                             |___/      '
handle_package_action "$1"
