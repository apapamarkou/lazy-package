INSTALL_DIR  := $(HOME)/.local/share/lazy-package
BIN_DIR      := $(HOME)/.local/bin
DESKTOP_DIR  := $(HOME)/.local/share/applications
REPO_URL     := https://github.com/apapamarkou/lazy-package.git

.PHONY: all install uninstall link clean test

all: link

# Install to ~/.local (mirrors the install script)
install:
	@bash install

# Uninstall from ~/.local
uninstall:
	@bash uninstall

# Remove the root symlink
clean:
	@rm -f pkg
	@echo "✓ Removed ./pkg symlink"

# Run test suite
test:
	@bash tests/run_all_tests.sh
