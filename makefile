.DEFAULT_GOAL := all

clean:
	rm -Rf Portable-VSCode-linux-x64
	rm -Rf visual-studio-code-icons
	rm -f vscode.tar.gz
	rm -f visual-studio-code-icons.zip
	rm -f manifest.md
	rm -f Portable-VSCode-linux-x64.zip

download:
	wget --no-verbose "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64" -O vscode.tar.gz
	wget --no-verbose "https://code.visualstudio.com/assets/branding/visual-studio-code-icons.zip" -O visual-studio-code-icons.zip

unpack:
	rm -Rf Portable-VSCode-linux-x64
	tar xf vscode.tar.gz
	mv VSCode-linux-x64 Portable-VSCode-linux-x64
	mkdir Portable-VSCode-linux-x64/data
	rm -Rf visual-studio-code-icons 
	unzip visual-studio-code-icons.zip

run:
	Portable-VSCode-linux-x64/bin/code

install-extensions:
	Portable-VSCode-linux-x64/bin/code `cat extensions.txt | sed 's|^|--install-extension |g' | tr '\n' ' '`

manifest:
	echo "# Portable VSCode" > manifest.md
	echo "https://github.com/jyannick/vscode-portable\n" >> manifest.md
	( git describe --tags || git show --oneline -s ) >> manifest.md
	echo "## VSCode version" >> manifest.md
	Portable-VSCode-linux-x64/bin/code -v | sed 's|^|* |g' >> manifest.md
	echo "## Extensions" >> manifest.md
	Portable-VSCode-linux-x64/bin/code --list-extensions --show-versions | sed 's|^|* |g' >> manifest.md
	cp manifest.md Portable-VSCode-linux-x64/portable-vscode-manifest.md

package:
	cp Portable-VSCode.desktop Portable-VSCode-linux-x64
	cp visual-studio-code-icons/vscode.svg Portable-VSCode-linux-x64
	zip --filesync -r Portable-VSCode-linux-x64.zip Portable-VSCode-linux-x64

install:
	./install.sh --local

uninstall:
	rm -Rf ~/.local/opt/Portable-VSCode-linux-x64
	rm ~/.local/bin/code
	
all_but_package: download unpack install-extensions manifest

all: all_but_package package

