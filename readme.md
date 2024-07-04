# Portable Visual Studio Code packager

[![Package](https://github.com/jyannick/vscode-portable/actions/workflows/package.yml/badge.svg)](https://github.com/jyannick/vscode-portable/actions/workflows/package.yml)

Prepare a portable version of Visual Studio Code with a set of preinstalled extensions by just running a single command.

See https://code.visualstudio.com/docs/editor/portable

## How to build your custom version

- clone this repository on a linux computer
- add your favorite extensions in `extensions.txt`
- run `make` to build the package
- copy `Portable-VSCode-linux-x64.zip` where you want

## Pre-built packages

The github releases of this project contain ready-to-use packages with my favorite set of extensions.

> [!IMPORTANT]
> This is NOT an official VSCode release, it is simply a repackaging of VSCode for my personal use.


### Automated script

Just paste this into a terminal to install my latest pre-packaged release:

```bash
curl -L https://github.com/jyannick/vscode-portable/releases/latest/download/install.sh | bash
```

> [!CAUTION]
> You should review [the installation script](https://github.com/jyannick/vscode-portable/releases/latest/download/install.sh) before running it. Use at your own risk.

### Manually

- Download the [latest release](https://github.com/jyannick/vscode-portable/releases/latest)
- unzip
- run `./bin/code`

