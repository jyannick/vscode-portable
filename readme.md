# Portable VSCode packager

[![Package](https://github.com/jyannick/vscode-portable/actions/workflows/package.yml/badge.svg)](https://github.com/jyannick/vscode-portable/actions/workflows/package.yml)

Portable version of VSCode with a set of preinstalled extensions.

See https://code.visualstudio.com/docs/editor/portable

## How to install

### Automated script

`curl https://github.com/jyannick/vscode-portable/releases/latest/download/install.sh | bash`

### Manually

- Download the [latest release](https://github.com/jyannick/vscode-portable/releases/latest)
- unzip
- run `./bin/code`

## How to build a custom version

- add your favorite extensions in `extensions.txt`
- `make`
- copy `Portable-VSCode-linux-x64.zip` where you want