# Portable Visual Studio Code packager

[![Package](https://github.com/jyannick/vscode-portable/actions/workflows/package.yml/badge.svg)](https://github.com/jyannick/vscode-portable/actions/workflows/package.yml)

Prepare a portable version of Visual Studio Code with a set of preinstalled extensions by just running a single command.

See https://code.visualstudio.com/docs/editor/portable

## How to build your custom version

- clone this repository on a linux computer
- add your favorite extensions in `extensions.txt`
- run `make -f package.mk` to build the package
- copy `Portable-VSCode-linux-x64.zip` where you want

## Pre-built packages

The github releases of this project contain ready-to-use packages with my favorite set of extensions.

> [!IMPORTANT]
> This is NOT an official VSCode release, it is simply a repackaging of VSCode for my personal use.


### Manually

- Download the [latest release](https://github.com/jyannick/vscode-portable/releases/latest)
- unzip
- run `./bin/code`

### Using `install.mk`

`install.mk` drives the same download-and-install flow as a set of `make` targets, with the download URL, install path, and command alias all overridable. `RELEASE_URL` has no default and must be set - e.g. to your organization's JFrog Artifactory generic repo, if that's the only thing reachable from the deployment environment:

```bash
make -f install.mk install-release RELEASE_URL=https://artifactory.example.com/artifactory/generic-repo/Portable-VSCode-linux-x64.zip
# or, further customized:
make -f install.mk install-release RELEASE_URL=... ALIAS=vscode-portable INSTALL_DIR=/opt/vscode-portable
```

If that URL needs a username/password (HTTP Basic auth), `install-release` prompts for them interactively (the password isn't echoed). To skip the prompt - e.g. in a script - export `ARTIFACTORY_USER`/`ARTIFACTORY_PASSWORD` beforehand rather than passing them inline on the command line, which would leak into shell history and `ps`.

Other targets: `make -f install.mk uninstall-release` removes the install, and `make -f install.mk clean-cache` clears VS Code's own runtime caches (handy after upgrading, since they're tied to the specific build that created them) without touching your settings or installed extensions - it checks both the portable install and a standard (non-portable) VS Code install's profile at `~/.config/Code`, clearing whichever exists.

