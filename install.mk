# Installation commands for end users - separate from `package.mk`, which
# builds the portable package itself (used by CI / contributors) and talks
# to entirely different URLs (code.visualstudio.com, the extension
# marketplace) that are irrelevant here. Run these with
# `make -f install.mk <target>`, e.g.:
#   make -f install.mk install-release RELEASE_URL=https://artifactory.example.com/artifactory/generic-repo/Portable-VSCode-linux-x64.zip
#   make -f install.mk install-release RELEASE_URL=... ALIAS=vscode-portable INSTALL_DIR=/opt/vscode-portable
#   make -f install.mk clean-cache
#
# RELEASE_URL has no default and must be set: the deployment environment
# cannot reach github.com directly at all, only wherever the .zip is
# actually mirrored (a JFrog Artifactory generic repo, proxied), so a
# github.com fallback would just silently be wrong there. Set it explicitly:
#   make -f install.mk install-release RELEASE_URL=https://artifactory.example.com/artifactory/generic-repo/Portable-VSCode-linux-x64.zip
# wget already honors the standard http_proxy/https_proxy/no_proxy
# environment variables for reaching RELEASE_URL, so a plain network proxy
# needs no change here - just set those before invoking make.
#
# If that URL requires authentication - common for an Artifactory generic
# repo - download-release prompts for a username and password (HTTP Basic
# auth) unless ARTIFACTORY_USER/ARTIFACTORY_PASSWORD are already set, in
# which case it uses those without prompting. Prefer exporting them rather
# than passing them inline on the make command line (`export
# ARTIFACTORY_PASSWORD=...` in your shell, then plain `make -f install.mk
# install-release`) - a value passed as `make ARTIFACTORY_PASSWORD=...
# install-release` lands in shell history and is visible to other users on
# the box via `ps` while make is running. The password itself is passed to
# wget via a throwaway .netrc (under a temp $HOME, never touching your real
# one) rather than a CLI flag, so it doesn't show up in `ps` either.

SHELL := /bin/bash
.DEFAULT_GOAL := install-release

# --- Settings (override any of these on the command line) ---
RELEASE_URL          ?=
ARTIFACTORY_USER     ?=
ARTIFACTORY_PASSWORD ?=
INSTALL_DIR          ?= $(HOME)/.local/opt
BIN_DIR              ?= $(HOME)/.local/bin
ALIAS                ?= code
CONFIG_DIR           ?= $(HOME)/.config/Portable-VSCode
STANDARD_CONFIG_DIR  ?= $(HOME)/.config/Code

# Downloads the packaged .zip from RELEASE_URL (typically an Artifactory
# generic repo, possibly authenticated - see ARTIFACTORY_USER/
# ARTIFACTORY_PASSWORD above), unpacks it to INSTALL_DIR, and symlinks it
# onto BIN_DIR as ALIAS. User settings persist across reinstalls in
# CONFIG_DIR (symlinked in), so upgrading is just re-running this target.
download-release:
	@if [ -z "$(RELEASE_URL)" ]; then \
		echo "RELEASE_URL is not set - point it at wherever the packaged .zip is reachable from this environment (e.g. your Artifactory generic repo), e.g.:" >&2; \
		echo "  make -f install.mk install-release RELEASE_URL=https://artifactory.example.com/artifactory/generic-repo/Portable-VSCode-linux-x64.zip" >&2; \
		exit 1; \
	fi
	@user="$(ARTIFACTORY_USER)"; \
	if [ -z "$$user" ]; then \
		read -r -p "Artifactory username (leave blank if not needed): " user; \
	fi; \
	netrc_home=""; \
	if [ -n "$$user" ]; then \
		pass="$(ARTIFACTORY_PASSWORD)"; \
		if [ -z "$$pass" ]; then \
			read -r -s -p "Artifactory password: " pass; \
			echo; \
		fi; \
		host=$$(echo "$(RELEASE_URL)" | sed -E 's#^[a-zA-Z]+://([^/]+).*#\1#'); \
		netrc_home=$$(mktemp -d); \
		trap 'rm -rf "$$netrc_home"' EXIT; \
		( umask 077; printf 'machine %s login %s password %s\n' "$$host" "$$user" "$$pass" > "$$netrc_home/.netrc" ); \
	fi; \
	HOME="$${netrc_home:-$$HOME}" wget --no-verbose "$(RELEASE_URL)" -O /tmp/Portable-VSCode-linux-x64.zip

install-release: download-release
	rm -Rf /tmp/Portable-VSCode-linux-x64
	unzip -q /tmp/Portable-VSCode-linux-x64.zip -d /tmp/Portable-VSCode-linux-x64
	rm -f /tmp/Portable-VSCode-linux-x64.zip
	mkdir -p "$(INSTALL_DIR)" "$(BIN_DIR)"
	rm -Rf "$(INSTALL_DIR)/Portable-VSCode-linux-x64"
	mv /tmp/Portable-VSCode-linux-x64/Portable-VSCode-linux-x64 "$(INSTALL_DIR)"
	rmdir /tmp/Portable-VSCode-linux-x64
	ln -s -f "$(INSTALL_DIR)/Portable-VSCode-linux-x64/bin/code" "$(BIN_DIR)/$(ALIAS)"
	mkdir -p "$(CONFIG_DIR)/User"
	mkdir -p "$(INSTALL_DIR)/Portable-VSCode-linux-x64/data/user-data"
	rmdir "$(INSTALL_DIR)/Portable-VSCode-linux-x64/data/user-data/User" 2>/dev/null || true
	ln -s -f "$(CONFIG_DIR)/User" "$(INSTALL_DIR)/Portable-VSCode-linux-x64/data/user-data/"
	mkdir -p "$(HOME)/.local/share/icons/hicolor/scalable/apps"
	cp "$(INSTALL_DIR)/Portable-VSCode-linux-x64/vscode.svg" "$(HOME)/.local/share/icons/hicolor/scalable/apps/Portable-VSCode-$(ALIAS).svg"
	@printf '[Desktop Entry]\nType=Application\nVersion=1.0\nName=VSCode-Portable (%s)\nComment=Portable version of Visual Studio Code with pre-installed extensions\nExec=sh -c "%s/Portable-VSCode-linux-x64/bin/code"\nIcon=Portable-VSCode-%s\nTerminal=false\nCategories=Development;\n' "$(ALIAS)" "$(INSTALL_DIR)" "$(ALIAS)" > /tmp/Portable-VSCode-$(ALIAS).desktop
	desktop-file-install --dir="$(HOME)/.local/share/applications" /tmp/Portable-VSCode-$(ALIAS).desktop
	update-desktop-database "$(HOME)/.local/share/applications"
	@echo "Installed to $(INSTALL_DIR)/Portable-VSCode-linux-x64 - run '$(ALIAS)' (make sure $(BIN_DIR) is on your PATH)."

uninstall-release:
	rm -Rf "$(INSTALL_DIR)/Portable-VSCode-linux-x64"
	rm -f "$(BIN_DIR)/$(ALIAS)"
	rm -f "$(HOME)/.local/share/applications/Portable-VSCode-$(ALIAS).desktop"
	rm -f "$(HOME)/.local/share/icons/hicolor/scalable/apps/Portable-VSCode-$(ALIAS).svg"

# Clears VS Code's own runtime caches (V8/CachedData, GPU cache, crash dumps,
# logs, ...) - handy after an upgrade, since those caches are tied to the
# specific build that created them and are never reused by a newer version
# anyway. Checks both the portable install at INSTALL_DIR and a standard
# (non-portable) VS Code install's profile at STANDARD_CONFIG_DIR
# (~/.config/Code by default - that's where a regular .deb/.rpm/snap install
# keeps its profile on Linux), clearing whichever of the two actually
# exists. Leaves User settings (symlinked to CONFIG_DIR for the portable
# install) and installed extensions untouched either way.
clean-cache:
	@found=0; \
	for USER_DATA in "$(INSTALL_DIR)/Portable-VSCode-linux-x64/data/user-data" "$(STANDARD_CONFIG_DIR)"; do \
		if [ -d "$$USER_DATA" ]; then \
			found=1; \
			echo "Clearing VS Code caches under $$USER_DATA (User settings and extensions are left untouched)..."; \
			rm -Rf \
				"$$USER_DATA/Cache" "$$USER_DATA/Code Cache" "$$USER_DATA/CachedData" \
				"$$USER_DATA/CachedExtensionVSIXs" "$$USER_DATA/CachedProfilesData" \
				"$$USER_DATA/CachedConfigurations" "$$USER_DATA/GPUCache" \
				"$$USER_DATA/DawnGraphiteCache" "$$USER_DATA/DawnWebGPUCache" \
				"$$USER_DATA/blob_storage" "$$USER_DATA/Crashpad" "$$USER_DATA/logs" \
				"$$USER_DATA/DIPS" "$$USER_DATA/DIPS-wal" \
				"$$USER_DATA/Network Persistent State" "$$USER_DATA/Trust Tokens" \
				"$$USER_DATA/Trust Tokens-journal" "$$USER_DATA/Shared Dictionary"; \
		fi; \
	done; \
	if [ "$$found" = 0 ]; then \
		echo "No VS Code install found (checked $(INSTALL_DIR)/Portable-VSCode-linux-x64 and $(STANDARD_CONFIG_DIR))" >&2; \
		exit 1; \
	fi
