# Portable VSCode packager

[![Package](https://github.com/jyannick/vscode-portable/actions/workflows/package.yml/badge.svg)](https://github.com/jyannick/vscode-portable/actions/workflows/package.yml)

Portable version of VSCode with a set of preinstalled extensions.

See https://code.visualstudio.com/docs/editor/portable

## How to install

### Automated script

Just paste this into a terminal:

```bash
curl -L https://github.com/jyannick/vscode-portable/releases/latest/download/install.sh | bash
```

> [!CAUTION]
> You should review [the installation script](https://github.com/jyannick/vscode-portable/releases/latest/download/install.sh) before running it. Use at your own risk.

### Manually

- Download the [latest release](https://github.com/jyannick/vscode-portable/releases/latest)
- unzip
- run `./bin/code`

## How to build a custom version

- add your favorite extensions in `extensions.txt`
- run `make` to build the package
- copy `Portable-VSCode-linux-x64.zip` where you want