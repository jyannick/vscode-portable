.DEFAULT_GOAL := all

download:
	wget --no-verbose "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64" -O vscode.tar.gz

unpack:
	rm -Rf VSCode-linux-x64
	tar xf vscode.tar.gz
	mkdir VSCode-linux-x64/data

run:
	VSCode-linux-x64/bin/code

install-extensions:
	for extension in `cat extensions.txt` ; do \
		VSCode-linux-x64/bin/code --install-extension $${extension} ; \
	done

manifest:
	echo "# Portable VSCode" > manifest.md
	git describe --tags >> manifest.md
	echo "## VSCode version" >> manifest.md
	VSCode-linux-x64/bin/code -v | sed 's|^|* |g' >> manifest.md
	echo "## Extensions" >> manifest.md
	VSCode-linux-x64/bin/code --list-extensions --show-versions | sed 's|^|* |g' >> manifest.md
	cp manifest.md VSCode-linux-x64/portable-vscode-manifest.md

package:
	zip -r Portable-VSCode-linux-x64.zip VSCode-linux-x64
	
all_but_package: download unpack install-extensions manifest

all: all_but_package package

